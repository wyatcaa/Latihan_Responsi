import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/amiibo_model.dart';

class ApiService {
  static const String baseUrl = "https://www.amiiboapi.com/api/amiibo";

  static Future<List<AmiiboModel>> fetchAllAmiibo() async {
    final uri = Uri.parse(baseUrl);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['amiibo'] ?? [];
      return list.map((e) => AmiiboModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load amiibo');
    }
  }
}

