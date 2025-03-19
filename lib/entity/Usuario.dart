class Usuario {
  int? id;
  String? nombre;
  String? email;
  String? contrasena;
  List<String>? roles;
  String? status;

  Usuario(
      {this.id,
      this.nombre,
      this.email,
      this.contrasena,
      this.roles,
      this.status});

  Usuario.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    email = json['email'];
    contrasena = json['contrasena'];
    roles = json['roles'].cast<String>();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nombre'] = this.nombre;
    data['email'] = this.email;
    data['contrasena'] = this.contrasena;
    data['roles'] = this.roles;
    data['status'] = this.status;
    return data;
  }
}
