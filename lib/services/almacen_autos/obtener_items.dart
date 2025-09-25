import 'dart:convert';
import 'package:acbmin_site/entity/Item.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

Future<List<Item>> obtenerItems() async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // El backend espera este formato.
  };
  // var url =
  //    Uri.parse("http://89.117.149.126/acbmin/api/tallerautomotriz/almacen");
  var url = Uri.parse(
      "https://acbmin.lamasoft.org/api/autoalmacen/tallerautomotriz/almacen");
//  var url = Uri.parse("http://localhost:8050/tallerautomotriz/almacen");
  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    List<Item> items = jsonData.map((json) => Item.fromJson(json)).toList();
    for (var item in items) {
      item.aging = item.aging ?? 0;
      item.cantidad = item.cantidad ?? 0;
      item.categoria = item.categoria ?? "-";
      item.descripcion = item.descripcion ?? "-";
      item.idProd = item.idProd ?? 0;
      item.localidad = item.localidad ?? "-";
      item.marca = item.marca ?? "-";
      item.modelo = item.modelo ?? "-";
      item.modeloAuto = item.modeloAuto ?? "-";
      item.nombre = item.nombre ?? "-";
      item.notas = item.notas ?? "-";
      item.serie = item.serie ?? "-";
      item.ultMovimiento = item.ultMovimiento ?? "-";
    }
    return items;
  } else {
    throw Exception('Error al obtener productos: ${response.statusCode}');
  }
}
