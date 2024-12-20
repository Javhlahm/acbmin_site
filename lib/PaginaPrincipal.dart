import 'package:acbmin_site/PaginaCRUD.dart';
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
  num tamanoInicio = 1;
  num tamanoIngresar = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.10,
          color: Color(0xfff6c500),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                InkWell(
                  child: Icon(
                    size: 30.0 * tamanoInicio,
                    Icons.home,
                    color: Colors.red,
                  ),
                  onTap: () {
                    setState(() {});
                  },
                  onHover: (value) {
                    setState(() {
                      tamanoInicio = value == true ? 1.15 : 1;
                    });
                  },
                ),
                SizedBox(
                  width: 10.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: InkWell(
                    child: Text(
                      "Inicio",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 20.0 * tamanoInicio,
                      ),
                    ),
                    onTap: () {
                      setState(() {});
                    },
                    onHover: (value) {
                      setState(() {
                        tamanoInicio = value == true ? 1.15 : 1;
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
                      tamanoIngresar = value == true ? 1.15 : 1;
                    });
                  },
                  child: Icon(
                    Icons.login,
                    size: 30.0 * tamanoIngresar,
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                InkWell(
                  onTap: () {
                    mostrarDialogoIngreso(context);
                  },
                  onHover: (value) {
                    setState(() {
                      tamanoIngresar = value == true ? 1.15 : 1;
                    });
                  },
                  child: Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 20.0 * tamanoIngresar,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50.0,
                )
              ],
            ),
          ),
        ),
        Container(
            height: MediaQuery.of(context).size.height * 0.90,
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
                                      builder: (context) => Paginacrud()));
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
            padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.5),
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
                    size: 50.0,
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
                    size: 50.0,
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
