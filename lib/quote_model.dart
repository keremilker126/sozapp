class Soz {
  final int? id;
  final String kategori;
  final String metin;
  final String kaynak;

  Soz({this.id, required this.kategori, required this.metin, required this.kaynak});

  // JSON'dan Dart nesnesine
  factory Soz.fromJson(Map<String, dynamic> json) {
    return Soz(
      id: json['id'],
      kategori: json['kategori'] ?? '',
      metin: json['metin'] ?? '',
      kaynak: json['kaynak'] ?? '',
    );
  }

  // Dart nesnesinden JSON'a (Ekleme ve Güncelleme için)
  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
  // Eğer id null değilse ekle (düzenleme için), null ise JSON'a hiç ekleme (yeni kayıt için)
  if (id != null) {
    data['id'] = id;
  }
  data['kategori'] = kategori;
  data['metin'] = metin;
  data['kaynak'] = kaynak;
  return data;
}
}