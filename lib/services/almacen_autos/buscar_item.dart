import 'dart:convert';
import 'package:acbmin_site/entity/Item.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:http/http.dart' as http;

buscarItem(String serie) async {
  final token = await authService.getToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // El backend espera este formato.
  };
  // var url = Uri.parse(
  //  "http://89.117.149.126/acbmin/api/tallerautomotriz/almacen/" + serie);
  var url = Uri.parse(
      "https://acbmin.lamasoft.org/api/autoalmacen/tallerautomotriz/almacen/" +
          serie);
//  var url = Uri.parse("http://localhost:8050/tallerautomotriz/almacen");
  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    return Item.fromJson(jsonData);
  } else {
    return null;
  }
}
