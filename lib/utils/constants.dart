/// Default patokan kain normal (ukuran → meter)
const Map<int, double> defaultKainNormal = {
  90: 2.11,
  100: 2.19,
  120: 2.35,
  140: 3.30,
  160: 3.53,
  180: 3.73,
  200: 3.93,
};

/// Default patokan kain tinggi 30 (ukuran → meter)
const Map<int, double> defaultKainTinggi30 = {
  90: 2.29,
  100: 2.39,
  120: 2.83,
  140: 3.52,
  160: 3.93,
  180: 4.15,
  200: 4.35,
};

/// Ukuran yang valid
const List<int> validUkuran = [90, 100, 120, 140, 160, 180, 200];

/// Ongkos jahit per pcs
const int ongkosKecil = 15000; // ukuran 90-120
const int ongkosBesar = 20000; // ukuran 140-200

/// Batas ukuran kecil vs besar
const int batasUkuranKecil = 120; // <= 120 = kecil, > 120 = besar

/// Default owners
const List<String> defaultOwners = ['Gilang', 'Bapa'];

/// Database name
const String dbName = 'gilang_mandiri.db';
const int dbVersion = 1;
