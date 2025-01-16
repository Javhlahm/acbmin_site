class Transaccion {
  int? idTrans;
  String? tipo;
  String? fecha;
  int? idProd;
  int? cantidad;
  String? placa;
  String? nombre;
  String? categoria;
  String? marca;
  String? modelo;
  String? serie;
  String? descripcion;
  String? modeloAuto;
  String? valeAlmacen;
  String? requerimiento;
  String? aging;
  String? localidad;
  String? notas;

  Transaccion(
      {this.idTrans,
      this.tipo,
      this.fecha,
      this.idProd,
      this.cantidad,
      this.placa,
      this.nombre,
      this.categoria,
      this.marca,
      this.modelo,
      this.serie,
      this.descripcion,
      this.modeloAuto,
      this.valeAlmacen,
      this.requerimiento,
      this.aging,
      this.localidad,
      this.notas});

  Transaccion.fromJson(Map<String, dynamic> json) {
    idTrans = json['id_trans'];
    tipo = json['tipo'];
    fecha = json['fecha'];
    idProd = json['id_prod'];
    cantidad = json['cantidad'];
    placa = json['placa'];
    nombre = json['nombre'];
    categoria = json['categoria'];
    marca = json['marca'];
    modelo = json['modelo'];
    serie = json['serie'];
    descripcion = json['descripcion'];
    modeloAuto = json['modeloAuto'];
    valeAlmacen = json['valeSalida'];
    requerimiento = json["requerimientoONotas"];
    aging = json["aging"];
    localidad = json["localidad"];
    notas = json["notas"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_trans'] = this.idTrans;
    data['tipo'] = this.tipo;
    data['fecha'] = this.fecha;
    data['id_prod'] = this.idProd;
    data['cantidad'] = this.cantidad;
    data['placa'] = this.placa;
    data['nombre'] = this.nombre;
    data['categoria'] = this.categoria;
    data['marca'] = this.marca;
    data['modelo'] = this.modelo;
    data['serie'] = this.serie;
    data['descripcion'] = this.descripcion;
    data['modeloAuto'] = this.modeloAuto;
    data['valeSalida'] = this.valeAlmacen;
    data['requerimientoONotas'] = this.requerimiento;
    data['aging'] = this.aging;
    data['localidad'] = this.localidad;
    data['notas'] = this.notas;
    return data;
  }
}
