import 'dart:convert';
import 'package:acbmin_site/entity/Transaccion.dart';
import 'package:http/http.dart' as http;

SalidaTransaccion(Transaccion transaccion) async {
  // var url = Uri.parse(
  //   "http://89.117.149.126/acbmin/api/tallerautomotriz/almacen/transact/salida");
  var url = Uri.parse(
      "https://acbmin.lamasoft.org/api/autoalmacen/tallerautomotriz/almacen/transact/salida");
//  var url = Uri.parse("http://localhost:8050/tallerautomotriz/almacen");
  Map<String, dynamic> transaccionJson = transaccion.toJson();

  var response = await http.post(
    url,
    headers: {
      'Content-Type':
          'application/json', // Especificamos que estamos enviando JSON
    },
    body: json.encode(transaccionJson),
  );

  if (response.statusCode == 200) {
    //   Map<String, dynamic> jsonData = json.decode(response.body);
    // List<Map<String, dynamic>> jsonData = json.decode(response.body);
    //var jsonData = json.decode(response.body);
    return "OK";
  } else {
    //throw Exception('Error al obtener productos: ${response.statusCode}');
    return "ERROR";
  }
}
