# 📱 NotMess Frontend - Aplicación Móvil

> Aplicación Flutter para la gestión de inventario y control APPCC en establecimientos de hostelería

---

## 📖 Descripción

Esta es la aplicación móvil multiplataforma de NotMess, desarrollada con Flutter. Proporciona una interfaz intuitiva y moderna para que los usuarios gestionen productos, albaranes, controles APPCC y más desde sus dispositivos móviles.

---

## 🏗️ Arquitectura del Proyecto

El proyecto sigue una arquitectura **MVVM (Model-View-ViewModel)** limpia y escalable:

```
lib/
├── 🎯 main.dart                      # Punto de entrada de la aplicación
│
├── 📦 core/                          # Núcleo de la aplicación
│   ├── constants/                    # Constantes globales
│   │   └── api_constants.dart       # URLs y endpoints de la API
│   ├── theme/                        # Configuración del tema
│   │   └── app_theme.dart           # Colores y estilos
│   └── utils/                        # Utilidades compartidas
│       ├── error_dialog.dart        # Diálogos de error
│       └── file_helper.dart         # Manejo de archivos
│
├── 📊 data/                          # Capa de datos
│   ├── models/                       # Modelos de datos (DTOs)
│   │   ├── producto.dart
│   │   ├── albaran.dart
│   │   ├── appcc.dart
│   │   ├── usuario.dart
│   │   └── categoria_producto.dart
│   └── services/                     # Servicios de comunicación
│       ├── api_service.dart         # Cliente HTTP base
│       ├── producto_service.dart    # Endpoints de productos
│       ├── albaran_service.dart     # Endpoints de albaranes
│       ├── appcc_service.dart       # Endpoints de APPCC
│       ├── usuario_service.dart     # Endpoints de usuarios
│       ├── auth_service.dart        # Autenticación
│       └── csv_service.dart         # Exportación a CSV
│
└── 🎨 presentation/                  # Capa de presentación (UI)
    ├── screens/                      # Pantallas de la aplicación
    │   ├── login_screen.dart        # Inicio de sesión
    │   ├── home_screen.dart         # Pantalla principal
    │   ├── productos_screen.dart    # Lista de productos
    │   ├── producto_form_screen.dart # Crear/editar producto
    │   ├── albaranes_screen.dart    # Lista de albaranes
    │   ├── albaran_create_screen.dart # Crear albarán
    │   ├── appcc_screen.dart        # Lista de APPCC
    │   ├── appcc_form_screen.dart   # Crear/editar APPCC
    │   ├── appcc_detail_screen.dart # Detalles de APPCC
    │   ├── usuarios_screen.dart     # Gestión de usuarios
    │   └── categorias_screen.dart   # Gestión de categorías
    │
    └── viewmodels/                   # ViewModels (Lógica de presentación)
        ├── auth_viewmodel.dart      # Estado de autenticación
        ├── producto_viewmodel.dart  # Estado de productos
        ├── albaran_viewmodel.dart   # Estado de albaranes
        ├── appcc_viewmodel.dart     # Estado de APPCC
        ├── usuario_viewmodel.dart   # Estado de usuarios
        └── categoria_viewmodel.dart # Estado de categorías
```

---

## 🔑 Componentes Principales

### 1. 🎯 Main.dart
**Función**: Punto de entrada de la aplicación

**Responsabilidades**:
- Configurar providers de estado global
- Establecer tema de la aplicación
- Definir rutas iniciales

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProductoViewModel()),
        // ... más providers
      ],
      child: const MyApp(),
    ),
  );
}
```

### 2. 📦 Models (Modelos)
**Función**: Representar entidades de datos

**Características**:
- Mapeo JSON ↔ Objeto Dart
- Validación de datos
- Getters calculados útiles

**Ejemplo - producto.dart**:
```dart
class Producto {
  final int idProducto;
  final String nombre;
  final double cantidad;
  final String medida;
  final String? imagenUrl;
  
  // Getter calculado
  String get cantidadFormateada => 
      medida == 'unidad' ? cantidad.toInt().toString() : cantidad.toString();
  
  // Conversión desde JSON
  factory Producto.fromJson(Map<String, dynamic> json) { ... }
  
  // Conversión a JSON
  Map<String, dynamic> toJson() { ... }
}
```

### 3. 🌐 Services (Servicios)
**Función**: Comunicación con la API REST

**Características**:
- Manejo de peticiones HTTP
- Gestión de errores
- Parseo de respuestas
- Autenticación con tokens

**Ejemplo - producto_service.dart**:
```dart
class ProductoService {
  final ApiService _apiService = ApiService();
  
  Future<List<Producto>> getProductos() async {
    final response = await _apiService.get('/productos');
    return (response as List)
        .map((json) => Producto.fromJson(json))
        .toList();
  }
  
  Future<Producto?> createProducto(Producto producto) async {
    final response = await _apiService.post(
      '/productos',
      body: producto.toJson(),
    );
    return Producto.fromJson(response);
  }
}
```

### 4. 🧠 ViewModels
**Función**: Gestión de estado y lógica de negocio

**Características**:
- Estado reactivo con `ChangeNotifier`
- Llamadas a servicios
- Manejo de loading y errores
- Filtros y búsquedas

**Ejemplo - producto_viewmodel.dart**:
```dart
class ProductoViewModel extends ChangeNotifier {
  final ProductoService _service = ProductoService();
  
  List<Producto> _productos = [];
  bool _isLoading = false;
  
  List<Producto> get productos => _productos;
  bool get isLoading => _isLoading;
  
  Future<void> loadProductos() async {
    _isLoading = true;
    notifyListeners();
    
    _productos = await _service.getProductos() ?? [];
    
    _isLoading = false;
    notifyListeners();
  }
}
```

### 5. 🎨 Screens (Pantallas)
**Función**: Interfaz de usuario

**Características**:
- Widgets reutilizables
- Consumo de ViewModels con `Consumer`
- Formularios con validación
- Navegación entre pantallas

**Ejemplo - productos_screen.dart**:
```dart
class ProductosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Productos')),
      body: Consumer<ProductoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return CircularProgressIndicator();
          }
          
          return ListView.builder(
            itemCount: viewModel.productos.length,
            itemBuilder: (context, index) {
              final producto = viewModel.productos[index];
              return ProductoCard(producto: producto);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(...),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## 🎨 Temas y Estilos

### Paleta de Colores

```dart
// Colores principales
- Primary: #FF6B35 (Naranja)
- Secondary: #4ECDC4 (Turquesa)
- Background: #FFFFFF (Blanco)

// Colores de albaranes
- Entrada: #4CAF50 (Verde)
- Salida: #2196F3 (Azul)
- Merma: #FF9800 (Naranja)

// Colores de estado
- Success: #4CAF50
- Error: #F44336
- Warning: #FF9800
```

### Componentes Material 3

- **Cards**: Elevación y bordes redondeados
- **Buttons**: FilledButton, OutlinedButton, TextButton
- **Inputs**: TextField con validación
- **Chips**: FilterChip para filtros
- **Dialogs**: Modales y alertas

---

## 📱 Flujos de Usuario

### 🔐 Autenticación

1. Usuario introduce email y contraseña
2. `AuthViewModel` llama a `AuthService.login()`
3. Backend devuelve token JWT
4. Token se guarda en `SharedPreferences`
5. Usuario redirigido a `HomeScreen`

### 📦 Crear Producto

1. Usuario toca botón "+" (solo admin)
2. Navega a `ProductoFormScreen`
3. Completa formulario (nombre, cantidad, categoría)
4. Opcionalmente selecciona imagen
5. `ProductoViewModel.createProducto()` llama a API
6. Lista de productos se actualiza automáticamente

### 📋 Crear Albarán

1. Usuario selecciona tipo (Entrada/Salida/Merma)
2. Modal muestra lista de productos disponibles
3. Usuario selecciona múltiples productos
4. Define cantidades para cada uno
5. Si es merma, añade motivo
6. `AlbaranViewModel.createAlbaran()` llama a API
7. Stock se actualiza automáticamente en backend

### 🧪 Control APPCC

1. Usuario crea nuevo registro APPCC
2. Selecciona turno (mañana/tarde/noche)
3. Navega por 5 pasos:
   - Información general
   - Control de limpieza (10 campos)
   - Control de temperatura (8 campos)
   - Control de productos (16 campos)
   - Control de freidoras (4 campos)
4. Puede añadir observaciones en cada sección
5. Sistema marca automáticamente completado
6. `AppccViewModel.createAppcc()` guarda todo

---

## 🔧 Configuración

### 📡 Configurar URL del Backend

Editar `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  // Desarrollo local
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Servidor de producción
  // static const String baseUrl = 'http://TU_IP:8080/api';
  
  // Endpoints
  static const String productos = '/productos';
  static const String albaranes = '/albaranes';
  static const String appcc = '/appcc';
  static const String usuarios = '/usuarios';
  static const String auth = '/auth';
}
```

### 🎨 Personalizar Tema

Editar `lib/core/theme/app_theme.dart`:

```dart
class AppTheme {
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF4ECDC4);
  
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      // ... más configuración
    );
  }
}
```

---

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Estado
  provider: ^6.1.1              # Gestión de estado
  
  # Networking
  http: ^1.2.0                  # Cliente HTTP
  
  # Almacenamiento
  shared_preferences: ^2.2.2    # Persistencia local
  
  # Imágenes
  image_picker: ^1.0.7          # Seleccionar imágenes
  file_picker: ^8.0.0+1         # Seleccionar archivos
  
  # Sistema de archivos
  path_provider: ^2.1.1         # Rutas del sistema
  permission_handler: ^11.0.1   # Permisos
  
  # Utilidades
  intl: ^0.20.2                 # Internacionalización/fechas
```

---

## 🚀 Comandos Útiles

### Desarrollo
```bash
# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Hot reload (durante desarrollo)
# Presionar 'r' en la terminal

# Hot restart (recarga completa)
# Presionar 'R' en la terminal
```

### Construcción
```bash
# Build APK (Android)
flutter build apk

# Build APK Split por ABI (más pequeño)
flutter build apk --split-per-abi

# Build App Bundle (para Play Store)
flutter build appbundle

# Build iOS (requiere Mac)
flutter build ios
```

### Mantenimiento
```bash
# Actualizar dependencias
flutter pub upgrade

# Limpiar build
flutter clean

# Ver información del doctor
flutter doctor

# Analizar código
flutter analyze

# Formatear código
dart format .
```

---

## 🐛 Debugging

### Ver Logs en Tiempo Real
```bash
flutter run --verbose
```

### Inspeccionar Estado
```dart
// En cualquier ViewModel
void debug() {
  print('Productos: ${_productos.length}');
  print('Loading: $_isLoading');
}
```

### DevTools
```bash
# Abrir DevTools en navegador
flutter pub global activate devtools
flutter pub global run devtools
```

---

## ✅ Características Implementadas

### Funcionalidad Completa
- ✅ Autenticación JWT con refresh automático
- ✅ CRUD completo de productos con imágenes
- ✅ Sistema de albaranes (entrada/salida/merma)
- ✅ Control APPCC con 4 secciones
- ✅ Gestión de usuarios y roles
- ✅ Filtros y búsqueda en todas las pantallas
- ✅ Exportación CSV (solo admin)
- ✅ Persistencia de sesión

### UX/UI
- ✅ Material Design 3
- ✅ Animaciones y transiciones
- ✅ Estados de carga
- ✅ Manejo de errores
- ✅ Validación de formularios
- ✅ Feedback visual

---

## 🎯 Próximas Mejoras

- [ ] Modo offline con sincronización
- [ ] Notificaciones push
- [ ] Estadísticas y gráficos
- [ ] Exportar APPCC a PDF
- [ ] Multi-idioma
- [ ] Tema oscuro

---

## 📚 Recursos de Aprendizaje

- [Flutter Documentation](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [Provider Package](https://pub.dev/packages/provider)
- [HTTP Package](https://pub.dev/packages/http)

---

