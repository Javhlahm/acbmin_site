import 'package:acbmin_site/PaginaMENU.dart';
import 'package:acbmin_site/services/usuarios/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

mostrarDialogoIngreso(context) {
  TextEditingController correoController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                      String respuesta = await Login(
                          correoController.text, contrasenaController.text);

                      if (respuesta != "OK") {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  insetPadding: EdgeInsets.symmetric(
                                      horizontal: 0.1.sw, vertical: 0.33.sh),
                                  content: Container(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "NO AUTORIZADO",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 0.025.sh,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.h)),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "OK",
                                                textAlign: TextAlign.center,
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
                        return;
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Paginamenu(
                                    usuarioLogeado: correoController.text,
                                  )));
                    },
                    child: Text("Ingresar",
                        style: TextStyle(
                            fontSize: 0.025.sh, fontWeight: FontWeight.bold)))
              ],
            )),
          ));
}
