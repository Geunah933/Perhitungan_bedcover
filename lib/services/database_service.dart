import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/motif_order.dart';
import '../models/formula.dart';
import '../utils/constants.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE motif_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        nama_motif TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        motif_order_id INTEGER NOT NULL,
        ukuran INTEGER NOT NULL,
        pcs INTEGER NOT NULL,
        is_tinggi_30 INTEGER NOT NULL DEFAULT 0,
        kain_per_pcs REAL NOT NULL,
        total_kain REAL NOT NULL,
        ongkos_per_pcs INTEGER NOT NULL,
        total_ongkos INTEGER NOT NULL,
        total_bantal REAL NOT NULL,
        FOREIGN KEY (motif_order_id) REFERENCES motif_orders(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE formulas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ukuran INTEGER NOT NULL,
        is_tinggi_30 INTEGER NOT NULL DEFAULT 0,
        kain_meter REAL NOT NULL,
        UNIQUE(ukuran, is_tinggi_30)
      )
    ''');

    await db.execute('''
      CREATE TABLE ongkos_config (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ukuran_min INTEGER NOT NULL,
        ukuran_max INTEGER NOT NULL,
        harga INTEGER NOT NULL
      )
    ''');

    // Insert default formulas
    for (final entry in defaultKainNormal.entries) {
      await db.insert('formulas', {
        'ukuran': entry.key,
        'is_tinggi_30': 0,
        'kain_meter': entry.value,
      });
    }
    for (final entry in defaultKainTinggi30.entries) {
      await db.insert('formulas', {
        'ukuran': entry.key,
        'is_tinggi_30': 1,
        'kain_meter': entry.value,
      });
    }

    // Insert default ongkos config
    await db.insert('ongkos_config', {
      'ukuran_min': 90,
      'ukuran_max': 120,
      'harga': ongkosKecil,
    });
    await db.insert('ongkos_config', {
      'ukuran_min': 140,
      'ukuran_max': 200,
      'harga': ongkosBesar,
    });
  }

  // ── ORDER CRUD ──────────────────────────────────────────────

  /// Insert order beserta semua motif dan items
  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.transaction((txn) async {
      final orderId = await txn.insert('orders', order.toMap()..remove('id'));

      for (final motif in order.motifs) {
        final motifMap = motif.toMap()..remove('id');
        motifMap['order_id'] = orderId;
        final motifId = await txn.insert('motif_orders', motifMap);

        for (final item in motif.items) {
          final itemMap = item.toMap()..remove('id');
          itemMap['motif_order_id'] = motifId;
          await txn.insert('order_items', itemMap);
        }
      }

      return orderId;
    });
  }

  /// Get single order by ID with all relations
  Future<Order?> getOrder(int id) async {
    final db = await database;
    final orderMaps = await db.query('orders', where: 'id = ?', whereArgs: [id]);
    if (orderMaps.isEmpty) return null;

    return _buildOrder(db, orderMaps.first);
  }

  /// Get all orders, optionally filtered by date and/or owner
  Future<List<Order>> getOrders({
    DateTime? tanggal,
    String? owner,
    int? limit,
  }) async {
    final db = await database;
    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (tanggal != null) {
      where.add('tanggal = ?');
      whereArgs.add(tanggal.toIso8601String().split('T').first);
    }
    if (owner != null) {
      where.add('owner = ?');
      whereArgs.add(owner);
    }

    final orderMaps = await db.query(
      'orders',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    final orders = <Order>[];
    for (final map in orderMaps) {
      orders.add(await _buildOrder(db, map));
    }
    return orders;
  }

  /// Get orders for a date range (for weekly recap)
  Future<List<Order>> getOrdersInRange(DateTime start, DateTime end) async {
    final db = await database;
    final orderMaps = await db.query(
      'orders',
      where: 'tanggal >= ? AND tanggal <= ?',
      whereArgs: [
        start.toIso8601String().split('T').first,
        end.toIso8601String().split('T').first,
      ],
      orderBy: 'tanggal ASC, created_at ASC',
    );

    final orders = <Order>[];
    for (final map in orderMaps) {
      orders.add(await _buildOrder(db, map));
    }
    return orders;
  }

  /// Delete order and all related data (cascade)
  Future<void> deleteOrder(int id) async {
    final db = await database;
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  /// Update order (delete + re-insert approach for simplicity)
  Future<void> updateOrder(Order order) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete old motifs and items (cascade)
      final oldMotifs = await txn.query(
        'motif_orders',
        where: 'order_id = ?',
        whereArgs: [order.id],
      );
      for (final m in oldMotifs) {
        await txn.delete('order_items',
            where: 'motif_order_id = ?', whereArgs: [m['id']]);
      }
      await txn.delete('motif_orders',
          where: 'order_id = ?', whereArgs: [order.id]);

      // Update order fields
      await txn.update(
        'orders',
        {
          'owner': order.owner,
          'tanggal': order.tanggal.toIso8601String().split('T').first,
        },
        where: 'id = ?',
        whereArgs: [order.id],
      );

      // Re-insert motifs and items
      for (final motif in order.motifs) {
        final motifMap = motif.toMap()..remove('id');
        motifMap['order_id'] = order.id;
        final motifId = await txn.insert('motif_orders', motifMap);

        for (final item in motif.items) {
          final itemMap = item.toMap()..remove('id');
          itemMap['motif_order_id'] = motifId;
          await txn.insert('order_items', itemMap);
        }
      }
    });
  }

  /// Build Order object from map with all relations
  Future<Order> _buildOrder(Database db, Map<String, dynamic> orderMap) async {
    final motifMaps = await db.query(
      'motif_orders',
      where: 'order_id = ?',
      whereArgs: [orderMap['id']],
    );

    final motifs = <MotifOrder>[];
    for (final motifMap in motifMaps) {
      final itemMaps = await db.query(
        'order_items',
        where: 'motif_order_id = ?',
        whereArgs: [motifMap['id']],
      );
      final items = itemMaps.map((m) => OrderItem.fromMap(m)).toList();
      motifs.add(MotifOrder.fromMap(motifMap, items: items));
    }

    return Order.fromMap(orderMap, motifs: motifs);
  }

  // ── FORMULA CRUD ────────────────────────────────────────────

  /// Get all formulas
  Future<List<Formula>> getFormulas() async {
    final db = await database;
    final maps = await db.query('formulas', orderBy: 'ukuran ASC, is_tinggi_30 ASC');
    return maps.map((m) => Formula.fromMap(m)).toList();
  }

  /// Update formula kain
  Future<void> updateFormula(Formula formula) async {
    final db = await database;
    await db.update(
      'formulas',
      {'kain_meter': formula.kainMeter},
      where: 'ukuran = ? AND is_tinggi_30 = ?',
      whereArgs: [formula.ukuran, formula.isTinggi30 ? 1 : 0],
    );
  }

  /// Get all ongkos configs
  Future<List<OngkosConfig>> getOngkosConfigs() async {
    final db = await database;
    final maps = await db.query('ongkos_config', orderBy: 'ukuran_min ASC');
    return maps.map((m) => OngkosConfig.fromMap(m)).toList();
  }

  /// Update ongkos config
  Future<void> updateOngkosConfig(OngkosConfig config) async {
    final db = await database;
    await db.update(
      'ongkos_config',
      {'harga': config.harga},
      where: 'id = ?',
      whereArgs: [config.id],
    );
  }

  /// Reset formulas to defaults
  Future<void> resetFormulas() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('formulas');
      await txn.delete('ongkos_config');

      for (final entry in defaultKainNormal.entries) {
        await txn.insert('formulas', {
          'ukuran': entry.key,
          'is_tinggi_30': 0,
          'kain_meter': entry.value,
        });
      }
      for (final entry in defaultKainTinggi30.entries) {
        await txn.insert('formulas', {
          'ukuran': entry.key,
          'is_tinggi_30': 1,
          'kain_meter': entry.value,
        });
      }
      await txn.insert('ongkos_config', {
        'ukuran_min': 90,
        'ukuran_max': 120,
        'harga': ongkosKecil,
      });
      await txn.insert('ongkos_config', {
        'ukuran_min': 140,
        'ukuran_max': 200,
        'harga': ongkosBesar,
      });
    });
  }

  // ── STATS ───────────────────────────────────────────────────

  /// Get total ongkos for a specific date and owner
  Future<int> getTotalOngkos({required DateTime tanggal, String? owner}) async {
    final orders = await getOrders(tanggal: tanggal, owner: owner);
    return orders.fold<int>(0, (sum, o) => sum + o.totalOngkos);
  }

  /// Get distinct dates that have orders
  Future<List<DateTime>> getOrderDates() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT tanggal FROM orders ORDER BY tanggal DESC',
    );
    return result.map((m) => DateTime.parse(m['tanggal'] as String)).toList();
  }
}
