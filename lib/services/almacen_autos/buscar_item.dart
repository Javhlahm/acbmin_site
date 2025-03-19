import 'dart:convert';
import 'package:acbmin_site/entity/Item.dart';
import 'package:http/http.dart' as http;

buscarItem(String serie) async {
  var url = Uri.parse(
      "http://89.117.149.126/acbmin/api/tallerautomotriz/almacen/" + serie);
//  var url = Uri.parse("http://localhost:8050/tallerautomotriz/almacen");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    return Item.fromJson(jsonData);
  } else {
    return null;
  }
}
