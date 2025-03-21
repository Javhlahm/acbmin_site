import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/services/NuevoUsuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Paginanuevousuario extends StatefulWidget {
  const Paginanuevousuario({super.key});

  @override
  State<Paginanuevousuario> createState() => _PaginanuevousuarioState();
}

class _PaginanuevousuarioState extends State<Paginanuevousuario> {
  TextEditingController controladorNombre = new TextEditingController();
  TextEditingController controladorCorreo = new TextEditingController();
  TextEditingController controladorContrasena = new TextEditingController();
  var formKey = GlobalKey<FormState>();
  String? status;
  bool moduloUsuarios = false;
  bool moduloTallerAutos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "ACBMIN-USUARIOS",
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 35.0.dg),
        ),
        backgroundColor: Color(0xfff6c500),
        actions: [
          Text(
            usuarioGlobal!.nombre!,
            style: TextStyle(
                fontSize: 20.dg,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
          Padding(padding: EdgeInsets.only(right: 20.dg)),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0.dg),
                    child: Text(
                      "Nuevo Usuario",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 50.0.h, vertical: 20.h),
                    child: TextFormField(
                      controller: controladorNombre,
                      validator: (value) {
                        return value!.trim().isEmpty ? "Campo Vacío" : null;
                      },
                      decoration: InputDecoration(
                          labelText: "Nombre",
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.w),
                              borderSide: BorderSide())),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 50.0.h, vertical: 20.h),
                    child: TextFormField(
                      controller: controladorCorreo,
                      validator: (value) {
                        !value!.contains("@jalisco.gob.mx")
                            ? "Correo no Válido"
                            : null;
                      },
                      decoration: InputDecoration(
                          labelText: "Correo",
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.w),
                              borderSide: BorderSide())),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 50.0.h, vertical: 20.h),
                    child: TextFormField(
                      controller: controladorContrasena,
                      validator: (value) {
                        return value!.trim().isEmpty ? "Campo Vacío" : null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Contraseña",
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0.w),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.w),
                              borderSide: BorderSide())),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 60.0, vertical: 20),
                    child: DropdownButtonFormField(
                        validator: (value) {
                          return value!.trim().isEmpty ? "Campo Vacío" : null;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[200], // Fondo del campo
                        ),
                        hint: Text(
                          "Estatus",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0.w),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: "Activo",
                              child: Text(
                                "Activo",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0.w),
                              )),
                          DropdownMenuItem(
                              value: "Inactivo",
                              child: Text(
                                "Inactivo",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0.w),
                              )),
                        ],
                        onChanged: ((value) {
                          setState(() {
                            status = value;
                          });
                        })),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0.dg),
                    child: Text(
                      "Selección de Roles",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(20.0.dg),
                      child: ListTile(
                        leading: Checkbox(
                            value: moduloUsuarios,
                            onChanged: (value) {
                              setState(() {
                                moduloUsuarios = value!;
                              });
                            }),
                        title: Text(
                          "Administrador de Usuarios",
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.all(20.0.dg),
                      child: ListTile(
                        leading: Checkbox(
                            value: moduloTallerAutos,
                            onChanged: (value) {
                              setState(() {
                                moduloTallerAutos = value!;
                              });
                            }),
                        title: Text(
                          "Almacén de Taller de Autos",
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.all(20.0.dg),
                      child: Container(
                        height: 100.h,
                        width: 200.h,
                        child: ElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              Usuario usuario = new Usuario();
                              usuario.nombre = controladorNombre.text;
                              usuario.email = controladorCorreo.text;
                              usuario.contrasena = controladorContrasena.text;
                              usuario.status = status;
                              usuario.roles = [];
                              moduloUsuarios == true
                                  ? usuario.roles?.add("admin")
                                  : null;
                              moduloTallerAutos == true
                                  ? usuario.roles?.add("taller_autos")
                                  : null;
                              if (usuario.roles!.isEmpty) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          insetPadding: EdgeInsets.symmetric(
                                              horizontal: 0.1.sw,
                                              vertical: 0.33.sh),
                                          content: Container(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "SELECCIONE AL MENOS UN ROL DE USUARIO",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 0.025.sh,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.h)),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "OK",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 0.025.sh,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ));
                                return;
                              }
                              String respuesta = await NuevoUsuario(usuario);
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        insetPadding: EdgeInsets.symmetric(
                                            horizontal: 0.1.sw,
                                            vertical: 0.33.sh),
                                        content: Container(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                respuesta == "OK"
                                                    ? Text(
                                                        "USUARIO CREADO EXITOSAMENTE",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 0.025.sh,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    : Text(
                                                        "ERROR AL CREAR",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 0.025.sh,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.h)),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "OK",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 0.025.sh,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Guardar",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w)),
                                Icon(
                                  Icons.save,
                                  size: 20.dg,
                                )
                              ],
                            )),
                      ))
                ],
              )),
        ),
      ),
    );
  }
}
