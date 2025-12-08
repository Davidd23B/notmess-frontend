import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/error_dialog.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../data/models/usuario.dart';
import '../../data/services/usuario_service.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final UsuarioService _usuarioService = UsuarioService();
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filtroRol;
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    _limpiarFiltros();
    _loadUsuarios();
    _searchController.addListener(_filtrarUsuarios);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filtroRol = null;
      _filtroEstado = null;
    });
  }

  void _filtrarUsuarios() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _usuariosFiltrados = _usuarios.where((usuario) {
        final matchNombre =
            _searchQuery.isEmpty ||
            usuario.nombre.toLowerCase().contains(_searchQuery);

        final matchRol =
            _filtroRol == null ||
            (_filtroRol == 'admin' && usuario.isAdmin) ||
            (_filtroRol == 'usuario' && !usuario.isAdmin);

        final matchEstado =
            _filtroEstado == null ||
            (_filtroEstado == 'activo' && usuario.activo) ||
            (_filtroEstado == 'inactivo' && !usuario.activo);

        return matchNombre && matchRol && matchEstado;
      }).toList();
    });
  }

  Future<void> _loadUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usuarios = await _usuarioService.getUsuarios();
      usuarios.sort((a, b) {
        if (a.activo && !b.activo) return -1;
        if (!a.activo && b.activo) return 1;
        return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      });
      setState(() {
        _usuarios = usuarios;
        _usuariosFiltrados = usuarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUsuarioDialog({Usuario? usuario}) {
    showDialog(
      context: context,
      builder: (context) =>
          _UsuarioDialog(usuario: usuario, onSuccess: _loadUsuarios),
    );
  }

  void _mostrarFiltros() {
    final theme = Theme.of(context);
    final tempController = TextEditingController(text: _searchController.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                'Buscar usuarios',
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
                            });
                            Navigator.pop(context);
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
                },
              ),
              const SizedBox(height: 24),
              Text('Rol', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _filtroRol == null,
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        _filtroRol = null;
                        _filtrarUsuarios();
                      });
                      setModalState(() {});
                    },
                    side: _filtroRol == null
                        ? const BorderSide(
                            color: AppTheme.filterBorderSelected,
                            width: 2.5,
                          )
                        : null,
                  ),
                  FilterChip(
                    label: const Text('Administradores'),
                    selected: _filtroRol == 'admin',
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        _filtroRol = selected ? 'admin' : null;
                        _filtrarUsuarios();
                      });
                      setModalState(() {});
                    },
                    side: _filtroRol == 'admin'
                        ? const BorderSide(
                            color: AppTheme.filterBorderSelected,
                            width: 2.5,
                          )
                        : null,
                  ),
                  FilterChip(
                    label: const Text('Usuarios'),
                    selected: _filtroRol == 'usuario',
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        _filtroRol = selected ? 'usuario' : null;
                        _filtrarUsuarios();
                      });
                      setModalState(() {});
                    },
                    side: _filtroRol == 'usuario'
                        ? const BorderSide(
                            color: AppTheme.filterBorderSelected,
                            width: 2.5,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Estado', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _filtroEstado == null,
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        _filtroEstado = null;
                        _filtrarUsuarios();
                      });
                      setModalState(() {});
                    },
                    side: _filtroEstado == null
                        ? const BorderSide(
                            color: AppTheme.filterBorderSelected,
                            width: 2.5,
                          )
                        : null,
                  ),
                  FilterChip(
                    label: const Text('Activos'),
                    selected: _filtroEstado == 'activo',
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        _filtroEstado = selected ? 'activo' : null;
                        _filtrarUsuarios();
                      });
                      setModalState(() {});
                    },
                    side: _filtroEstado == 'activo'
                        ? const BorderSide(
                            color: AppTheme.filterBorderSelected,
                            width: 2.5,
                          )
                        : null,
                  ),
                  FilterChip(
                    label: const Text('Inactivos'),
                    selected: _filtroEstado == 'inactivo',
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        _filtroEstado = selected ? 'inactivo' : null;
                        _filtrarUsuarios();
                      });
                      setModalState(() {});
                    },
                    side: _filtroEstado == 'inactivo'
                        ? const BorderSide(
                            color: AppTheme.filterBorderSelected,
                            width: 2.5,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _filtroRol = null;
                          _filtroEstado = null;
                          _filtrarUsuarios();
                        });
                        setModalState(() {});
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
        appBar: AppBar(title: const Text('Usuarios')),
        body: const Center(
          child: Text('No tienes permisos para acceder a este módulo'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Usuarios',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _mostrarFiltros,
            icon: Badge(
              isLabelVisible:
                  _searchQuery.isNotEmpty ||
                  _filtroRol != null ||
                  _filtroEstado != null,
              child: const Icon(Icons.filter_list_outlined),
            ),
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty ||
              _filtroRol != null ||
              _filtroEstado != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_searchQuery.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.search, size: 18),
                      label: Text('"$_searchQuery"'),
                      onDeleted: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                  if (_filtroRol != null)
                    Chip(
                      avatar: const Icon(Icons.shield_outlined, size: 18),
                      label: Text(
                        _filtroRol == 'admin' ? 'Administradores' : 'Usuarios',
                      ),
                      onDeleted: () {
                        setState(() {
                          _filtroRol = null;
                          _filtrarUsuarios();
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                  if (_filtroEstado != null)
                    Chip(
                      avatar: const Icon(Icons.circle, size: 18),
                      label: Text(
                        _filtroEstado == 'activo' ? 'Activos' : 'Inactivos',
                      ),
                      onDeleted: () {
                        setState(() {
                          _filtroEstado = null;
                          _filtrarUsuarios();
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading && _usuarios.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _usuariosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No se encontraron usuarios'
                              : 'No hay usuarios',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUsuarios,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _usuariosFiltrados.length,
                      itemBuilder: (context, index) {
                        final usuario = _usuariosFiltrados[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: usuario.isAdmin
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                                  child: Icon(
                                    usuario.isAdmin
                                        ? Icons.admin_panel_settings_outlined
                                        : Icons.person_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              usuario.nombre,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                color: usuario.activo
                                                    ? null
                                                    : AppTheme.estadoInactivo,
                                              ),
                                            ),
                                          ),
                                          if (!usuario.activo) ...[
                                            const SizedBox(width: 8),
                                            Chip(
                                              label: const Text(
                                                'Inactivo',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor:
                                                  AppTheme.estadoInactivo,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                  ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Chip(
                                        label: Text(
                                          usuario.isAdmin
                                              ? 'Administrador'
                                              : 'Usuario',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        backgroundColor: usuario.activo
                                            ? (usuario.isAdmin
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.secondary)
                                            : Colors.grey.shade400,
                                        labelStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ),
                                if (usuario.activo &&
                                    usuario.id !=
                                        authViewModel.currentUser?.id) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () =>
                                        _showUsuarioDialog(usuario: usuario),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppTheme.error,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Confirmar desactivación',
                                          ),
                                          content: Text(
                                            '¿Estás seguro de desactivar al usuario "${usuario.nombre}"? No podrá iniciar sesión.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: AppTheme.error,
                                              ),
                                              child: const Text('Desactivar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        try {
                                          await _usuarioService.deleteUsuario(
                                            usuario.id,
                                          );
                                          _loadUsuarios();
                                        } catch (e) {
                                          if (context.mounted) {
                                            ErrorDialog.show(context);
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ] else if (!usuario.activo)
                                  SizedBox(
                                    width: 96,
                                    child: FilledButton.icon(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Confirmar activación',
                                            ),
                                            content: Text(
                                              '¿Deseas activar al usuario "${usuario.nombre}"? Podrá iniciar sesión.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancelar'),
                                              ),
                                              FilledButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      AppTheme.estadoActivo,
                                                ),
                                                child: const Text('Activar'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            await _usuarioService
                                                .activateUsuario(usuario.id);
                                            _loadUsuarios();
                                          } catch (e) {
                                            if (context.mounted) {
                                              ErrorDialog.show(context);
                                            }
                                          }
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Activar',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppTheme.estadoActivo,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                    ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUsuarioDialog(),
        tooltip: 'Agregar usuario',
        child: const Icon(Icons.add, size: 36),
      ),
    );
  }
}

class _UsuarioDialog extends StatefulWidget {
  final Usuario? usuario;
  final VoidCallback onSuccess;

  const _UsuarioDialog({this.usuario, required this.onSuccess});

  @override
  State<_UsuarioDialog> createState() => _UsuarioDialogState();
}

class _UsuarioDialogState extends State<_UsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _passwdController = TextEditingController();
  final UsuarioService _usuarioService = UsuarioService();
  String _rolSeleccionado = 'usuario';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _nombreController.text = widget.usuario!.nombre;
      _rolSeleccionado = widget.usuario!.rol;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _passwdController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final usuario = Usuario(
        idUsuario: widget.usuario?.idUsuario ?? 0,
        nombre: _nombreController.text.trim(),
        passwd: _passwdController.text.isNotEmpty
            ? _passwdController.text
            : null,
        rol: _rolSeleccionado,
      );

      if (widget.usuario == null) {
        await _usuarioService.createUsuario(usuario);
      } else {
        await _usuarioService.updateUsuario(widget.usuario!.idUsuario, usuario);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorDialog.show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.usuario != null;

    return AlertDialog(
      title: Text(isEdit ? 'Editar Usuario' : 'Nuevo Usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre de usuario';
                  }
                  return null;
                },
                autofocus: !isEdit,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwdController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: isEdit
                      ? 'Nueva contraseña (opcional)'
                      : 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                  helperText: isEdit
                      ? 'Dejar vacío para mantener la actual'
                      : null,
                ),
                validator: (value) {
                  if (!isEdit && (value == null || value.isEmpty)) {
                    return 'Ingresa una contraseña';
                  }
                  if (value != null && value.isNotEmpty && value.length < 4) {
                    return 'Mínimo 4 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _rolSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(
                    _rolSeleccionado == 'admin'
                        ? Icons.shield_outlined
                        : Icons.person_outline,
                  ),
                  border: const OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _rolSeleccionado = value!);
                },
              ),
            ],
          ),
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
