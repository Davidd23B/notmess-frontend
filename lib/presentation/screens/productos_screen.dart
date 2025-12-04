import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/producto.dart';
import '../../data/services/csv_service.dart';
import '../../core/utils/file_helper.dart';
import '../../core/utils/error_dialog.dart';
import '../viewmodels/producto_viewmodel.dart';
import '../viewmodels/categoria_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'producto_form_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CsvService _csvService = CsvService();
  bool _modoSeleccion = false;
  final Set<int> _productosSeleccionados = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productoViewModel = Provider.of<ProductoViewModel>(
        context,
        listen: false,
      );
      final categoriaViewModel = Provider.of<CategoriaViewModel>(
        context,
        listen: false,
      );
      productoViewModel.limpiarFiltros();
      productoViewModel.loadProductos();
      categoriaViewModel.loadCategorias();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportarTodosLosProductos() async {
    try {
      final csvResponse = await _csvService.exportarTodosLosProductos();
      final ruta = await FileHelper.descargarCsv(
        csvResponse.bytes,
        csvResponse.nombreArchivo,
      );

      if (mounted) {
        if (ruta == null) {
          ErrorDialog.show(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context);
      }
    }
  }

  Future<void> _exportarProductosSeleccionados() async {
    if (_productosSeleccionados.isEmpty) {
      ErrorDialog.show(context);
      return;
    }

    try {
      final csvResponse = await _csvService.exportarProductosSeleccionados(
        _productosSeleccionados.toList(),
      );
      final ruta = await FileHelper.descargarCsv(
        csvResponse.bytes,
        csvResponse.nombreArchivo,
      );

      if (mounted) {
        if (ruta != null) {
          setState(() {
            _modoSeleccion = false;
            _productosSeleccionados.clear();
          });
        } else {
          ErrorDialog.show(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context);
      }
    }
  }

  void _toggleModoSeleccion() {
    setState(() {
      _modoSeleccion = !_modoSeleccion;
      if (!_modoSeleccion) {
        _productosSeleccionados.clear();
      }
    });
  }

  void _toggleSeleccionProducto(int idProducto) {
    setState(() {
      if (_productosSeleccionados.contains(idProducto)) {
        _productosSeleccionados.remove(idProducto);
      } else {
        _productosSeleccionados.add(idProducto);
      }
    });
  }

  void _showProductoDetail(Producto producto) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final isAdmin = authViewModel.currentUser?.isAdmin ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.7,
        snap: true,
        snapSizes: const [0.7],
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(0),
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (producto.imagen != null && producto.imagen!.isNotEmpty)
                Container(
                  height: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      '${ApiConstants.baseUrl}/imagenes/${producto.imagen}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  height: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.inventory_outlined,
                      label: 'Stock',
                      value: producto.cantidadFormateada,
                      theme: theme,
                    ),
                    _InfoRow(
                      icon: Icons.straighten_outlined,
                      label: 'Medida',
                      value: producto.medida,
                      theme: theme,
                    ),
                    _InfoRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Proveedor',
                      value: producto.proveedor,
                      theme: theme,
                    ),
                    if (producto.nombreCategoria != null)
                      _InfoRow(
                        icon: Icons.category_outlined,
                        label: 'Categoría',
                        value: producto.nombreCategoria!,
                        theme: theme,
                      ),
                    const SizedBox(height: 16),
                    if (isAdmin)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                Navigator.pop(context);
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductoFormScreen(producto: producto),
                                  ),
                                );
                                if (result == true) {
                                  if (!context.mounted) return;
                                  Provider.of<ProductoViewModel>(
                                    context,
                                    listen: false,
                                  ).loadProductos();
                                }
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Editar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                final id = producto.idProducto;
                                final nombre = producto.nombre;
                                
                                Navigator.of(context).pop();
                                await Future.delayed(const Duration(milliseconds: 200));
                                
                                if (!context.mounted) return;
                                
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: Text('¿Estás seguro de eliminar "$nombre"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(true),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppTheme.error,
                                        ),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (confirm != true || !context.mounted) return;
                                
                                final vm = Provider.of<ProductoViewModel>(context, listen: false);
                                final resultado = await vm.deleteProducto(id);
                                
                                if (!context.mounted) return;
                                
                                if (!resultado) {
                                  ErrorDialog.show(context);
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Eliminar'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFiltroCategoria() {
    final theme = Theme.of(context);
    final TextEditingController searchCategoria = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Filtrar por categoría',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: StatefulBuilder(
                  builder: (context, setState) => TextField(
                    controller: searchCategoria,
                    decoration: InputDecoration(
                      hintText: 'Buscar categoría...',
                      prefixIcon: const Icon(Icons.search_outlined),
                      suffixIcon: searchCategoria.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_outlined),
                              onPressed: () {
                                searchCategoria.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),
              Expanded(
                child: Consumer2<CategoriaViewModel, ProductoViewModel>(
                  builder:
                      (context, categoriaViewModel, productoViewModel, child) {
                        final categoriasFiltradas = categoriaViewModel
                            .categorias
                            .where(
                              (c) => c.nombre.toLowerCase().contains(
                                searchCategoria.text.toLowerCase(),
                              ),
                            )
                            .toList();

                        return ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            Card(
                              color:
                                  productoViewModel.categoriaSeleccionada ==
                                      null
                                  ? theme.colorScheme.primaryContainer
                                  : null,
                              child: ListTile(
                                leading: Icon(
                                  Icons.all_inclusive,
                                  color:
                                      productoViewModel.categoriaSeleccionada ==
                                          null
                                      ? theme.colorScheme.onPrimaryContainer
                                      : null,
                                ),
                                title: Text(
                                  'Todas las categorías',
                                  style: TextStyle(
                                    fontWeight:
                                        productoViewModel
                                                .categoriaSeleccionada ==
                                            null
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                                trailing:
                                    productoViewModel.categoriaSeleccionada ==
                                        null
                                    ? Icon(
                                        Icons.check_circle,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                                onTap: () {
                                  productoViewModel.setCategoria(null);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...categoriasFiltradas.map((categoria) {
                              final isSelected =
                                  productoViewModel.categoriaSeleccionada ==
                                  categoria.id;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                    : null,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.category_outlined,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : null,
                                  ),
                                  title: Text(
                                    categoria.nombre,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: theme.colorScheme.primary,
                                        )
                                      : null,
                                  onTap: () {
                                    productoViewModel.setCategoria(
                                      categoria.id,
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            }),
                          ],
                        );
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarFiltros() {
    final theme = Theme.of(context);
    final productoViewModel = Provider.of<ProductoViewModel>(
      context,
      listen: false,
    );
    final tempSearchController = TextEditingController(
      text: _searchController.text,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Buscar y filtrar productos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: tempSearchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: tempSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          tempSearchController.clear();
                          _searchController.clear();
                          productoViewModel.setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
              onChanged: (value) {
                _searchController.text = value;
                productoViewModel.setSearchQuery(value);
              },
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showFiltroCategoria();
              },
              icon: const Icon(Icons.category_outlined),
              label: const Text('Filtrar por categoría'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _searchController.clear();
                      productoViewModel.setSearchQuery('');
                      productoViewModel.setCategoria(null);
                    },
                    child: const Text('Limpiar todo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isAdmin = authViewModel.currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: _modoSeleccion
            ? Text('${_productosSeleccionados.length} seleccionados')
            : const Text(
                'Productos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
        leading: _modoSeleccion
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleModoSeleccion,
              )
            : null,
        actions: [
          if (!_modoSeleccion) ...[
            Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) {
                final isAdmin = authViewModel.currentUser?.isAdmin ?? false;
                if (!isAdmin) return const SizedBox.shrink();

                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_outlined),
                  onSelected: (value) {
                    if (value == 'exportar_todos') {
                      _exportarTodosLosProductos();
                    } else if (value == 'exportar_seleccionados') {
                      _toggleModoSeleccion();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'exportar_todos',
                      child: Row(
                        children: [
                          Icon(Icons.download_outlined),
                          SizedBox(width: 12),
                          Text('Exportar todos (CSV)'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'exportar_seleccionados',
                      child: Row(
                        children: [
                          Icon(Icons.checklist_outlined),
                          SizedBox(width: 12),
                          Text('Exportar selección (CSV)'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Consumer<ProductoViewModel>(
              builder: (context, productoViewModel, child) {
                final hayFiltros =
                    productoViewModel.searchQuery.isNotEmpty ||
                    productoViewModel.categoriaSeleccionada != null;

                return IconButton(
                  onPressed: _mostrarFiltros,
                  icon: Badge(
                    isLabelVisible: hayFiltros,
                    child: const Icon(Icons.filter_list_outlined),
                  ),
                  tooltip: 'Buscar y filtrar',
                );
              },
            ),
          ],
        ],
      ),
      body: Consumer<ProductoViewModel>(
        builder: (context, productoViewModel, child) {
          if (productoViewModel.isLoading &&
              productoViewModel.productos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (productoViewModel.searchQuery.isNotEmpty ||
                  productoViewModel.categoriaSeleccionada != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (productoViewModel.searchQuery.isNotEmpty)
                        Chip(
                          avatar: const Icon(Icons.search, size: 18),
                          label: Text(
                            'Búsqueda: "${productoViewModel.searchQuery}"',
                          ),
                          onDeleted: () {
                            _searchController.clear();
                            productoViewModel.setSearchQuery('');
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (productoViewModel.categoriaSeleccionada != null)
                        Consumer<CategoriaViewModel>(
                          builder: (context, categoriaViewModel, child) {
                            final categoria = categoriaViewModel.categorias
                                .where(
                                  (c) =>
                                      c.id ==
                                      productoViewModel.categoriaSeleccionada,
                                )
                                .firstOrNull;
                            return Chip(
                              avatar: const Icon(Icons.filter_list, size: 18),
                              label: Text(categoria?.nombre ?? 'Categoría'),
                              onDeleted: () =>
                                  productoViewModel.setCategoria(null),
                              deleteIcon: const Icon(Icons.close, size: 18),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: productoViewModel.productos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay productos',
                              style: theme.textTheme.titleMedium,
                            ),
                            if (productoViewModel.categoriaSeleccionada !=
                                    null ||
                                productoViewModel.searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Prueba con otros filtros',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => productoViewModel.loadProductos(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: productoViewModel.productos.length,
                          itemBuilder: (context, index) {
                            final producto = productoViewModel.productos[index];
                            final isSeleccionado = _productosSeleccionados
                                .contains(producto.id);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  if (_modoSeleccion) {
                                    _toggleSeleccionProducto(producto.id);
                                  } else {
                                    _showProductoDetail(producto);
                                  }
                                },
                                onLongPress: !_modoSeleccion
                                    ? () {
                                        _toggleModoSeleccion();
                                        _toggleSeleccionProducto(producto.id);
                                      }
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      if (_modoSeleccion)
                                        Checkbox(
                                          value: isSeleccionado,
                                          onChanged: (_) =>
                                              _toggleSeleccionProducto(
                                                producto.id,
                                              ),
                                        ),
                                      Hero(
                                        tag: 'producto_${producto.id}',
                                        child:
                                            producto.imagen != null &&
                                                producto.imagen!.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  '${ApiConstants.baseUrl}/imagenes/${producto.imagen}',
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        color: theme
                                                            .colorScheme
                                                            .surfaceContainerHighest,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .inventory_2_outlined,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                        size: 32,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme
                                                      .surfaceContainerHighest,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.inventory_2_outlined,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  size: 32,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              producto.nombre,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 17,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Stock: ${producto.cantidadFormateada}',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isAdmin
          ? _modoSeleccion
                ? FloatingActionButton.extended(
                    onPressed: _exportarProductosSeleccionados,
                    icon: const Icon(Icons.download_outlined),
                    label: Text('Descargar ${_productosSeleccionados.length}'),
                    backgroundColor: theme.colorScheme.primary,
                  )
                : FloatingActionButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductoFormScreen(),
                        ),
                      );
                      if (result == true) {
                        if (!context.mounted) return;
                        final productoViewModel =
                            Provider.of<ProductoViewModel>(
                              context,
                              listen: false,
                            );
                        productoViewModel.loadProductos();
                      }
                    },
                    tooltip: 'Nuevo producto',
                    child: const Icon(Icons.add, size: 36),
                  )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
