import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Paginasalidaitem extends StatefulWidget {
  final String? serie;
  const Paginasalidaitem({super.key, this.serie});

  @override
  State<Paginasalidaitem> createState() => _PaginasalidaitemState();
}

class _PaginasalidaitemState extends State<Paginasalidaitem> {
  Color colorHoverRegresar = Colors.black;

  @override
  Widget build(BuildContext context) {
    var landscape =
        ScreenUtil().orientation == Orientation.landscape ? true : false;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(15.0, 7.0, 25.0, 7.0).w,
            height: 0.10.sh,
            color: Color(0xfff6c500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  onHover: (value) {
                    setState(() {
                      colorHoverRegresar =
                          value == true ? Colors.red : Colors.black;
                    });
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: colorHoverRegresar,
                    size: landscape ? 0.07.sh : 0.03.sh,
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 0.9.sh,
            width: 1.sw,
            child: Form(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 5.h)),
                  Text(
                    "Salida de Material",
                    style:
                        TextStyle(fontSize: 20.dg, fontWeight: FontWeight.bold),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.h),
                    child: TextFormField(
                      validator: (value) {},
                      decoration: InputDecoration(
                          labelText: "Número de Serie",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.w),
                              borderSide: BorderSide())),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.h),
                    child: TextFormField(
                      validator: (value) {},
                      decoration: InputDecoration(
                          labelText: "Nombre",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.w),
                              borderSide: BorderSide())),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.h),
                    child: TextFormField(
                      validator: (value) {},
                      decoration: InputDecoration(
                          labelText: "Descripción",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.w),
                              borderSide: BorderSide())),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.h),
                    child: TextFormField(
                      validator: (value) {},
                      decoration: InputDecoration(
                          labelText: "Notas",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.w),
                              borderSide: BorderSide())),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.h),
                    child: TextFormField(
                      validator: (value) {},
                      decoration: InputDecoration(
                          labelText: "Cantidad",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.w),
                              borderSide: BorderSide())),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.h),
                    child: TextFormField(
                      validator: (value) {},
                      decoration: InputDecoration(
                          labelText: "Placa",
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.w),
                              borderSide: BorderSide())),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                  Container(
                    height: 100.h,
                    width: 200.h,
                    child: ElevatedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Guardar",
                              style: TextStyle(
                                  fontSize: 20.dg, fontWeight: FontWeight.bold),
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
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 10.h)),
                ],
              ),
            )),
          )
        ],
      ),
    );
  }
}
