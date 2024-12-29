class Item {
  int? idProd;
  String? nombre;
  String? categoria;
  String? marca;
  String? modelo;
  String? serie;
  String? descripcion;
  int? cantidad;
  String? modeloAuto;
  String? ultMovimiento;
  String? notas;

  Item(
      {this.idProd,
      this.nombre,
      this.categoria,
      this.marca,
      this.modelo,
      this.serie,
      this.descripcion,
      this.cantidad,
      this.modeloAuto,
      this.ultMovimiento,
      this.notas});

  Item.fromJson(Map<String, dynamic> json) {
    idProd = json['id_prod'];
    nombre = json['nombre'];
    categoria = json['categoria'];
    marca = json['marca'];
    modelo = json['modelo'];
    serie = json['serie'];
    descripcion = json['descripcion'];
    cantidad = json['cantidad'];
    modeloAuto = json['modeloAuto'];
    ultMovimiento = json['ultMovimiento'];
    notas = json['notas'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_prod'] = this.idProd;
    data['nombre'] = this.nombre;
    data['categoria'] = this.categoria;
    data['marca'] = this.marca;
    data['modelo'] = this.modelo;
    data['serie'] = this.serie;
    data['descripcion'] = this.descripcion;
    data['cantidad'] = this.cantidad;
    data['modeloAuto'] = this.modeloAuto;
    data['ultMovimiento'] = this.ultMovimiento;
    data['notas'] = this.notas;
    return data;
  }
}
