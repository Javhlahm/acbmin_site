import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/services/usuarios/EditarUsuario.dart';
import 'package:acbmin_site/services/usuarios/ObtenerUsuarioEmail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Paginaeditarusuario extends StatefulWidget {
  String usuarioSeleccionado;
  Paginaeditarusuario({super.key, required this.usuarioSeleccionado});

  @override
  State<Paginaeditarusuario> createState() => _PaginaeditarusuarioState();
}

class _PaginaeditarusuarioState extends State<Paginaeditarusuario> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  bool admin = false;
  bool taller_autos = false;
  bool resguardos_internos = false; // <-- AÑADIDO
  bool bajas_bienes = false; // <-- AÑADIDO
  bool datosCargados = false;
  late Future<Usuario> usuario;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usuario = obtenerUsuarioEmail(widget.usuarioSeleccionado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ACBMIN-EDITAR USUARIO",
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 35.0.dg),
        ),
        backgroundColor: Color(0xfff6c500),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 0.5.sw,
            height: 0.8.sh,
            child: FutureBuilder(
                future: usuario,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    if (!datosCargados) {
                      nombreController.text = snapshot.data!.nombre!;
                      correoController.text = snapshot.data!.email!;
                      for (var rol in snapshot.data!.roles!) {
                        if (rol == "admin") {
                          admin = true;
                        }
                        if (rol == "taller_autos") {
                          taller_autos = true;
                        }
                        // --- INICIO DE CÓDIGO AÑADIDO ---
                        if (rol == "resguardos_internos") {
                          resguardos_internos = true;
                        }
                        if (rol == "bajas_bienes") {
                          bajas_bienes = true;
                        }
                        // --- FIN DE CÓDIGO AÑADIDO ---
                      }
                      datosCargados = true;
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: nombreController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.h),
                              hintText: "Nombre Completo",
                              hintStyle: TextStyle(fontSize: 0.02.sh)),
                        ),
                        TextFormField(
                          controller: correoController,
                          readOnly: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.h),
                              hintText: "Correo",
                              hintStyle: TextStyle(fontSize: 0.02.sh)),
                        ),
                        TextFormField(
                          controller: contrasenaController,
                          obscureText: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.h),
                              hintText: "Contraseña",
                              hintStyle: TextStyle(fontSize: 0.02.sh)),
                        ),
                        Padding(padding: EdgeInsets.only(top: 20.dg)),
                        Text("ROLES:"),
                        CheckboxListTile(
                          title: Text("Administrador"),
                          value: admin,
                          onChanged: (newValue) {
                            setState(() {
                              admin = newValue!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Taller de Autos"),
                          value: taller_autos,
                          onChanged: (newValue) {
                            setState(() {
                              taller_autos = newValue!;
                            });
                          },
                        ),
                        // --- INICIO DE CÓDIGO AÑADIDO ---
                        CheckboxListTile(
                          title: Text("Resguardos Internos"),
                          value: resguardos_internos,
                          onChanged: (newValue) {
                            setState(() {
                              resguardos_internos = newValue!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Bajas de Bienes"),
                          value: bajas_bienes,
                          onChanged: (newValue) {
                            setState(() {
                              bajas_bienes = newValue!;
                            });
                          },
                        ),
                        // --- FIN DE CÓDIGO AÑADIDO ---
                        ElevatedButton(
                            onPressed: () async {
                              List<String> roles = [];
                              if (admin) {
                                roles.add("admin");
                              }
                              if (taller_autos) {
                                roles.add("taller_autos");
                              }
                              // --- INICIO DE CÓDIGO AÑADIDO ---
                              if (resguardos_internos) {
                                roles.add("resguardos_internos");
                              }
                              if (bajas_bienes) {
                                roles.add("bajas_bienes");
                              }
                              // --- FIN DE CÓDIGO AÑADIDO ---

                              Usuario usuario = snapshot.data!;
                              usuario.nombre = nombreController.text;
                              usuario.email = correoController.text;
                              usuario.contrasena = contrasenaController.text;
                              usuario.roles = roles;
                              usuario.status = "ACTIVO";

                              await EditarUsuario(usuario);
                              Navigator.pop(context);
                            },
                            child: Text("Actualizar"))
                      ],
                    );
                  } else {
                    return Center(child: Text("No hay datos."));
                  }
                }),
          ),
        ),
      ),
    );
  }
}
