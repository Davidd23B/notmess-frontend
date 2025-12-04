import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../data/models/categoria_producto.dart';
import '../viewmodels/categoria_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../core/utils/error_dialog.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CategoriaViewModel>(context, listen: false);
      viewModel.limpiarFiltros();
      viewModel.loadCategorias();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoriaDialog({CategoriaProducto? categoria}) {
    showDialog(
      context: context,
      builder: (context) => _CategoriaDialog(categoria: categoria),
    );
  }

  void _mostrarFiltros() {
    final theme = Theme.of(context);
    final tempController = TextEditingController(text: _searchController.text);

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
              'Buscar categorías',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: tempController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                hintStyle: const TextStyle(fontSize: 16),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: tempController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          tempController.clear();
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _searchController.text = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    child: const Text(
                      'Limpiar todo',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(fontSize: 16),
                    ),
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

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Categorías')),
        body: const Center(
          child: Text('No tienes permisos para acceder a este módulo'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categorías',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _mostrarFiltros,
            icon: Badge(
              isLabelVisible: _searchQuery.isNotEmpty,
              child: const Icon(Icons.filter_list_outlined),
            ),
            tooltip: 'Buscar',
          ),
        ],
      ),
      body: Consumer<CategoriaViewModel>(
        builder: (context, categoriaViewModel, child) {
          final categoriasFiltradas = _searchQuery.isEmpty
              ? categoriaViewModel.categorias
              : categoriaViewModel.categorias
                    .where(
                      (cat) => cat.nombre.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

          if (categoriaViewModel.isLoading &&
              categoriaViewModel.categorias.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (_searchQuery.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  width: double.infinity,
                  child: Chip(
                    avatar: const Icon(Icons.search, size: 18),
                    label: Text('Búsqueda: "$_searchQuery"'),
                    onDeleted: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
                ),
              Expanded(
                child: categoriasFiltradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No se encontraron categorías'
                                  : 'No hay categorías',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => categoriaViewModel.loadCategorias(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: categoriasFiltradas.length,
                          itemBuilder: (context, index) {
                            final categoria = categoriasFiltradas[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.category_outlined,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                title: Text(
                                  categoria.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _showCategoriaDialog(
                                        categoria: categoria,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.error,
                                      ),
                                      onPressed: () async {
                                        final categoriaViewModel = Provider.of<CategoriaViewModel>(
                                          context,
                                          listen: false,
                                        );
                                        
                                        final categoriaId = categoria.id;
                                        final categoriaNombre = categoria.nombre;
                                        
                                        final success = await categoriaViewModel.deleteCategoria(categoriaId);
                                        
                                        if (!context.mounted) return;
                                        
                                        if (!success) {
                                          await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('No se puede eliminar'),
                                              content: Text(
                                                'Primero debe reasignar o eliminar los productos de la categoría "$categoriaNombre".',
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                              actions: [
                                                FilledButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Aceptar'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoriaDialog(),
        tooltip: 'Agregar categoría',
        child: const Icon(Icons.add, size: 36),
      ),
    );
  }
}

class _CategoriaDialog extends StatefulWidget {
  final CategoriaProducto? categoria;

  const _CategoriaDialog({this.categoria});

  @override
  State<_CategoriaDialog> createState() => _CategoriaDialogState();
}

class _CategoriaDialogState extends State<_CategoriaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nombreController.text = widget.categoria!.nombre;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final categoriaViewModel = Provider.of<CategoriaViewModel>(
      context,
      listen: false,
    );

    final categoria = CategoriaProducto(
      idCategoria: widget.categoria?.idCategoria ?? 0,
      nombre: _nombreController.text.trim(),
    );

    final success = widget.categoria == null
        ? await categoriaViewModel.createCategoria(categoria)
        : await categoriaViewModel.updateCategoria(
            widget.categoria!.idCategoria,
            categoria,
          );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ErrorDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.categoria != null;

    return AlertDialog(
      title: Text(isEdit ? 'Editar Categoría' : 'Nueva Categoría'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.category_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa el nombre de la categoría';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }
}
