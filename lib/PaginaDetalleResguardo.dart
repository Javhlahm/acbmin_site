import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../entity/Resguardo.dart';
import '../entity/UsuarioGlobal.dart'; // Importar para verificar rol y obtener nombre

// Enum para indicar la acción realizada al regresar
enum DetalleResguardoResultAction { updated, deleted, none }

// Clase para empaquetar el resultado
class DetalleResguardoResult {
  final DetalleResguardoResultAction action;
  final Resguardo? resguardo; // El resguardo actualizado (si aplica)

  DetalleResguardoResult(this.action, {this.resguardo});
}

class PaginaDetalleResguardo extends StatefulWidget {
  final Resguardo resguardoInicial;

  const PaginaDetalleResguardo({super.key, required this.resguardoInicial});

  @override
  State<PaginaDetalleResguardo> createState() => _PaginaDetalleResguardoState();
}

class _PaginaDetalleResguardoState extends State<PaginaDetalleResguardo> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false; // Controla si los campos están habilitados
  bool _isAdmin = false; // Verifica si el usuario actual es admin

  // Controladores para los campos editables
  late TextEditingController _numeroInventarioController;
  late TextEditingController _descripcionController;
  late TextEditingController _areaEntregaController;
  late TextEditingController _nombreEntregaController;
  late TextEditingController _rfcEntregaController;
  late TextEditingController _areaRecibeController;
  late TextEditingController _nombreRecibeController;
  late TextEditingController _rfcRecibeController;
  late TextEditingController _observacionesController;

  String _tipoResguardoSeleccionado = 'Traspaso de resguardo';
  bool _camposEntregaHabilitados = true;
  late Resguardo _resguardoActual; // Para mantener el estado actual

  @override
  void initState() {
    super.initState();
    _resguardoActual = widget.resguardoInicial.copyWith(); // Copia inicial
    _isAdmin = usuarioGlobal?.roles?.contains('admin') ?? false;

    // Inicializar controladores con los datos del resguardo
    _numeroInventarioController =
        TextEditingController(text: _resguardoActual.numeroInventario);
    _descripcionController =
        TextEditingController(text: _resguardoActual.descripcion);
    _areaEntregaController =
        TextEditingController(text: _resguardoActual.areaEntrega);
    _nombreEntregaController =
        TextEditingController(text: _resguardoActual.nombreEntrega);
    _rfcEntregaController =
        TextEditingController(text: _resguardoActual.rfcEntrega);
    _areaRecibeController =
        TextEditingController(text: _resguardoActual.areaRecibe);
    _nombreRecibeController =
        TextEditingController(text: _resguardoActual.nombreRecibe);
    _rfcRecibeController =
        TextEditingController(text: _resguardoActual.rfcRecibe);
    _observacionesController =
        TextEditingController(text: _resguardoActual.observaciones ?? '');
    _tipoResguardoSeleccionado = _resguardoActual.tipoResguardo;
    _camposEntregaHabilitados =
        (_tipoResguardoSeleccionado == 'Traspaso de resguardo');
  }

  @override
  void dispose() {
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

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      // Si salimos de edición, restauramos los valores originales por si hubo cambios no guardados
      if (!_isEditing) {
        _resguardoActual =
            widget.resguardoInicial.copyWith(); // Restaura desde el original
        _actualizarControladores(); // Actualiza los campos visuales
        _tipoResguardoSeleccionado = _resguardoActual.tipoResguardo;
        _camposEntregaHabilitados =
            (_tipoResguardoSeleccionado == 'Traspaso de resguardo');
      }
    });
  }

  // Helper para actualizar todos los controladores desde _resguardoActual
  void _actualizarControladores() {
    _numeroInventarioController.text = _resguardoActual.numeroInventario;
    _descripcionController.text = _resguardoActual.descripcion;
    _areaEntregaController.text = _resguardoActual.areaEntrega;
    _nombreEntregaController.text = _resguardoActual.nombreEntrega;
    _rfcEntregaController.text = _resguardoActual.rfcEntrega;
    _areaRecibeController.text = _resguardoActual.areaRecibe;
    _nombreRecibeController.text = _resguardoActual.nombreRecibe;
    _rfcRecibeController.text = _resguardoActual.rfcRecibe;
    _observacionesController.text = _resguardoActual.observaciones ?? '';
    // Tipo y habilitación ya se manejan en _cambiarTipoResguardo
  }

  void _cambiarTipoResguardo(String? valor) {
    if (valor != null && _isEditing) {
      // Solo permite cambiar en modo edición
      setState(() {
        _tipoResguardoSeleccionado = valor;
        _camposEntregaHabilitados = (valor == 'Traspaso de resguardo');
        if (!_camposEntregaHabilitados) {
          _areaEntregaController.clear();
          _nombreEntregaController.clear();
          _rfcEntregaController.clear();
        }
      });
    }
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      final String? nombreEditor =
          usuarioGlobal?.nombre; // Nombre del usuario que guarda

      // Actualizar el objeto _resguardoActual con los datos de los controladores
      _resguardoActual = _resguardoActual.copyWith(
        tipoResguardo: _tipoResguardoSeleccionado,
        numeroInventario: _numeroInventarioController.text,
        descripcion: _descripcionController.text,
        areaEntrega:
            _camposEntregaHabilitados ? _areaEntregaController.text : 'N/A',
        nombreEntrega:
            _camposEntregaHabilitados ? _nombreEntregaController.text : 'N/A',
        rfcEntrega:
            _camposEntregaHabilitados ? _rfcEntregaController.text : 'N/A',
        areaRecibe: _areaRecibeController.text,
        nombreRecibe: _nombreRecibeController.text,
        rfcRecibe: _rfcRecibeController.text,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text,
        capturadoPor: nombreEditor ?? 'Desconocido', // Actualiza quien modificó
        // Estatus y FechaAutorizado no se modifican aquí directamente
      );

      // TODO: Aquí iría la lógica para guardar en la base de datos

      // Devolver el resguardo actualizado y salir
      Navigator.pop(
          context,
          DetalleResguardoResult(DetalleResguardoResultAction.updated,
              resguardo: _resguardoActual));

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Resguardo ${_resguardoActual.folioFormateado} actualizado'),
            backgroundColor: Colors.blue),
      );

      // Salir del modo edición después de guardar
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text(
              '¿Está seguro que desea eliminar el resguardo ${_resguardoActual.folioFormateado}? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Cierra el diálogo de confirmación
                _eliminarResguardo();
              },
            ),
          ],
        );
      },
    );
  }

  void _eliminarResguardo() {
    // TODO: Aquí iría la lógica para eliminar en la base de datos

    // Devolver indicación de eliminación y salir
    Navigator.pop(
        context,
        DetalleResguardoResult(DetalleResguardoResultAction.deleted,
            resguardo:
                _resguardoActual)); // Pasamos el resguardo para saber cuál se eliminó

    // Mostrar confirmación (opcional, ya que se navega hacia atrás)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Resguardo ${_resguardoActual.folioFormateado} eliminado'),
          backgroundColor: Colors.red),
    );
  }

  void _cambiarEstatus(String nuevoEstatus) {
    setState(() {
      final now = DateTime.now();
      final formatter =
          DateFormat('yyyy-MM-dd HH:mm:ss'); // Formato de fecha y hora
      _resguardoActual = _resguardoActual.copyWith(
          estatus: nuevoEstatus,
          // Actualizar fecha solo si se aprueba, o limpiar si se rechaza/pone pendiente
          fechaAutorizado:
              nuevoEstatus == 'Aprobado' ? formatter.format(now) : null,
          capturadoPor: usuarioGlobal?.nombre ??
              'Desconocido' // Quién hizo el cambio de estatus
          );
      // TODO: Aquí iría la lógica para guardar el cambio de estatus en la base de datos

      // Devolver el resguardo actualizado
      Navigator.pop(
          context,
          DetalleResguardoResult(DetalleResguardoResultAction.updated,
              resguardo: _resguardoActual));

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Estatus de ${_resguardoActual.folioFormateado} actualizado a $nuevoEstatus'),
            backgroundColor: Colors.blue),
      );
    });
  }

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

  // Widget para mostrar datos (editable o no)
  Widget _buildInfoField({
    required String label,
    required String? value,
    TextEditingController? controller,
    bool editable = false, // Por defecto no editable
    bool enabled = true, // Para habilitar/deshabilitar externamente
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    // Si estamos en modo edición Y el campo es editable Y está habilitado
    bool fieldEnabled = _isEditing && editable && enabled;

    // Si no hay controlador, creamos uno temporal solo para mostrar el valor
    final displayController =
        controller ?? TextEditingController(text: value ?? '');
    // Si no se pasó un controlador, aseguramos limpiar el temporal
    if (controller == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) displayController.dispose();
      });
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller:
            displayController, // Usar el controlador pasado o el temporal
        readOnly: !fieldEnabled, // Solo editable si fieldEnabled es true
        enabled: enabled, // Controla si se ve grisáceo (caso 'N/A')
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
          filled: !enabled ||
              !fieldEnabled, // Relleno si no está habilitado o no es editable
          fillColor: (!enabled || !fieldEnabled)
              ? Colors.grey[200]
              : Colors.white, // Color gris si no editable/habilitado
        ),
        validator: fieldEnabled
            ? validator
            : null, // Validar solo si está habilitado y en modo edición
        // Actualizar el estado interno si es un campo temporal y cambia (aunque sea readOnly)
        // No es necesario si usamos controladores de estado
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final folioFormatter = NumberFormat("0000");
    final String folioMostrado =
        'RICB-${folioFormatter.format(_resguardoActual.folio)}';
    bool puedeEditarEntrega = _isEditing && _camposEntregaHabilitados;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalle Resguardo: $folioMostrado",
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 25.0.dg),
        ),
        backgroundColor: Color(0xfff6c500),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(
              context,
              DetalleResguardoResult(DetalleResguardoResultAction
                  .none)), // Devolver 'none' si solo regresa
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.w),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                child: Padding(
                  padding: EdgeInsets.all(25.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoField(
                            label: 'Folio',
                            value: folioMostrado,
                            editable: false,
                            enabled: false), // Folio nunca editable
                        SizedBox(height: 12.h),

                        _buildSectionTitle('Tipo de Resguardo'),
                        // Radio buttons solo activos en modo edición
                        IgnorePointer(
                          ignoring:
                              !_isEditing, // Deshabilita interacción si no se edita
                          child: Opacity(
                            opacity: _isEditing
                                ? 1.0
                                : 0.6, // Atenuar si no se edita
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  title: const Text('Traspaso de resguardo'),
                                  value: 'Traspaso de resguardo',
                                  groupValue: _tipoResguardoSeleccionado,
                                  onChanged: _cambiarTipoResguardo,
                                ),
                                RadioListTile<String>(
                                  title: const Text('Nueva adquisición'),
                                  value: 'Nueva adquisición',
                                  groupValue: _tipoResguardoSeleccionado,
                                  onChanged: _cambiarTipoResguardo,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(height: 20.h, thickness: 1),

                        _buildSectionTitle('Datos del Bien'),
                        _buildInfoField(
                            label: 'No. Inventario',
                            value: _resguardoActual.numeroInventario,
                            controller: _numeroInventarioController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'Descripción',
                            value: _resguardoActual.descripcion,
                            controller: _descripcionController,
                            editable: true,
                            maxLines: 2,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        Divider(height: 20.h, thickness: 1),

                        _buildSectionTitle('Datos de Quien Entrega'),
                        _buildInfoField(
                            label: 'Área Entrega',
                            value: _resguardoActual.areaEntrega,
                            controller: _areaEntregaController,
                            editable: true,
                            enabled: _camposEntregaHabilitados,
                            validator: (v) => (puedeEditarEntrega &&
                                    (v?.trim().isEmpty ?? true))
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'Nombre Entrega',
                            value: _resguardoActual.nombreEntrega,
                            controller: _nombreEntregaController,
                            editable: true,
                            enabled: _camposEntregaHabilitados,
                            validator: (v) => (puedeEditarEntrega &&
                                    (v?.trim().isEmpty ?? true))
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'RFC Entrega',
                            value: _resguardoActual.rfcEntrega,
                            controller: _rfcEntregaController,
                            editable: true,
                            enabled: _camposEntregaHabilitados,
                            validator: (v) => (puedeEditarEntrega &&
                                    (v?.trim().isEmpty ?? true))
                                ? 'Requerido'
                                : null),
                        Divider(height: 20.h, thickness: 1),

                        _buildSectionTitle('Datos de Quien Recibe'),
                        _buildInfoField(
                            label: 'Área Recibe',
                            value: _resguardoActual.areaRecibe,
                            controller: _areaRecibeController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'Nombre Recibe',
                            value: _resguardoActual.nombreRecibe,
                            controller: _nombreRecibeController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        _buildInfoField(
                            label: 'RFC Recibe',
                            value: _resguardoActual.rfcRecibe,
                            controller: _rfcRecibeController,
                            editable: true,
                            validator: (v) => (v?.trim().isEmpty ?? true)
                                ? 'Requerido'
                                : null),
                        Divider(height: 20.h, thickness: 1),

                        _buildSectionTitle('Historial y Estatus'),
                        _buildInfoField(
                            label: 'Capturado Por',
                            value: _resguardoActual.capturadoPor,
                            editable: false,
                            enabled: false), // No editable
                        _buildInfoField(
                            label: 'Fecha Autorizado',
                            value: _resguardoActual.fechaAutorizado,
                            editable: false,
                            enabled: false), // No editable directamente
                        _buildInfoField(
                            label: 'Estatus',
                            value: _resguardoActual.estatus,
                            editable: false,
                            enabled:
                                false), // No editable directamente por usuario normal
                        Divider(height: 20.h, thickness: 1),

                        _buildSectionTitle('Observaciones'),
                        _buildInfoField(
                            label: 'Observaciones',
                            value: _resguardoActual.observaciones,
                            controller: _observacionesController,
                            editable: true,
                            maxLines: 3),
                        SizedBox(height: 30.h),

                        // --- Botones de Acción ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Botón Modificar / Guardar
                            if (_isEditing)
                              ElevatedButton.icon(
                                icon: Icon(Icons.save),
                                label: Text('Guardar Cambios'),
                                onPressed: _guardarCambios,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white),
                              )
                            else
                              ElevatedButton.icon(
                                icon: Icon(Icons.edit),
                                label: Text('Modificar Folio'),
                                onPressed: _toggleEdit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black),
                              ),

                            // Botón Eliminar (siempre visible, excepto en edición?)
                            // O podríamos ocultarlo mientras se edita para evitar clics accidentales
                            if (!_isEditing) // Ocultar mientras se edita
                              ElevatedButton.icon(
                                icon: Icon(Icons.delete_forever),
                                label: Text('Eliminar Folio'),
                                onPressed: _confirmarEliminar,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                              ),

                            // Botón Cancelar (solo visible en modo edición)
                            if (_isEditing)
                              TextButton(
                                  onPressed:
                                      _toggleEdit, // Llama a la misma función para cancelar
                                  child: Text('Cancelar')),
                          ],
                        ),

                        // --- Botones de Admin ---
                        if (_isAdmin &&
                            !_isEditing) // Solo para admin Y no en modo edición
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(Icons.check_circle),
                                  label: Text('Aprobar'),
                                  onPressed: () => _cambiarEstatus('Aprobado'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white),
                                ),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.cancel),
                                  label: Text('Rechazar'),
                                  onPressed: () => _cambiarEstatus('Rechazado'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white),
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
