import 'package:acbmin_site/PaginaMENU.dart';
import 'package:acbmin_site/entity/Usuario.dart';
import 'package:acbmin_site/entity/UsuarioGlobal.dart';
import 'package:acbmin_site/security/auth_service.dart';
import 'package:acbmin_site/services/usuarios/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:acbmin_site/services/usuarios/ObtenerUsuarioEmail.dart';

class Paginaprincipal extends StatelessWidget {
  const Paginaprincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? PaginaPrincipalHorizontal()
        : PaginaPrincipalHorizontal();
  }
}

class PaginaPrincipalHorizontal extends StatefulWidget {
  const PaginaPrincipalHorizontal({super.key});

  @override
  State<PaginaPrincipalHorizontal> createState() =>
      _PaginaprincipalEscritorioState();
}

class _PaginaprincipalEscritorioState extends State<PaginaPrincipalHorizontal> {
  Color colorHoverHome = Colors.black;
  Color colorHoverIngreso = Colors.black;

  @override
  Widget build(BuildContext context) {
    var landscape =
        ScreenUtil().orientation == Orientation.landscape ? true : false;

    return Scaffold(
        body: Column(
      children: [
        Container(
          height: 0.10.sh,
          width: 1.sw,
          color: Color(0xfff6c500),
          child: Padding(
            padding: EdgeInsets.all(0.01.sh),
            child: Row(
              children: [
                InkWell(
                  child: Icon(
                    size: 0.07.sh,
                    Icons.home,
                    color: colorHoverHome,
                  ),
                  onTap: () {
                    setState(() {});
                  },
                  onHover: (value) {
                    setState(() {
                      colorHoverHome = value ? Colors.red : Colors.black;
                    });
                  },
                ),
                SizedBox(
                  width: 0.02.sw,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.005.sh),
                  child: landscape
                      ? InkWell(
                          child: Text(
                            "Inicio",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorHoverHome,
                                fontSize: 30.dg),
                          ),
                          onTap: () {
                            setState(() {});
                          },
                          onHover: (value) {
                            setState(() {
                              colorHoverHome =
                                  value ? Colors.red : Colors.black;
                            });
                          },
                        )
                      : null,
                ),
                Expanded(child: Container()),
                InkWell(
                  onTap: () {
                    // Pasamos el context del Scaffold
                    mostrarDialogoIngreso(context);
                  },
                  onHover: (value) {
                    setState(() {
                      colorHoverIngreso = value ? Colors.red : Colors.black;
                    });
                  },
                  child: Icon(
                    Icons.login,
                    size: 0.07.sh,
                    color: colorHoverIngreso,
                  ),
                ),
                SizedBox(
                  width: 0.02.sw,
                ),
                landscape
                    ? InkWell(
                        onTap: () {
                          // Pasamos el context del Scaffold
                          mostrarDialogoIngreso(context);
                        },
                        onHover: (value) {
                          setState(() {
                            colorHoverIngreso =
                                value ? Colors.red : Colors.black;
                          });
                        },
                        child: Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorHoverIngreso,
                            fontSize: 30.dg,
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  width: 0.05.sw,
                )
              ],
            ),
          ),
        ),
        Container(
            height: 0.90.sh,
            width: 1.sw,
            child: Image.asset("lib/assets/landing.png",
                fit: ScreenUtil().orientation == Orientation.landscape
                    ? BoxFit.fill
                    : BoxFit.fitHeight))
      ],
    ));
  }
}

// --- LÓGICA DE INGRESO MODIFICADA ---
mostrarDialogoIngreso(context) {
  TextEditingController correoController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
            // Usamos dialogContext para el diálogo
            scrollable: true,
            insetPadding:
                EdgeInsets.symmetric(horizontal: 0.1.sw, vertical: 0.1.sh),
            title: Text("Ingresar",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 0.03.sh, fontWeight: FontWeight.bold)),
            content: Form(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 0.09.sh,
                  width: 0.3.sw,
                  child: TextFormField(
                    controller: correoController,
                    style: TextStyle(fontSize: 0.04.sh),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.h),
                        hintText: "Usuario",
                        hintStyle: TextStyle(fontSize: 0.02.sh)),
                  ),
                ),
                Container(
                  height: 0.09.sh,
                  width: 0.3.sw,
                  child: TextFormField(
                    controller: contrasenaController,
                    style: TextStyle(fontSize: 0.04.sh),
                    obscureText: true,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.h),
                        hintText: "Contraseña",
                        hintStyle: TextStyle(fontSize: 0.02.sh)),
                  ),
                ),
                SizedBox(
                  height: 0.02.sh,
                ),
                ElevatedButton(
                    onPressed: () async {
                      // 1. Obtenemos el token.
                      String? token = await Login(
                          correoController.text, contrasenaController.text);

                      // 2. Verificamos si el token es nulo (credenciales incorrectas)
                      if (token == null) {
                        // Usamos el 'context' del build principal para mostrar el SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Usuario o contraseña incorrectos.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Detenemos la ejecución
                      }

                      // 3. Si el token SÍ existe, continuamos
                      await authService
                          .saveToken(token); // Ya no se necesita '!'

                      try {
                        // 4. Obtenemos datos del usuario
                        Usuario usuario =
                            await obtenerUsuarioEmail(correoController.text);
                        usuarioGlobal =
                            usuario; // Guardamos el usuario globalmente.

                        // 5. Navegamos al menú principal
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Paginamenu()));
                      } catch (e) {
                        // Manejo de error si falla la obtención de datos del usuario
                        print("Error al obtener detalles del usuario: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error al obtener datos del usuario.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text("Ingresar",
                        style: TextStyle(
                            fontSize: 0.025.sh, fontWeight: FontWeight.bold)))
              ],
            )),
          ));
}
