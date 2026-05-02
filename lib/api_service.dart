import 'dart:convert';
import 'package:gunun_sozleri_kerem_ilker/quote_model.dart';
import 'package:http/http.dart' as http;


class ApiService {
  // Emülatör kullanıyorsan 10.0.2.2, fiziksel cihazsa kendi IP'ni yazmalısın.
  static const String baseUrl = "http://localhost:5136/api/SozApi"; 

  // Listeleme (GET)
  Future<List<Soz>> getSozler() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Soz.fromJson(data)).toList();
    } else {
      throw Exception('Sözler yüklenemedi');
    }
  }

  // Ekleme (POST)
  Future<bool> sozEkle(Soz soz) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(soz.toJson()), // Modeldeki toJson'ı kullanır
  );
  
  // .NET API tarafında başarılı ekleme genellikle 201 Created döner
  return response.statusCode == 201 || response.statusCode == 200;
}

  // Güncelleme (PUT)
  Future<bool> sozGuncelle(int id, Soz soz) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(soz.toJson()),
    );
    return response.statusCode == 204;
  }

  // Silme (DELETE)
  Future<bool> sozSil(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    return response.statusCode == 204;
  }
}