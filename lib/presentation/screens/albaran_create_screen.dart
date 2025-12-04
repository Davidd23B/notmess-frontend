import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/utils/error_dialog.dart';
import '../../data/models/linea_albaran.dart';
import '../../data/models/producto.dart';
import '../viewmodels/albaran_viewmodel.dart';
import '../viewmodels/producto_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class AlbaranCreateScreen extends StatefulWidget {
  const AlbaranCreateScreen({super.key});

  @override
  State<AlbaranCreateScreen> createState() => _AlbaranCreateScreenState();
}

class _AlbaranCreateScreenState extends State<AlbaranCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tipoSeleccionado = 'entrada';
  final _motivoMermaController = TextEditingController();
  final List<_LineaTemp> _lineas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductoViewModel>(context, listen: false).loadProductos();
    });
  }

  @override
  void dispose() {
    _motivoMermaController.dispose();
    super.dispose();
  }

  void _agregarLinea() {
    // Obtener IDs de productos ya agregados
    final productosYaAgregados = _lineas.map((l) => l.producto.idProducto).toSet();
    
    showDialog(
      context: context,
      builder: (context) => _MultiProductDialog(
        productosExcluidos: productosYaAgregados,
        onAdd: (lineas) {
          setState(() => _lineas.addAll(lineas));
        },
      ),
    );
  }

  void _eliminarLinea(int index) {
    setState(() => _lineas.removeAt(index));
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tipoSeleccionado == 'merma' && _motivoMermaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes especificar el motivo de la merma'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final albaranViewModel = Provider.of<AlbaranViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    final lineasAlbaran = _lineas.map((lt) => LineaAlbaran(
      idLineaAlbaran: 0,
      idAlbaran: 0,
      idProducto: lt.producto.idProducto,
      cantidad: lt.cantidad,
      nombreProducto: lt.producto.nombre,
    )).toList();

    final result = await albaranViewModel.createAlbaranWithLineas(
      tipo: _tipoSeleccionado,
      motivoMerma: _tipoSeleccionado == 'merma' ? _motivoMermaController.text.trim() : null,
      lineas: lineasAlbaran,
      idUsuario: authViewModel.currentUser?.id ?? 1,
    );

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ErrorDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Albarán'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Tipo de movimiento',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'entrada',
                        label: Text('Entrada'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: 'salida',
                        label: Text('Salida'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                      ButtonSegment(
                        value: 'merma',
                        label: Text('Merma'),
                        icon: Icon(Icons.warning_outlined),
                      ),
                    ],
                    selected: {_tipoSeleccionado},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() => _tipoSeleccionado = newSelection.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_tipoSeleccionado == 'merma') ...[
                    TextFormField(
                      controller: _motivoMermaController,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de merma *',
                        prefixIcon: Icon(Icons.description_outlined),
                        border: OutlineInputBorder(),
                        helperText: 'Requerido para mermas',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (_tipoSeleccionado == 'merma' && (value == null || value.trim().isEmpty)) {
                          return 'El motivo es obligatorio para mermas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Líneas del albarán
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Líneas del albarán',
                        style: theme.textTheme.titleMedium,
                      ),
                      FilledButton.icon(
                        onPressed: _agregarLinea,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_lineas.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'No hay líneas agregadas',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_lineas.length, (index) {
                      final linea = _lineas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(linea.producto.nombre),
                          subtitle: Text(
                            'Cantidad: ${linea.cantidad} ${linea.producto.medida}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _eliminarLinea(index),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

            // Botones
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
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Crear Albarán'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineaTemp {
  final Producto producto;
  double cantidad;

  _LineaTemp({required this.producto, required this.cantidad});
}

// Nuevo diálogo para selección múltiple
class _MultiProductDialog extends StatefulWidget {
  final Function(List<_LineaTemp>) onAdd;
  final Set<int> productosExcluidos;

  const _MultiProductDialog({
    required this.onAdd,
    this.productosExcluidos = const {},
  });

  @override
  State<_MultiProductDialog> createState() => _MultiProductDialogState();
}

class _MultiProductDialogState extends State<_MultiProductDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final List<Producto> _productosSeleccionados = [];
  bool _mostrandoCantidades = false;
  final Map<int, TextEditingController> _cantidadControllers = {};

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _cantidadControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleProducto(Producto producto) {
    setState(() {
      if (_productosSeleccionados.contains(producto)) {
        _productosSeleccionados.remove(producto);
        _cantidadControllers[producto.idProducto]?.dispose();
        _cantidadControllers.remove(producto.idProducto);
      } else {
        _productosSeleccionados.add(producto);
        _cantidadControllers[producto.idProducto] = TextEditingController();
      }
    });
  }

  void _continuar() {
    if (_productosSeleccionados.isEmpty) return;
    setState(() => _mostrandoCantidades = true);
  }

  void _confirmar() {
    final lineas = <_LineaTemp>[];
    bool hayErrores = false;

    for (var producto in _productosSeleccionados) {
      final controller = _cantidadControllers[producto.idProducto];
      if (controller == null || controller.text.trim().isEmpty) {
        hayErrores = true;
        break;
      }

      final cantidad = double.tryParse(controller.text);
      if (cantidad == null || cantidad <= 0) {
        hayErrores = true;
        break;
      }

      if (producto.medida == 'unidad' && cantidad != cantidad.toInt()) {
        hayErrores = true;
        break;
      }

      lineas.add(_LineaTemp(producto: producto, cantidad: cantidad));
    }

    if (!hayErrores && lineas.isNotEmpty) {
      widget.onAdd(lineas);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AlertDialog(
      title: Text(_mostrandoCantidades ? 'Definir cantidades' : 'Seleccionar productos'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: screenHeight * 0.7,
        child: Column(
          children: [
            // Buscador
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar producto',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
            const SizedBox(height: 16),
            // Texto informativo
            if (_productosSeleccionados.isNotEmpty && !_mostrandoCantidades)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${_productosSeleccionados.length} producto${_productosSeleccionados.length != 1 ? 's' : ''} seleccionado${_productosSeleccionados.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            // Lista
            Expanded(
              child: Consumer<ProductoViewModel>(
                builder: (context, productoViewModel, child) {
                  if (productoViewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final productosFiltrados = productoViewModel.productos
                      .where((p) => 
                          !widget.productosExcluidos.contains(p.idProducto) &&
                          (_searchQuery.isEmpty || p.nombre.toLowerCase().contains(_searchQuery)))
                      .toList();

                  // Si no hay cantidades, mostrar todos. Si hay, solo los seleccionados
                  final productosAMostrar = _mostrandoCantidades 
                      ? _productosSeleccionados
                      : productosFiltrados;

                  return ListView.builder(
                    itemCount: productosAMostrar.length,
                    itemBuilder: (context, index) {
                      final producto = productosAMostrar[index];
                      final isSelected = _productosSeleccionados.contains(producto);
                      final controller = _cantidadControllers[producto.idProducto];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          title: Text(
                            producto.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Stock: ${producto.cantidadFormateada}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: _mostrandoCantidades
                              ? SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Cantidad',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: producto.medida == 'unidad'
                                        ? [FilteringTextInputFormatter.digitsOnly]
                                        : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                )
                              : Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleProducto(producto),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_mostrandoCantidades) {
              setState(() => _mostrandoCantidades = false);
            } else {
              Navigator.pop(context);
            }
          },
          child: Text(_mostrandoCantidades ? 'Atrás' : 'Cancelar'),
        ),
        FilledButton(
          onPressed: _mostrandoCantidades 
              ? _confirmar 
              : (_productosSeleccionados.isEmpty ? null : _continuar),
          child: Text(_mostrandoCantidades ? 'Agregar' : 'Continuar (${_productosSeleccionados.length})'),
        ),
      ],
    );
  }
}
