import 'package:flutter/material.dart';

class Paginacrud extends StatelessWidget {
  const Paginacrud({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 800
        ? PaginacrudEscritorio()
        : PaginacrudMovil();
  }
}

class PaginacrudEscritorio extends StatefulWidget {
  const PaginacrudEscritorio({super.key});

  @override
  State<PaginacrudEscritorio> createState() => _PaginacrudEscritorioState();
}

class _PaginacrudEscritorioState extends State<PaginacrudEscritorio> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PaginacrudMovil extends StatefulWidget {
  const PaginacrudMovil({super.key});

  @override
  State<PaginacrudMovil> createState() => _PaginacrudMovilState();
}

class _PaginacrudMovilState extends State<PaginacrudMovil> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
