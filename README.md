# NotMess - Aplicación Móvil Flutter

Aplicación móvil para la gestión de inventario y control APPCC del restaurante NotMess.

## 🎨 Características

- **Autenticación**: Login con JWT y persistencia de sesión
- **Dashboard**: Acceso rápido a módulos según rol de usuario
- **Productos**: CRUD completo con búsqueda y filtros por categoría
- **Albaranes**: Gestión de entradas, salidas y mermas con líneas de detalle
- **Categorías**: Administración de categorías de productos (solo admin)
- **Usuarios**: Gestión de usuarios y roles (solo admin)
- **Tema**: Material Design 3 con paleta naranja profesional
- **Arquitectura**: MVVM con Provider para state management

## 📋 Requisitos Previos

- Flutter SDK 3.10.1 o superior
- Dart 3.10.1 o superior
- Android Studio / VS Code con extensiones de Flutter
- Backend NotMess ejecutándose en `http://localhost:8080`

## 🚀 Instalación

1. **Clonar el repositorio** (si aplica) o navegar a la carpeta del proyecto:
```bash
cd notmess_frontend
```

2. **Instalar dependencias**:
```bash
flutter pub get
```

3. **Verificar la configuración**:
```bash
flutter doctor
```

## ▶️ Ejecución

### Modo desarrollo

```bash
flutter run
```

### Seleccionar dispositivo específico

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device_id>
```

### Ejecutar en Chrome (Web)

```bash
flutter run -d chrome
```

## 🔧 Configuración del Backend

Por defecto, la aplicación se conecta a `http://localhost:8080`. Para cambiar la URL:

1. Abrir `lib/core/constants/api_constants.dart`
2. Modificar la constante `baseUrl`:

```dart
static const String baseUrl = 'http://TU_IP:8080';
```

**Nota**: Para pruebas en dispositivos físicos Android, usar la IP local de tu PC en lugar de `localhost`.

## 👥 Usuarios de Prueba

Dependiendo de los usuarios configurados en el backend:

- **Admin**: Acceso completo a todos los módulos
  - Puede crear/editar/eliminar productos, albaranes, categorías y usuarios
  
- **Usuario**: Acceso limitado
  - Puede ver productos y albaranes
  - Puede crear albaranes
  - Sin acceso a gestión de categorías y usuarios

## 📱 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/        # Constantes (API endpoints, etc.)
│   └── theme/           # Tema y colores de la aplicación
├── data/
│   ├── models/          # Modelos de datos (Usuario, Producto, etc.)
│   └── services/        # Servicios API (HTTP requests)
├── presentation/
│   ├── screens/         # Pantallas de la aplicación
│   └── viewmodels/      # ViewModels (lógica de negocio)
└── main.dart           # Punto de entrada
```

## 🎯 Módulos Implementados

### ✅ Productos
- Lista con búsqueda en tiempo real
- Filtros por categoría
- Formulario de creación/edición con validaciones
- Validación de medidas (unidad: enteros, kg/L: decimales)
- Control de permisos por rol

### ✅ Albaranes
- Lista con filtros por tipo (entrada/salida/merma)
- Wizard de creación con múltiples líneas
- Motivo obligatorio para mermas
- Vista de detalle con todas las líneas
- Validación de stock automática

### ✅ Categorías (Admin only)
- CRUD completo en diálogos
- Validación antes de eliminar

### ✅ Usuarios (Admin only)
- Gestión de usuarios con roles
- Contraseñas encriptadas
- Edición de datos sin cambiar contraseña

### ✅ APPCC (Control completo)
- Lista de registros con filtros por turno
- Wizard de creación con 5 pasos:
  1. Información general y turno
  2. Control de limpieza (checkboxes)
  3. Control de temperatura (equipos)
  4. Control de productos (estado + temperatura)
  5. Control de freidoras (temperatura + TPM)
- Vista de detalle de registros
- 4 subtablas relacionadas (limpieza, temperatura, producto, freidora)
- Validación de datos y observaciones por sección

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de UI
- **Provider**: State management (patrón MVVM)
- **http**: Cliente HTTP para API REST
- **shared_preferences**: Persistencia local (tokens)
- **intl**: Formateo de fechas y números

## 📝 Validaciones Implementadas

- **Productos**: 
  - Nombre requerido
  - Categoría requerida
  - Precio > 0
  - Cantidad según medida (unidad=enteros, kg/L=decimales)

- **Albaranes**:
  - Tipo requerido
  - Motivo obligatorio si tipo=merma
  - Al menos una línea de producto
  - Cantidad según medida del producto

- **Usuarios**:
  - Nombre único
  - Contraseña mínimo 4 caracteres
  - Rol requerido

## 🐛 Troubleshooting

### Error de conexión al backend
- Verificar que el backend esté ejecutándose
- Comprobar la URL en `api_constants.dart`
- En Android físico, usar la IP local en lugar de localhost

### Error de compilación
```bash
flutter clean
flutter pub get
flutter run
```

### Hot reload no funciona
- Usar hot restart: `R` en la consola
- O reiniciar la aplicación completamente

## 📄 Licencia

Proyecto privado para NotMess Restaurant.

---

**Desarrollado con ❤️ usando Flutter**
