import 'package:acbmin_site/PaginaMENU.dart';
import 'package:flutter/material.dart';

class Paginaprincipal extends StatelessWidget {
  const Paginaprincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 800
        ? PaginaprincipalEscritorio()
        : PaginaprincipalMovil();
  }
}

class PaginaprincipalEscritorio extends StatefulWidget {
  const PaginaprincipalEscritorio({super.key});

  @override
  State<PaginaprincipalEscritorio> createState() =>
      _PaginaprincipalEscritorioState();
}

class _PaginaprincipalEscritorioState extends State<PaginaprincipalEscritorio> {
  Color colorHoverHome = Colors.black;
  Color colorHoverIngreso = Colors.black;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
        body: Column(
      children: [
        Container(
          height: screenHeight * 0.10,
          width: screenWidth,
          color: Color(0xfff6c500),
          child: Padding(
            padding: EdgeInsets.all(screenHeight * 0.01),
            child: Row(
              children: [
                InkWell(
                  child: Icon(
                    size: screenHeight * 0.07,
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
                  width: screenWidth * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.005),
                  child: InkWell(
                    child: Text(
                      "Inicio",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorHoverHome,
                          fontSize: screenHeight * 0.05),
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
                    size: screenHeight * 0.07,
                    color: colorHoverIngreso,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.02,
                ),
                InkWell(
                  onTap: () {
                    mostrarDialogoIngreso(context);
                  },
                  onHover: (value) {
                    setState(() {
                      colorHoverIngreso = value ? Colors.red : Colors.black;
                    });
                  },
                  child: Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorHoverIngreso,
                      fontSize: screenHeight * 0.05,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.05,
                )
              ],
            ),
          ),
        ),
        Container(
            height: screenHeight * 0.90,
            width: double.infinity,
            child: Image.asset(
              "lib/assets/landing.png",
              fit: BoxFit.fill,
            ))
      ],
    ));
  }
}

mostrarDialogoIngreso(context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text(
              "Ingresar",
              textAlign: TextAlign.center,
            ),
            content: Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Form(
                        child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(hintText: "Usuario"),
                        ),
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(hintText: "Contraseña"),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Paginamenu()));
                            },
                            child: Text("Ingresar"))
                      ],
                    ))
                  ],
                ),
              ),
            ),
          ));
}

class PaginaprincipalMovil extends StatefulWidget {
  const PaginaprincipalMovil({super.key});

  @override
  State<PaginaprincipalMovil> createState() => _PaginaprincipalMovilState();
}

class _PaginaprincipalMovilState extends State<PaginaprincipalMovil> {
  Color? colorHomePresionado;
  Color? colorIngresoPresionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(15.0, 0.5, 15.0, 0.5),
            color: Color(0xfff6c500),
            height: MediaQuery.of(context).size.height * 0.10,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {});
                  },
                  onTapDown: (details) {
                    setState(() {
                      colorHomePresionado = Colors.red;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      colorHomePresionado = Colors.black;
                    });
                  },
                  child: Icon(
                    Icons.home,
                    size: MediaQuery.of(context).size.height * 0.07,
                    color: colorHomePresionado,
                  ),
                ),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () {
                    mostrarDialogoIngreso(context);
                  },
                  onTapDown: (details) {
                    setState(() {
                      colorIngresoPresionado = Colors.red;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      colorIngresoPresionado = Colors.black;
                    });
                  },
                  child: Icon(
                    Icons.login,
                    size: MediaQuery.of(context).size.height * 0.07,
                    color: colorIngresoPresionado,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.90,
            width: double.infinity,
            child: Image.asset(
              "lib/assets/landing.png",
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}
