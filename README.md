<div align="center">
  <img src="https://raw.githubusercontent.com/edagrex-sketch/Mascota-saludable/main/assets/icon.png" alt="Mascota Saludable" width="120" height="120"/>

  # 🐾 Mascota Saludable

  **Gestor Móvil de Salud para Mascotas**

  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-3.24-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/Dart-3.4-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
    <img src="https://img.shields.io/badge/Supabase-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase">
    <img src="https://img.shields.io/badge/FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="FCM">
    <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
    <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS">
  </p>

  <p align="center">
    <a href="#-características">Características</a> •
    <a href="#-tecnologías">Tecnologías</a> •
    <a href="#-capturas">Capturas</a> •
    <a href="#-estructura">Estructura</a> •
    <a href="#-comenzando">Comenzando</a> •
    <a href="#-equipo">Equipo</a>
  </p>
</div>

---

## 📱 Descripción

**Mascota Saludable** es una aplicación móvil multiplataforma que permite a los dueños de mascotas **digitalizar y gestionar fácilmente** la información de salud de sus animales de compañía. Lleva un control completo de tus mascotas desde la palma de tu mano.

> 🎯 **Objetivo:** Digitalizar de forma fácil la gestión de datos del cuidado de las mascotas.

---

## ✨ Características

<div align="center">
  <table>
    <tr>
      <td align="center">🔐</td>
      <td><b>Autenticación</b><br/>Login seguro con sesión persistente mediante Supabase Auth</td>
      <td align="center">🐕</td>
      <td><b>Registro de Mascotas</b><br/>Registra, edita y consulta tus mascotas</td>
    </tr>
    <tr>
      <td align="center">💉</td>
      <td><b>Historial de Vacunas</b><br/>Controla el calendario de vacunación de cada mascota</td>
      <td align="center">🏥</td>
      <td><b>Visitas Veterinarias</b><br/>Registra y consulta el historial médico</td>
    </tr>
    <tr>
      <td align="center">📊</td>
      <td><b>Dashboard</b><br/>Indicadores clave: mascotas, vacunas próximas, visitas recientes</td>
      <td align="center">🔔</td>
      <td><b>Notificaciones Push</b><br/>Recordatorios de vacunas y cuidados con FCM</td>
    </tr>
  </table>
</div>

---

## 🛠️ Tecnologías

| Tecnología | Propósito |
|---|---|
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" width="18" /> **Flutter** | Framework UI multiplataforma (Android + iOS) |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" width="18" /> **Dart** | Lenguaje de programación |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/supabase/supabase-original.svg" width="18" /> **Supabase** | Backend: Autenticación, Base de datos PostgreSQL, Storage |
| 🔥 **Firebase Cloud Messaging** | Notificaciones push |

---

## 📸 Capturas de Pantalla

<p align="center">
  <i>🖼️ Próximamente — Las capturas se agregarán cuando el desarrollo avance.</i>
</p>

<!-- Cuando tengas capturas, descomenta y agrega:
<p align="center">
  <img src="assets/screenshots/login.png" width="200" alt="Login" />
  <img src="assets/screenshots/dashboard.png" width="200" alt="Dashboard" />
  <img src="assets/screenshots/pets.png" width="200" alt="Mascotas" />
  <img src="assets/screenshots/vaccines.png" width="200" alt="Vacunas" />
</p>
-->

---

## 📁 Estructura del Proyecto

```
lib/
├── core/                     # Configuración central
│   ├── theme/                # Tema y estilos
│   ├── routes/               # Rutas de navegación
│   ├── services/             # Servicios compartidos
│   └── utils/                # Utilidades
├── features/                 # Módulos funcionales
│   ├── auth/                 # Autenticación
│   ├── pets/                 # Gestión de mascotas
│   ├── vaccinations/         # Historial de vacunas
│   ├── medical_visits/       # Visitas veterinarias
│   ├── dashboard/            # Panel principal
│   └── notifications/        # Notificaciones y sugerencias
├── shared/                   # Recursos compartidos
│   ├── widgets/              # Widgets reutilizables
│   └── models/               # Modelos de datos
└── main.dart                 # Punto de entrada
```

---

## 🚀 Comenzando

### Prerrequisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.24+)
- [Dart](https://dart.dev/get-dart) (v3.4+)
- Una cuenta en [Supabase](https://supabase.com)

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/edagrex-sketch/Mascota-saludable.git

# Entrar al directorio
cd Mascota-saludable

# Instalar dependencias
flutter pub get

# Configurar variables de entorno
# Copia el archivo de ejemplo y completa tus credenciales de Supabase
cp .env.example .env

# Ejecutar la app
flutter run
```

> ⚠️ **Nota:** El proyecto se encuentra en fase de planificación. Próximamente se agregarán las instrucciones detalladas de configuración de Supabase (tablas, RLS policies, etc.).

---

## 📦 Roadmap

### Sprint 1 — Fundación
- [x] Planificación y diseño de arquitectura
- [x] Configuración de repositorio
- [ ] Scaffold del proyecto Flutter
- [ ] Configuración de Supabase (Auth, DB, Storage)

### Sprint 2 — Núcleo
- [ ] Autenticación de usuarios
- [ ] CRUD de mascotas
- [ ] Historial de vacunas
- [ ] Visitas veterinarias

### Sprint 3 — Experiencia
- [ ] Dashboard con KPIs
- [ ] Sugerencias de cuidado
- [ ] Notificaciones push
- [ ] QA y despliegue

---

## 👥 Equipo

| | Eduardo | Neyser |
|---|---|---|
| **Rol** | Backend, Base de Datos, Lógica de Negocio | Frontend Flutter, UI/UX, Dashboard |
| **GitHub** | [@edagrex-sketch](https://github.com/edagrex-sketch) | — |

---

<div align="center">
  <p>
    Desarrollado con 💙 para todos los amantes de las mascotas
  </p>
  <p>
    <a href="https://github.com/edagrex-sketch/Mascota-saludable/issues">Reportar un problema</a> •
    <a href="https://github.com/edagrex-sketch/Mascota-saludable/issues">Sugerir una funcionalidad</a>
  </p>
</div>
