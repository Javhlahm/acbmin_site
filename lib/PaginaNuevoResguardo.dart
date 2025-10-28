import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Para diseño adaptable
import 'package:intl/intl.dart'; // Para formatear fecha si es necesario

// Importar entidad Resguardo y UsuarioGlobal
import 'entity/Resguardo.dart'; // Asegúrate que la ruta sea correcta
import 'entity/UsuarioGlobal.dart'; // Para obtener el nombre del capturista
// Importar el servicio para crear resguardos en la API
import 'services/resguardos/crear_resguardo.dart'; // Asegúrate que la ruta sea correcta

class PaginaNuevoResguardo extends StatefulWidget {
  const PaginaNuevoResguardo({super.key});

  @override
  State<PaginaNuevoResguardo> createState() => _PaginaNuevoResguardoState();
}

class _PaginaNuevoResguardoState extends State<PaginaNuevoResguardo> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _numeroInventarioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _areaEntregaController = TextEditingController();
  final _nombreEntregaController = TextEditingController();
  final _rfcEntregaController = TextEditingController();
  final _areaRecibeController = TextEditingController();
  final _nombreRecibeController = TextEditingController();
  final _rfcRecibeController = TextEditingController();
  final _observacionesController = TextEditingController();

  // Variable de estado para el tipo de resguardo seleccionado
  String _tipoResguardoSeleccionado = 'Traspaso de resguardo';
  bool _camposEntregaHabilitados = true;
  bool _isSaving = false; // Para deshabilitar botón mientras guarda

  @override
  void dispose() {
    // Limpiar controladores al destruir el widget
    _numeroInventarioController.dispose();
    _descripcionController.dispose();
    _areaEntregaController.dispose();
    _nombreEntregaController.dispose();
    _rfcEntregaController.dispose();
    _areaRecibeController.dispose();
    _nombreRecibeController.dispose();
    _rfcRecibeController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  // Cambia el tipo de resguardo y habilita/deshabilita campos de entrega
  void _cambiarTipoResguardo(String? valor) {
    if (valor != null) {
      setState(() {
        _tipoResguardoSeleccionado = valor;
        _camposEntregaHabilitados = (valor == 'Traspaso de resguardo');
        // Limpiar campos si se deshabilita
        if (!_camposEntregaHabilitados) {
          _areaEntregaController.clear();
          _nombreEntregaController.clear();
          _rfcEntregaController.clear();
        }
      });
    }
  }

  // Función modificada para llamar a la API
  void _crearResguardo() async {
    // Validar el formulario y asegurarse que no se esté guardando ya
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() {
        _isSaving = true;
      }); // Deshabilita botón y muestra indicador

      final String? nombreCapturista = usuarioGlobal?.nombre;

      // Crear el objeto Resguardo localmente (sin folio asignado aún)
      final nuevoResguardo = Resguardo(
        folio: 0, // El folio lo asignará el backend, ponemos 0 temporalmente
        fechaAutorizado: null,
        estatus: 'Pendiente', // Estatus inicial por defecto
        tipoResguardo: _tipoResguardoSeleccionado,
        numeroInventario: _numeroInventarioController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        areaEntrega: _camposEntregaHabilitados
            ? _areaEntregaController.text.trim()
            : 'N/A',
        nombreEntrega: _camposEntregaHabilitados
            ? _nombreEntregaController.text.trim()
            : 'N/A',
        rfcEntrega: _camposEntregaHabilitados
            ? _rfcEntregaController.text.trim()
            : 'N/A',
        areaRecibe: _areaRecibeController.text.trim(),
        nombreRecibe: _nombreRecibeController.text.trim(),
        rfcRecibe: _rfcRecibeController.text.trim(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? null // Si está vacío, manda null
            : _observacionesController.text.trim(),
        capturadoPor: nombreCapturista ?? 'Desconocido', // Asigna el capturista
      );

      // Llamar al servicio para crear el resguardo en la API
      Resguardo? resguardoCreado = await crearResguardo(nuevoResguardo);

      // Verificar si el widget sigue montado antes de actualizar estado o navegar
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      }); // Rehabilita botón

      if (resguardoCreado != null) {
        // Si la API devuelve el resguardo creado (con folio), lo pasamos de vuelta a PaginaResguardos
        Navigator.pop(context, resguardoCreado);
      } else {
        // Si hubo un error en la API, mostrar mensaje
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al crear el resguardo. Intente de nuevo.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // Widget helper para crear títulos de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nuevo Resguardo Interno",
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 25.0.dg),
        ),
        backgroundColor: Color(0xfff6c500),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          // Si está guardando, no permitir salir fácilmente
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: 20.h, horizontal: 10.w), // Margen exterior
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.w), // Ancho máximo
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                child: Padding(
                  padding: EdgeInsets.all(25.w), // Padding interno
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Tipo de Resguardo'),
                        // Radio buttons para seleccionar el tipo
                        RadioListTile<String>(
                          title: const Text('Traspaso de resguardo'),
                          value: 'Traspaso de resguardo',
                          groupValue: _tipoResguardoSeleccionado,
                          onChanged: _isSaving
                              ? null
                              : _cambiarTipoResguardo, // Deshabilitar si está guardando
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: const Text('Nueva adquisición'),
                          value: 'Nueva adquisición',
                          groupValue: _tipoResguardoSeleccionado,
                          onChanged: _isSaving ? null : _cambiarTipoResguardo,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                        ),
                        Divider(height: 20.h, thickness: 1),

                        _buildSectionTitle('Datos del Bien'),
                        // Campo Número de Inventario
                        TextFormField(
                          controller: _numeroInventarioController,
                          decoration: const InputDecoration(
                              labelText: 'Número de Inventario'),
                          enabled: !_isSaving, // Deshabilitar si está guardando
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        // Campo Descripción
                        TextFormField(
                          controller: _descripcionController,
                          decoration:
                              const InputDecoration(labelText: 'Descripción'),
                          maxLines: 2,
                          enabled: !_isSaving,
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        Divider(height: 20.h, thickness: 1),

                        _buildSectionTitle('Datos de Quien Entrega'),
                        // Campo Área Entrega
                        TextFormField(
                          controller: _areaEntregaController,
                          decoration: InputDecoration(
                              labelText: 'Área que Entrega',
                              filled:
                                  !_camposEntregaHabilitados, // Fondo gris si está deshabilitado por tipo
                              fillColor: Colors.grey[200]),
                          enabled: _camposEntregaHabilitados &&
                              !_isSaving, // Habilitado solo si es traspaso y no guardando
                          validator: (value) => (_camposEntregaHabilitados &&
                                  (value?.trim().isEmpty ?? true))
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        // Campo Nombre Entrega
                        TextFormField(
                          controller: _nombreEntregaController,
                          decoration: InputDecoration(
                              labelText: 'Nombre de quien Entrega',
                              filled: !_camposEntregaHabilitados,
                              fillColor: Colors.grey[200]),
                          enabled: _camposEntregaHabilitados && !_isSaving,
                          validator: (value) => (_camposEntregaHabilitados &&
                                  (value?.trim().isEmpty ?? true))
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        // Campo RFC Entrega
                        TextFormField(
                          controller: _rfcEntregaController,
                          decoration: InputDecoration(
                              labelText: 'RFC de quien Entrega',
                              filled: !_camposEntregaHabilitados,
                              fillColor: Colors.grey[200]),
                          enabled: _camposEntregaHabilitados && !_isSaving,
                          validator: (value) => (_camposEntregaHabilitados &&
                                  (value?.trim().isEmpty ?? true))
                              ? 'Campo requerido'
                              : null,
                        ),
                        Divider(height: 20.h, thickness: 1),

                        _buildSectionTitle('Datos de Quien Recibe'),
                        // Campo Área Recibe
                        TextFormField(
                          controller: _areaRecibeController,
                          decoration: const InputDecoration(
                              labelText: 'Área que Recibe'),
                          enabled: !_isSaving,
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        // Campo Nombre Recibe
                        TextFormField(
                          controller: _nombreRecibeController,
                          decoration: const InputDecoration(
                              labelText: 'Nombre de quien Recibe'),
                          enabled: !_isSaving,
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        SizedBox(height: 12.h),
                        // Campo RFC Recibe
                        TextFormField(
                          controller: _rfcRecibeController,
                          decoration: const InputDecoration(
                              labelText: 'RFC de quien Recibe'),
                          enabled: !_isSaving,
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Campo requerido'
                              : null,
                        ),
                        Divider(height: 20.h, thickness: 1),

                        _buildSectionTitle('Observaciones (Opcional)'),
                        // Campo Observaciones
                        TextFormField(
                          controller: _observacionesController,
                          decoration: const InputDecoration(
                            labelText: 'Observaciones',
                            hintText: 'Detalles adicionales...',
                          ),
                          maxLines: 3,
                          enabled: !_isSaving,
                          // No necesita validador porque es opcional
                        ),
                        SizedBox(height: 30.h),

                        // Botón de Crear y posible indicador de progreso
                        Center(
                          child: Column(
                            // Usar Column para poner el indicador debajo
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(Icons.save),
                                label: const Text('Crear Resguardo'),
                                // Deshabilita el botón si _isSaving es true
                                onPressed: _isSaving ? null : _crearResguardo,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15.h, horizontal: 30.w),
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                  textStyle: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                  // Cambiar apariencia si está deshabilitado
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  disabledForegroundColor: Colors.grey.shade500,
                                ),
                              ),
                              // Muestra un indicador de progreso si _isSaving es true
                              if (_isSaving)
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
