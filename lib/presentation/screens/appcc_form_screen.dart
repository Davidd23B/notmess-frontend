import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/utils/error_dialog.dart';
import '../../data/models/appcc.dart';
import '../../data/models/appcc_limpieza.dart';
import '../../data/models/appcc_temperatura.dart';
import '../../data/models/appcc_producto.dart';
import '../../data/models/appcc_freidora.dart';
import '../viewmodels/appcc_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class AppccFormScreen extends StatefulWidget {
  final Appcc? appcc;
  
  const AppccFormScreen({super.key, this.appcc});

  @override
  State<AppccFormScreen> createState() => _AppccFormScreenState();
}

class _AppccFormScreenState extends State<AppccFormScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  int? _idLimpieza;
  int? _idTemperatura;
  int? _idProducto;
  int? _idFreidora;
  bool _isLoading = true;
  bool _datosYaCargados = false;

  String _turnoSeleccionado = 'mañana';
  final TextEditingController _observacionesGeneralesController = TextEditingController();

  final Map<String, bool?> _limpieza = {
    'congelador1': null,
    'congelador2': null,
    'congelador3': null,
    'camara1': null,
    'camara2': null,
    'mesa1': null,
    'mesa2': null,
    'mesa3': null,
    'paredes': null,
    'suelo': null,
  };
  final TextEditingController _observacionesLimpiezaController = TextEditingController();

  final Map<String, TextEditingController> _temperaturaControllers = {
    'congelador1': TextEditingController(),
    'congelador2': TextEditingController(),
    'congelador3': TextEditingController(),
    'camara1': TextEditingController(),
    'camara2': TextEditingController(),
    'mesa1': TextEditingController(),
    'mesa2': TextEditingController(),
    'mesa3': TextEditingController(),
  };
  final TextEditingController _observacionesTemperaturaController = TextEditingController();

  final Map<String, TextEditingController> _estadoProductoControllers = {
    'congelador1': TextEditingController(),
    'congelador2': TextEditingController(),
    'congelador3': TextEditingController(),
    'camara1': TextEditingController(),
    'camara2': TextEditingController(),
    'mesa1': TextEditingController(),
    'mesa2': TextEditingController(),
    'mesa3': TextEditingController(),
  };
  final Map<String, TextEditingController> _tempProductoControllers = {
    'congelador1': TextEditingController(),
    'congelador2': TextEditingController(),
    'congelador3': TextEditingController(),
    'camara1': TextEditingController(),
    'camara2': TextEditingController(),
    'mesa1': TextEditingController(),
    'mesa2': TextEditingController(),
    'mesa3': TextEditingController(),
  };
  final TextEditingController _observacionesProductoController = TextEditingController();

  final Map<String, TextEditingController> _freidoraControllers = {
    'temperatura_freidora1': TextEditingController(),
    'temperatura_freidora2': TextEditingController(),
    'tpm_freidora1': TextEditingController(),
    'tpm_freidora2': TextEditingController(),
  };
  final TextEditingController _observacionesFreidoraController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.appcc == null) {
      _isLoading = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.appcc != null && !_datosYaCargados) {
      _datosYaCargados = true;
      _cargarDatosParaEdicion();
    }
  }

  Future<void> _cargarDatosParaEdicion() async {
    final appccViewModel = Provider.of<AppccViewModel>(context, listen: false);
    final datos = await appccViewModel.getAppccDetalle(widget.appcc!.idAppcc);
    
    if (datos != null && mounted) {
      setState(() {
        _turnoSeleccionado = widget.appcc!.turno;
        _observacionesGeneralesController.text = widget.appcc!.observaciones ?? '';

        if (datos['limpieza'] != null) {
          final limpieza = datos['limpieza'] as AppccLimpieza;
          _idLimpieza = limpieza.idAppccLimpieza;
          _limpieza['congelador1'] = limpieza.congelador1;
          _limpieza['congelador2'] = limpieza.congelador2;
          _limpieza['congelador3'] = limpieza.congelador3;
          _limpieza['camara1'] = limpieza.camara1;
          _limpieza['camara2'] = limpieza.camara2;
          _limpieza['mesa1'] = limpieza.mesa1;
          _limpieza['mesa2'] = limpieza.mesa2;
          _limpieza['mesa3'] = limpieza.mesa3;
          _limpieza['paredes'] = limpieza.paredes;
          _limpieza['suelo'] = limpieza.suelo;
          _observacionesLimpiezaController.text = limpieza.observaciones ?? '';
        }

        if (datos['temperatura'] != null) {
          final temperatura = datos['temperatura'] as AppccTemperatura;
          _idTemperatura = temperatura.idAppccTemperatura;
          _temperaturaControllers['congelador1']!.text = temperatura.congelador1?.toString() ?? '';
          _temperaturaControllers['congelador2']!.text = temperatura.congelador2?.toString() ?? '';
          _temperaturaControllers['congelador3']!.text = temperatura.congelador3?.toString() ?? '';
          _temperaturaControllers['camara1']!.text = temperatura.camara1?.toString() ?? '';
          _temperaturaControllers['camara2']!.text = temperatura.camara2?.toString() ?? '';
          _temperaturaControllers['mesa1']!.text = temperatura.mesa1?.toString() ?? '';
          _temperaturaControllers['mesa2']!.text = temperatura.mesa2?.toString() ?? '';
          _temperaturaControllers['mesa3']!.text = temperatura.mesa3?.toString() ?? '';
          _observacionesTemperaturaController.text = temperatura.observaciones ?? '';
        }

        if (datos['producto'] != null) {
          final producto = datos['producto'] as AppccProducto;
          _idProducto = producto.idAppccProducto;
          _estadoProductoControllers['congelador1']!.text = producto.estadoProductoCongelador1 ?? '';
          _estadoProductoControllers['congelador2']!.text = producto.estadoProductoCongelador2 ?? '';
          _estadoProductoControllers['congelador3']!.text = producto.estadoProductoCongelador3 ?? '';
          _estadoProductoControllers['camara1']!.text = producto.estadoProductoCamara1 ?? '';
          _estadoProductoControllers['camara2']!.text = producto.estadoProductoCamara2 ?? '';
          _estadoProductoControllers['mesa1']!.text = producto.estadoProductoMesa1 ?? '';
          _estadoProductoControllers['mesa2']!.text = producto.estadoProductoMesa2 ?? '';
          _estadoProductoControllers['mesa3']!.text = producto.estadoProductoMesa3 ?? '';
          _tempProductoControllers['congelador1']!.text = producto.temperaturaProductoCongelador1?.toString() ?? '';
          _tempProductoControllers['congelador2']!.text = producto.temperaturaProductoCongelador2?.toString() ?? '';
          _tempProductoControllers['congelador3']!.text = producto.temperaturaProductoCongelador3?.toString() ?? '';
          _tempProductoControllers['camara1']!.text = producto.temperaturaProductoCamara1?.toString() ?? '';
          _tempProductoControllers['camara2']!.text = producto.temperaturaProductoCamara2?.toString() ?? '';
          _tempProductoControllers['mesa1']!.text = producto.temperaturaProductoMesa1?.toString() ?? '';
          _tempProductoControllers['mesa2']!.text = producto.temperaturaProductoMesa2?.toString() ?? '';
          _tempProductoControllers['mesa3']!.text = producto.temperaturaProductoMesa3?.toString() ?? '';
          _observacionesProductoController.text = producto.observaciones ?? '';
        }

        if (datos['freidora'] != null) {
          final freidora = datos['freidora'] as AppccFreidora;
          _idFreidora = freidora.idAppccFreidora;
          _freidoraControllers['temperatura_freidora1']!.text = freidora.temperaturaFreidora1?.toString() ?? '';
          _freidoraControllers['temperatura_freidora2']!.text = freidora.temperaturaFreidora2?.toString() ?? '';
          _freidoraControllers['tpm_freidora1']!.text = freidora.tpmFreidora1?.toString() ?? '';
          _freidoraControllers['tpm_freidora2']!.text = freidora.tpmFreidora2?.toString() ?? '';
          _observacionesFreidoraController.text = freidora.observaciones ?? '';
        }

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _observacionesGeneralesController.dispose();
    _observacionesLimpiezaController.dispose();
    _observacionesTemperaturaController.dispose();
    _observacionesProductoController.dispose();
    _observacionesFreidoraController.dispose();
    for (final c in _temperaturaControllers.values) {
      c.dispose();
    }
    for (final c in _estadoProductoControllers.values) {
      c.dispose();
    }
    for (final c in _tempProductoControllers.values) {
      c.dispose();
    }
    for (final c in _freidoraControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardarAppcc() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final appccViewModel = Provider.of<AppccViewModel>(context, listen: false);

    final temperatura = <String, double?>{};
    for (final entry in _temperaturaControllers.entries) {
      temperatura[entry.key] = entry.value.text.isNotEmpty 
          ? double.tryParse(entry.value.text) 
          : null;
    }

    final producto = <String, dynamic>{};
    for (final entry in _estadoProductoControllers.entries) {
      producto['estado_${entry.key}'] = entry.value.text.isNotEmpty ? entry.value.text : null;
    }
    for (final entry in _tempProductoControllers.entries) {
      producto['temp_${entry.key}'] = entry.value.text.isNotEmpty 
          ? double.tryParse(entry.value.text) 
          : null;
    }

    final freidora = <String, double?>{};
    for (final entry in _freidoraControllers.entries) {
      freidora[entry.key] = entry.value.text.isNotEmpty 
          ? double.tryParse(entry.value.text) 
          : null;
    }

    bool success;
    if (widget.appcc != null) {
      bool estaCompletado = _verificarCompletado(
        limpieza: _limpieza,
        temperatura: temperatura,
        producto: producto,
        freidora: freidora,
      );
      
      success = await appccViewModel.updateAppccCompleto(
        idAppcc: widget.appcc!.idAppcc,
        turno: _turnoSeleccionado,
        observacionesGenerales: _observacionesGeneralesController.text.isNotEmpty 
            ? _observacionesGeneralesController.text 
            : null,
        completado: estaCompletado,
        idUsuario: authViewModel.currentUser?.idUsuario ?? 1,
        limpieza: _limpieza,
        observacionesLimpieza: _observacionesLimpiezaController.text.isNotEmpty 
            ? _observacionesLimpiezaController.text 
            : null,
        idLimpieza: _idLimpieza,
        temperatura: temperatura,
        observacionesTemperatura: _observacionesTemperaturaController.text.isNotEmpty 
            ? _observacionesTemperaturaController.text 
            : null,
        idTemperatura: _idTemperatura,
        producto: producto,
        observacionesProducto: _observacionesProductoController.text.isNotEmpty 
            ? _observacionesProductoController.text 
            : null,
        idProducto: _idProducto,
        freidora: freidora,
        observacionesFreidora: _observacionesFreidoraController.text.isNotEmpty 
            ? _observacionesFreidoraController.text 
            : null,
        idFreidora: _idFreidora,
      );
    } else {
      bool estaCompletado = _verificarCompletado(
        limpieza: _limpieza,
        temperatura: temperatura,
        producto: producto,
        freidora: freidora,
      );
      
      success = await appccViewModel.createAppccCompleto(
        turno: _turnoSeleccionado,
        observacionesGenerales: _observacionesGeneralesController.text.isNotEmpty 
            ? _observacionesGeneralesController.text 
            : null,
        completado: estaCompletado,
        idUsuario: authViewModel.currentUser?.idUsuario ?? 1,
        limpieza: _limpieza,
        observacionesLimpieza: _observacionesLimpiezaController.text.isNotEmpty 
            ? _observacionesLimpiezaController.text 
            : null,
        temperatura: temperatura,
        observacionesTemperatura: _observacionesTemperaturaController.text.isNotEmpty 
            ? _observacionesTemperaturaController.text 
            : null,
        producto: producto,
        observacionesProducto: _observacionesProductoController.text.isNotEmpty 
            ? _observacionesProductoController.text 
            : null,
        freidora: freidora,
        observacionesFreidora: _observacionesFreidoraController.text.isNotEmpty 
            ? _observacionesFreidoraController.text 
            : null,
      );
    }

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ErrorDialog.show(context);
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _verificarCompletado({
    required Map<String, bool?> limpieza,
    required Map<String, double?> temperatura,
    required Map<String, dynamic> producto,
    required Map<String, double?> freidora,
  }) {
    final limpiezaCompleta = limpieza.values.every((v) => v != null);
    final temperaturaCompleta = temperatura.values.every((v) => v != null);
    final productoCompleto = producto.values.every((v) => v != null && (v is! String || v.isNotEmpty));
    final freidoraCompleta = freidora.values.every((v) => v != null);
    return limpiezaCompleta && 
           temperaturaCompleta && 
           productoCompleto && 
           freidoraCompleta;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appcc != null ? 'Editar Registro APPCC' : 'Nuevo Registro APPCC'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;
                
                return Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : isActive
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.onPrimary,
                                size: 18,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (index < 4)
                      Container(
                        width: 40,
                        height: 2,
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                  ],
                );
              }),
            ),
          ),

          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepGeneral(),
                  _buildStepLimpieza(),
                  _buildStepTemperatura(),
                  _buildStepProducto(),
                  _buildStepFreidora(),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _currentStep == 4
                      ? FilledButton.icon(
                          onPressed: _guardarAppcc,
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar'),
                        )
                      : FilledButton.icon(
                          onPressed: _nextStep,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Siguiente'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepGeneral() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Información General',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _turnoSeleccionado,
          decoration: const InputDecoration(
            labelText: 'Turno',
            prefixIcon: Icon(Icons.access_time),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'mañana', child: Text('Mañana')),
            DropdownMenuItem(value: 'tarde', child: Text('Tarde')),
          ],
          onChanged: (value) {
            setState(() => _turnoSeleccionado = value!);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _observacionesGeneralesController,
          decoration: const InputDecoration(
            labelText: 'Observaciones generales (opcional)',
            prefixIcon: Icon(Icons.notes),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildStepLimpieza() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Control de Limpieza',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Marca las áreas que han sido limpiadas',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _buildCheckboxGroup('Congeladores', ['congelador1', 'congelador2', 'congelador3']),
        const SizedBox(height: 16),
        _buildCheckboxGroup('Cámaras', ['camara1', 'camara2']),
        const SizedBox(height: 16),
        _buildCheckboxGroup('Mesas', ['mesa1', 'mesa2', 'mesa3']),
        const SizedBox(height: 16),
        _buildCheckboxGroup('Otros', ['paredes', 'suelo']),
        const SizedBox(height: 24),
        TextFormField(
          controller: _observacionesLimpiezaController,
          decoration: const InputDecoration(
            labelText: 'Observaciones de limpieza (opcional)',
            prefixIcon: Icon(Icons.notes),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildCheckboxGroup(String title, List<String> keys) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...keys.map((key) => CheckboxListTile(
              title: Text(_formatLabel(key)),
              value: _limpieza[key] ?? false,
              tristate: true,
              onChanged: (value) {
                setState(() => _limpieza[key] = value);
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTemperatura() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Control de Temperatura',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Registra las temperaturas en °C',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _buildTemperaturaSection('Congeladores', ['congelador1', 'congelador2', 'congelador3']),
        const SizedBox(height: 16),
        _buildTemperaturaSection('Cámaras', ['camara1', 'camara2']),
        const SizedBox(height: 16),
        _buildTemperaturaSection('Mesas', ['mesa1', 'mesa2', 'mesa3']),
        const SizedBox(height: 24),
        TextFormField(
          controller: _observacionesTemperaturaController,
          decoration: const InputDecoration(
            labelText: 'Observaciones de temperatura (opcional)',
            prefixIcon: Icon(Icons.notes),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTemperaturaSection(String title, List<String> keys) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...keys.map((key) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _temperaturaControllers[key],
                decoration: InputDecoration(
                  labelText: _formatLabel(key),
                  suffixText: '°C',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStepProducto() {
    final keys = ['congelador1', 'congelador2', 'congelador3', 'camara1', 'camara2', 'mesa1', 'mesa2', 'mesa3'];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Control de Productos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Estado y temperatura de productos almacenados',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        ...keys.map((key) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatLabel(key),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _estadoProductoControllers[key],
                  decoration: const InputDecoration(
                    labelText: 'Estado del producto',
                    hintText: 'Ej: Correcto, Caducado, etc.',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tempProductoControllers[key],
                  decoration: const InputDecoration(
                    labelText: 'Temperatura',
                    suffixText: '°C',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                ),
              ],
            ),
          ),
        )),
        TextFormField(
          controller: _observacionesProductoController,
          decoration: const InputDecoration(
            labelText: 'Observaciones de productos (opcional)',
            prefixIcon: Icon(Icons.notes),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildStepFreidora() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Control de Freidoras',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Temperatura y TPM (Total Polar Materials)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Freidora 1',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _freidoraControllers['temperatura_freidora1'],
                  decoration: const InputDecoration(
                    labelText: 'Temperatura',
                    suffixText: '°C',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _freidoraControllers['tpm_freidora1'],
                  decoration: const InputDecoration(
                    labelText: 'TPM',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Freidora 2',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _freidoraControllers['temperatura_freidora2'],
                  decoration: const InputDecoration(
                    labelText: 'Temperatura',
                    suffixText: '°C',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _freidoraControllers['tpm_freidora2'],
                  decoration: const InputDecoration(
                    labelText: 'TPM',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _observacionesFreidoraController,
          decoration: const InputDecoration(
            labelText: 'Observaciones de freidoras (opcional)',
            prefixIcon: Icon(Icons.notes),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  String _formatLabel(String key) {
    return key
        .replaceAll('congelador', 'Congelador ')
        .replaceAll('camara', 'Cámara ')
        .replaceAll('mesa', 'Mesa ')
        .replaceAll('paredes', 'Paredes')
        .replaceAll('suelo', 'Suelo')
        .replaceAllMapped(RegExp(r'\d'), (match) => match.group(0)!);
  }
}
