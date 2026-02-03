import 'dart:convert';
import 'package:imccalc/models/imc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = 'historico_imc';

  Future<void> salvarLista(List<IMC> lista) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = lista.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<List<IMC>> buscarLista() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_key);

    if (jsonList == null) return [];

    return jsonList.map((item) => IMC.fromJson(jsonDecode(item))).toList();
  }
}