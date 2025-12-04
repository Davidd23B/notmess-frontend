import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/producto.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/error_dialog.dart';
import '../viewmodels/producto_viewmodel.dart';
import '../viewmodels/categoria_viewmodel.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _proveedorController = TextEditingController();
  
  int? _categoriaSeleccionada;
  String _medidaSeleccionada = 'unidad';
  bool _isLoading = false;
  File? _selectedImage;
  String? _imagenActual; // Para trackear la imagen actual del producto
  bool _eliminarImagen = false; // Flag para marcar si se debe eliminar la imagen al actualizar
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    if (widget.producto != null) {
      _nombreController.text = widget.producto!.nombre;
      _cantidadController.text = _formatCantidadParaEdicion(widget.producto!.cantidad, widget.producto!.medida);
      _proveedorController.text = widget.producto!.proveedor;
      _categoriaSeleccionada = widget.producto!.idCategoria;
      _medidaSeleccionada = widget.producto!.medida;
      _imagenActual = widget.producto!.imagen; // Inicializar con la imagen existente
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriaViewModel = Provider.of<CategoriaViewModel>(context, listen: false);
      categoriaViewModel.loadCategorias();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  String _formatCantidadParaEdicion(double cantidad, String medida) {
    if (medida == 'unidad') {
      return cantidad.toInt().toString();
    } else {
      return cantidad.toString();
    }
  }

  void _onMedidaChanged(String? newMedida) {
    if (newMedida == null) return;
    setState(() => _medidaSeleccionada = newMedida);
    
    // Reformatear la cantidad cuando cambia la medida
    if (_cantidadController.text.isNotEmpty) {
      final cantidad = double.tryParse(_cantidadController.text.replaceAll(',', '.'));
      if (cantidad != null) {
        if (newMedida == 'unidad') {
          // Quitar decimales automáticamente
          _cantidadController.text = cantidad.toInt().toString();
        } else if (newMedida == 'kg' || newMedida == 'L') {
          // Si no tiene decimales, agregar .0
          if (!_cantidadController.text.contains('.')) {
            _cantidadController.text = '${cantidad.toInt()}.0';
          }
        }
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSeleccionada == null) {
      return;
    }

    setState(() => _isLoading = true);

    final productoViewModel = Provider.of<ProductoViewModel>(context, listen: false);
    
    // Para crear: pasar id=0, el backend lo ignora y genera uno nuevo
    // Para actualizar: usar el id existente
    final producto = Producto(
      idProducto: widget.producto?.idProducto ?? 0,
      nombre: _nombreController.text.trim(),
      cantidad: double.parse(_cantidadController.text),
      medida: _medidaSeleccionada,
      proveedor: _proveedorController.text.trim(),
      idCategoria: _categoriaSeleccionada!,
      imagen: _eliminarImagen ? null : _imagenActual, // Si se marcó para eliminar, enviar null
    );

    bool success = false;
    if (widget.producto == null) {
      // Crear producto y obtener el creado con su ID
      final productoCreado = await productoViewModel.createProducto(producto);
      
      if (productoCreado != null) {
        success = true;
        // Si hay una imagen seleccionada, subirla usando el ID del producto creado
        if (_selectedImage != null) {
          success = await productoViewModel.uploadImagen(productoCreado.idProducto, _selectedImage!);
        }
      }
    } else {
      // Actualizar producto
      
      // Si el usuario marcó la imagen para eliminar, llamar al DELETE primero
      if (_eliminarImagen && widget.producto!.imagen != null) {
        await productoViewModel.deleteImagen(widget.producto!.idProducto);
      }
      
      success = await productoViewModel.updateProducto(widget.producto!.idProducto, producto);
      
      // Si hay una nueva imagen seleccionada, subirla
      if (success && _selectedImage != null) {
        success = await productoViewModel.uploadImagen(widget.producto!.idProducto, _selectedImage!);
      }
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ErrorDialog.show(context);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // No hcaer nada.
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // No hacer nada.
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.producto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el nombre del producto';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _proveedorController,
              decoration: const InputDecoration(
                labelText: 'Proveedor',
                prefixIcon: Icon(Icons.local_shipping_outlined),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el proveedor';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Consumer<CategoriaViewModel>(
              builder: (context, categoriaViewModel, child) {
                if (categoriaViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<int>(
                  initialValue: _categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: categoriaViewModel.categorias.map((categoria) {
                    return DropdownMenuItem(
                      value: categoria.id,
                      child: Text(categoria.nombre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _categoriaSeleccionada = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Selecciona una categoría';
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _medidaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Unidad de medida',
                prefixIcon: Icon(Icons.straighten_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'unidad', child: Text('Unidad')),
                DropdownMenuItem(value: 'kg', child: Text('Kilogramo (kg)')),
                DropdownMenuItem(value: 'L', child: Text('Litro (L)')),
              ],
              onChanged: _onMedidaChanged,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cantidadController,
              decoration: InputDecoration(
                labelText: 'Cantidad en stock',
                prefixIcon: const Icon(Icons.format_list_numbered_outlined),
                border: const OutlineInputBorder(),
                helperText: _medidaSeleccionada == 'unidad'
                    ? 'Solo números enteros (ej: 80)'
                    : 'Puede tener decimales (ej: 80.5 o 80.0)',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _medidaSeleccionada == 'unidad'
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
              onChanged: (value) {
                if (_medidaSeleccionada == 'kg' || _medidaSeleccionada == 'L') {
                  if (value.isNotEmpty && !value.contains('.') && value.isNotEmpty) {
                  }
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa la cantidad';
                }
                final cantidad = double.tryParse(value);
                if (cantidad == null || cantidad < 0) {
                  return 'Cantidad inválida';
                }
                if (_medidaSeleccionada == 'unidad' && cantidad != cantidad.toInt()) {
                  return 'Debe ser un número entero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              child: InkWell(
                onTap: _showImageSourceDialog,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_selectedImage != null)
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: CircleAvatar(
                                backgroundColor: theme.colorScheme.errorContainer,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: theme.colorScheme.onErrorContainer),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (_imagenActual != null)
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.network(
                                    '${ApiConstants.baseUrl}/imagenes/$_imagenActual',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: theme.colorScheme.surfaceContainer,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 64,
                                            color: theme.colorScheme.outline,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (_eliminarImagen)
                                    Container(
                                      height: 200,
                                      color: Colors.red.withValues(alpha: 0.5),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.delete_forever,
                                              size: 64,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Se eliminará al actualizar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: CircleAvatar(
                                backgroundColor: theme.colorScheme.errorContainer,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: theme.colorScheme.onErrorContainer),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Eliminar imagen'),
                                        content: const Text('¿Estás seguro de que deseas eliminar la imagen del producto?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirm == true && widget.producto != null) {
                                      setState(() {
                                        _eliminarImagen = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 64,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca para agregar una imagen',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Desde galería o cámara',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
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
                        : Text(isEdit ? 'Actualizar' : 'Crear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
