import 'dart:convert';

import 'package:acbmin_site/entity/Usuario.dart';
import 'package:http/http.dart' as http;

Future<List<Usuario>> obtenerUsuarios() async {
  // var url = Uri.parse("http://89.117.149.126/acbmin/api/users/usuarios");
  var url = Uri.parse("https://acbmin.lamasoft.org/api/users/usuarios");
//  var url = Uri.parse("http://localhost:8050/tallerautomotriz/almacen");

  var response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    List<Usuario> usuarios =
        jsonData.map((json) => Usuario.fromJson(json)).toList();
    for (var usuario in usuarios) {
      usuario.nombre = usuario.nombre ?? "-";
      usuario.id = usuario.id ?? 0;
      usuario.contrasena = usuario.contrasena ?? "-";
      usuario.email = usuario.email ?? "-";
      usuario.roles = usuario.roles ?? [];
      usuario.status = usuario.status ?? "-";
    }
    return usuarios;
  } else {
    throw Exception('Error al obtener Usuarios: ${response.statusCode}');
  }
}
