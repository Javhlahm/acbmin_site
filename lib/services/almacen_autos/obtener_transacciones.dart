import 'dart:convert';
import 'package:acbmin_site/entity/Transaccion.dart';
import 'package:http/http.dart' as http;

Future<List<Transaccion>> obtenerTransacciones() async {
  var url = Uri.parse(
      "http://89.117.149.126/acbmin/api/tallerautomotriz/almacen/transact");
//  var url = Uri.parse("http://localhost:8050/tallerautomotriz/almacen");

  var response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    List<Transaccion> transacciones =
        jsonData.map((json) => Transaccion.fromJson(json)).toList();
    for (var transaccion in transacciones) {
      transaccion.idTrans = transaccion.idTrans ?? 0;
      transaccion.tipo = transaccion.tipo ?? "-";
      transaccion.fecha = transaccion.fecha ?? "-";
      transaccion.idProd = transaccion.idProd ?? 0;
      transaccion.cantidad = transaccion.cantidad ?? 0;
      transaccion.placa = transaccion.placa ?? "-";
      transaccion.nombre = transaccion.nombre ?? "-";
      transaccion.categoria = transaccion.categoria ?? "-";
      transaccion.marca = transaccion.marca ?? "-";
      transaccion.modelo = transaccion.modelo ?? "-";
      transaccion.serie = transaccion.serie ?? "-";
      transaccion.descripcion = transaccion.descripcion ?? "-";
      transaccion.modeloAuto = transaccion.modeloAuto ?? "-";
      transaccion.valeAlmacen = transaccion.valeAlmacen ?? "-";
      transaccion.requerimiento = transaccion.requerimiento ?? "-";
      transaccion.aging = transaccion.aging ?? "-";
      transaccion.localidad = transaccion.localidad ?? "-";
      transaccion.notas = transaccion.notas ?? "-";
    }
    return transacciones;
  } else {
    throw Exception('Error al obtener Transacciones: ${response.statusCode}');
  }
}
