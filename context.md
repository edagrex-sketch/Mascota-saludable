Proyecto de Aplicación Móvil para el Seguimiento del Cuidado Digno de Mascotas
Documento de Contexto y Guía de Desarrollo
Versión:
1.0
Fecha:
Junio 2026
Equipo:
Neyser y Eduardo (Full Stack)Duración sugerida: 6 días hábiles full-time

ÍNDICE
Resumen del Proyecto

Problema y Objetivo

Tecnologías Definidas

Arquitectura del Proyecto

Módulos Funcionales de la App

Plan de Sprint

Base de Datos

Pantallas y Flujos

Buenas Prácticas

Cronograma Sugerido

1. RESUMEN DEL PROTECTOR
Nombre del Proyecto
Gestor Móvil de Salud para Mascotas (nombre provisional)

Tipo de Producto
Aplicación móvil para Android y iOS (PWA - Progressive Web App)

Objetivo General
Digitalizar de forma fácil la gestión de datos del cuidado de las mascotas, permitiendo consultar historial, visitas médicas, vacunación y recibir sugerencias de cuidado adecuadas.

Valor Innovador
Convierte un diario médico personal en una herramienta preventiva visual. Incluye:

Seguimiento de vacunas según estándares mexicanos

Historial médico completo

Diario fotográfico de cambios físicos (como pigmentación de nariz)

Registro de ingredientes de snacks caseros con verificación de seguridad

Recordatorios automáticos

Sugerencias de cuidado personalizadas

Tecnología
PWA (Progressive Web App) para acceso rápido desde el móvil mientras estás en el parque o en la veterinaria.

2. PROBLEMA Y OBJETIVO
Problema
Falta de control en el cuidado digno de mascotas:

Dueños que olvidan fechas de vacunación

No registran visitas veterinarias

Carecen de historial médico organizado

No tienen sugerencias de cuidado adaptadas

Pierden información importante sobre cambios físicos de sus mascotas

Objetivo
Crear una aplicación móvil que permita:

Registrar y gestionar datos de mascotas

Controlar historial de vacunación con recordatorios

Guardar consultas veterinarias y diagnósticos

Mantener diario fotográfico de cambios físicos

Verificar seguridad de ingredientes en snacks caseros

Recibir sugerencias de cuidado personalizadas

3. TECNOLOGÍAS DEFINIDAS
Stack Tecnológico Oficial
Componente	Tecnología	Justificación
Framework Móvil	Flutter	Una base de código para Android e iOS, interfaz consistente, buen rendimiento
Backend	Supabase	PostgreSQL, menor dependencia propietaria, ideal para datos estructurados
Notificaciones	Firebase Cloud Messaging	Recordatorios de vacunas y alertas
Control de Código	GitHub	Colaboración entre Neyser y Eduardo
Diseño	Figma	Prototipado y diseño UI/UX
Por qué Flutter + Supabase
Flutter: Single codebase, componentes reutilizables, Material 3 nativo

Supabase: PostgreSQL real, autenticación integrada, API automática, escalable

Ambos son gratuitos para empezar y tienen documentación excelente

4. ARQUITECTURA DEL PROYECTO
Estructura de Organización
IMPORTANTANTE: El trabajo se divide por módulos funcionales (features) de la app, NO por backend/frontend.

¿Por qué por módulos y no por back/front?
Neyser y Eduardo son ambos full stack

En Flutter, UI, lógica y datos van juntos naturalmente

Reduce conflictos de integración

Cada módulo es autónomo y funcional

Mejor coordinación y claridad sobre qué se espera de cada módulo

Estructura de Directorios Sugerida
text
lib/
├── core/                  # Configuración global, temas, constantes
├── features/              # Módulos funcionales de la app
│   ├── auth/              # Autenticación y login
│   ├── pets/              # Registro y gestión de mascotas
│   ├── vaccinations/      # Historial de vacunación
│   ├── veterinary/        # Consultas veterinarias
│   ├── dashboard/         # Pantalla principal con información prioritaria
│   ├── photo_diary/       # Diario fotográfico
│   ├── snacks/            # Verificador de ingredientes de snacks
│   └── reminders/         # Recordatorios y alertas
├── services/              # Servicios API, notificaciones
├── models/                # Modelos de datos
├── utils/                 # Utilidades y helpers
└── main.dart              # Punto de entrada
Cada Módulo Funcional debe incluir:
Objetivo del módulo

Pantallas necesarias

Modelos de datos

Lógica y servicios

UI y componentes

Pruebas básicas

5. MODULOS FUNCIONALES DE LA APP
MÓDULO 1: Autenticación (Auth)
Objetivo: Permitir que usuarios se registren y accedan a su cuenta de forma segura.

Pantallas:

Login (email/password)

Registro de nuevo usuario

Recuperación de password

Modelos:

User (id, email, name, created_at)

Funcionalidades:

Autenticación con Supabase Auth

Validación de campos

Mensajes de error claros

Redirección al dashboard después de login

MÓDULO 2: Gestión de Mascotas (Pets)
Objetivo: Registrar y gestionar información de las mascotas del usuario.

Pantallas:

Lista de mascotas (dashboard)

Detalle de mascota

Crear nueva mascota

Editar mascota

Modelos:

text
Pet (
  id,
  user_id,
  name,
  species,           // perro, gato, etc.
  breed,
  age,
  weight,
  color,
  photo_url,
  created_at
)
Funcionalidades:

Registrar mascota con foto

Editar información

Mostrar lista de todas las mascotas

Foto principal en dashboard

MÓDULO 3: Vacunación (Vaccinations)
Objetivo: Controlar historial de vacunación con recordatorios automáticos.

Pantallas:

Lista de vacunas de la mascota

Detalle de vacuna

Registrar nueva vacuna

Calendario de vacunación

Modelos:

text
Vaccination (
  id,
  pet_id,
  vaccine_name,
  date_given,
  date_next,         // Fecha próxima vacuna
  veterinarian,
  notes,
  created_at
)
Funcionalidades:

Registrar vacunas con fecha

Recordar próximas vacunas (Firebase Cloud Messaging)

Historial completo de vacunación

Vacunas según estándares mexicanos (rábia, polivalente, etc.)

Alertas visuales para vacunas pendientes

MÓDULO 4: Consultas Veterinarias (Veterinary)
Objetivo: Guardar historial de visitas al veterinario y diagnósticos.

Pantallas:

Lista de consultas

Detalle de consulta

Registrar nueva consulta

Calendario de visitas

Modelos:

text
VeterinaryVisit (
  id,
  pet_id,
  date,
  veterinarian_name,
  clinic_name,
  diagnosis,
  treatment,
  notes,
  cost,
  created_at
)
Funcionalidades:

Registrar consultas con diagnóstico

Guardar tratamiento recomendado

Historial de visitas

Recordatorio de próximas citas

MÓDULO 5: Dashboard Principal
Objetivo: Mostrar información prioritaria de todas las mascotas.

Pantallas:

Dashboard principal

Funcionalidades:

Lista de mascotas con foto

Vacunas pendientes próximas

Citas veterinarias próximas

Resumen rápido de salud

Navegación rápida a todos los módulos

Alertas importantes

MÓDULO 6: Diario Fotográfico (Photo Diary)
Objetivo: Registrar cambios físicos de las mascotas con fotos cronológicas.

Pantallas:

Lista de fotos por mascota

Detalle de foto

Agregar nueva foto

Timeline cronológico

Modelos:

text
PhotoDiary (
  id,
  pet_id,
  photo_url,
  description,       // Ej: "pigmentación de nariz cambió"
  date_taken,
  category,          // cambio_físico, salud, comportamiento
  created_at
)
Funcionalidades:

Agregar fotos con descripción

Categorizar cambios (pigmentación, peso, pelo, etc.)

Timeline cronológico

Comparar cambios visuales

Diario preventivo visual

MÓDULO 7: Verificador de Snacks (Snacks)
Objetivo: Registrar ingredientes de snacks caseros y verificar si son seguros.

Pantallas:

Lista de snacks registrados

Detalle de snack

Crear nuevo snack

Buscador de ingredientes

Modelos:

text
Snack (
  id,
  pet_id,
  name,
  ingredients,       // Array de ingredientes
  is_safe,
  notes,
  created_at
)

Ingredient (
  id,
  name,
  is_safe_for_pets,
  risks,             // Descripción de riesgos
  category
)
Funcionalidades:

Registrar snacks caseros con ingredientes

Verificar seguridad de cada ingrediente

Alertas si ingrediente es peligroso

Base de ingredientes seguros/inseguros

Sugerencias de snacks seguros

Ingredientes comunes a verificar:

Chocolate: ❌ PELIGROSO

Cebolla: ❌ PELIGROSO

Ajo: ❌ PELIGROSO

Manzana: ✅ SEGURO (sin semillas)

Zanahoria: ✅ SEGURO

Plátano: ✅ SEGURO

MÓDULO 8: Recordatorios (Reminders)
Objetivo: Emitir alertas automáticas para vacunas, citas y cuidados.

Pantallas:

Lista de recordatorios

Crear recordatorio manual

Configuración de alertas

Funcionalidades:

Recordatorios automáticos de vacunas (desde módulo Vaccinations)

Recordatorios de citas veterinarias (desde módulo Veterinary)

Recordatorios manuales personalizados

Notificaciones push con Firebase Cloud Messaging

Configuración de frecuencia de alertas

6. PLAN DE SPRINT
Meta del Sprint
Al finalizar el sprint, el equipo debe tener una app móvil funcional capaz de:

Autenticar usuarios

Registrar mascotas

Guardar historial de vacunación

Registrar consultas veterinarias

Mostrar dashboard con información prioritaria

Emitir recordatorios básicos

No es necesario terminar toda la plataforma
La meta es dejar una primera versión estable sobre Flutter y Supabase que permita iterar en siguientes sprints con:

Diario fotográfico completo

Alertas más avanzadas

Analítica

Nuevas funciones de cuidado

Entregables del Sprint
App compilada y ejecutable en Android e iOS

Backend en Supabase con tablas creadas

Autenticación funcional

Mínimo 3 módulos completos (Auth, Pets, Vaccinations)

Dashboard funcional

Recordatorios básicos implementados

7. BASE DE DATOS
Tablas en Supabase (PostgreSQL)
sql
-- Usuarios
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE,
  name TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Mascotas
CREATE TABLE pets (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name TEXT,
  species TEXT,
  breed TEXT,
  age INTEGER,
  weight DECIMAL,
  color TEXT,
  photo_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Vacunas
CREATE TABLE vaccinations (
  id UUID PRIMARY KEY,
  pet_id UUID REFERENCES pets(id),
  vaccine_name TEXT,
  date_given TIMESTAMP,
  date_next TIMESTAMP,
  veterinarian TEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Consultas Veterinarias
CREATE TABLE veterinary_visits (
  id UUID PRIMARY KEY,
  pet_id UUID REFERENCES pets(id),
  date TIMESTAMP,
  veterinarian_name TEXT,
  clinic_name TEXT,
  diagnosis TEXT,
  treatment TEXT,
  notes TEXT,
  cost DECIMAL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Diario Fotográfico
CREATE TABLE photo_diary (
  id UUID PRIMARY KEY,
  pet_id UUID REFERENCES pets(id),
  photo_url TEXT,
  description TEXT,
  date_taken TIMESTAMP,
  category TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Snacks
CREATE TABLE snacks (
  id UUID PRIMARY KEY,
  pet_id UUID REFERENCES pets(id),
  name TEXT,
  ingredients TEXT[],
  is_safe BOOLEAN,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Ingredientes (base de conocimiento)
CREATE TABLE ingredients (
  id UUID PRIMARY KEY,
  name TEXT UNIQUE,
  is_safe_for_pets BOOLEAN,
  risks TEXT,
  category TEXT
);

-- Recordatorios
CREATE TABLE reminders (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  title TEXT,
  description TEXT,
  due_date TIMESTAMP,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
Reglas de Seguridad (RLS)
Cada usuario solo ve sus propios datos

Pets, Vaccinations, etc. filtrados por user_id

Autenticación requerida para todas las consultas

8. PANTALLAS Y FLUJOS
Flujo Principal de Usuario
text
1. Login/Registro
   ↓
2. Dashboard (lista de mascotas)
   ↓
3. Seleccionar mascota
   ↓
4. Ver detalle completo de mascota
   ├─ Historial de vacunación
   ├─ Consultas veterinarias
   ├─ Diario fotográfico
   ├─ Snacks registrados
   └─ Configuración
Pantallas Principales
#	Pantalla	Módulo	Descripción
1	Login	Auth	Ingreso con email/password
2	Registro	Auth	Crear nueva cuenta
3	Dashboard	Dashboard	Lista de mascotas + alertas
4	Lista de Mascotas	Pets	Todas las mascotas del usuario
5	Detalle de Mascota	Pets	Información completa + navegación
6	Crear Mascota	Pets	Registrar nueva mascota
7	Lista de Vacunas	Vaccinations	Historial de vacunación
8	Registrar Vacuna	Vaccinations	Nueva vacuna con fecha
9	Calendario de Vacunas	Vaccinations	Vista cronológica
10	Lista de Consultas	Veterinary	Historial veterinario
11	Registrar Consulta	Veterinary	Nueva visita al veterinario
12	Timeline de Fotos	Photo Diary	Diario cronológico
13	Agregar Foto	Photo Diary	Nueva foto con descripción
14	Lista de Snacks	Snacks	Snacks registrados
15	Crear Snack	Snacks	Nuevo snack con ingredientes
16	Buscador de Ingredientes	Snacks	Verificar seguridad
17	Lista de Recordatorios	Reminders	Alertas programadas
18	Configuración	Reminders	Frecuencia de notificaciones
9. BUENAS PRÁCTICAS
Para Flutter
Estructura por Features

Organizar por módulos funcionales, no por backend/frontend

Cada feature tiene su propia carpeta con UI, lógica y datos

Tema Centralizado

Usar ThemeData en main.dart

Colores, tipografía y estilos en un solo lugar

Facilita cambios de diseño global

Componentes Reutilizables

Crear components personalizados para elementos repetitivos

Cards, Buttons, InputFields, Headers

Diseño Adaptativo

Usar LayoutBuilder y MediaQuery

Considerar diferentes tamaños de pantalla

Material 3

Usar componentes Material 3 nativos

Transiciones y animaciones del sistema

Nombres de Variables Claros

userProfile no up

isVaccinationPending no ivp

Para Supabase
Reglas de Seguridad (RLS)

Siempre implementar RLS en todas las tablas

Filtrar por user_id

Índices

Crear índices en campos frecuentemente consultados

user_id, pet_id, date

Naming Conventions

Tablas en snake_case: veterinary_visits

Campos en snake_case: date_given

Primary keys: id con tipo UUID

Feedback en UI

Mostrar mensajes de éxito/error claros

Loading indicators durante operaciones

Validación de campos antes de enviar

Para el Equipo (Neyser + Eduardo)
Trabajo Colaborativo

Ambos trabajan en cada módulo como full stack

Uno puede tomar prioridad visual, otro lógica principal

Pero ambos participan en el mismo módulo hasta cerrarlo

Comunicación

Reuniones rápidas每天 para sincronizar

GitHub para control de versiones

Figma para diseño compartido

Sin División Back/Front

No separar trabajo por backend/frontend

Dividir por funciones de la app

Cada módulo es autónomo

Pruebas

Testear cada módulo antes de integrar

Verificar en Android e iOS

Testear con datos reales

10. CRONOGRAMA SUGERIDO
6 Días Hábiles Full-Time
Día	Módulo	Actividades
1	Auth + Setup	- Setup de proyecto Flutter
- Configuración Supabase
- Login y Registro
- Autenticación funcional
2	Pets	- Tabla pets en Supabase
- Lista de mascotas
- Crear/editar mascota
- Foto y detalles
3	Vaccinations	- Tabla vaccinations
- Lista de vacunas
- Registrar nueva vacuna
- Recordatorios básicos
4	Veterinary	- Tabla veterinary_visits
- Lista de consultas
- Registrar consulta
- Historial completo
5	Dashboard	- Pantalla principal
- Resumen de mascotas
- Vacunas pendientes
- Citas próximas
- Navegación rápida
6	Reminders + Testing	- Firebase Cloud Messaging
- Notificaciones push
- Testing en Android/iOS
- corregir bugs
- Compilar app final
Sprints Posteriores (Opcional)
Sprint 2: Diario fotográfico completo + categorias

Sprint 3: Verificador de snacks + base de ingredientes

Sprint 4: Alertas avanzadas + analítica

Sprint 5: Nuevas funciones de cuidado personalizado

CONCLUSIONES
Estado del Proyecto
✅ Stack tecnológico definido: Flutter + Supabase

✅ Equipo organizado: Neyser y Eduardo (full stack)

✅ Organización por módulos funcionales (no back/front)

✅ Plan de sprint completo con 6 días

✅ Base de datos diseñada

✅ Pantallas y flujos definidos

✅ Buenas prácticas establecidas

Próximos Pasos
Comenzar Setup del proyecto (Día 1)

Crear tabla users en Supabase

Implementar Login y Registro

Testear autenticación

Continuar con módulo Pets

Recursos Necesarios
Cuenta en Supabase (gratis)

Cuenta en Firebase (gratis para notificaciones)

GitHub para control de versiones

Figma para diseño (gratis)

Emuladores Android/iOS o dispositivos físicos

CONTACTO Y REFERENCIAS
Documentación Oficial
Flutter Documentation

Supabase Documentation

Firebase Cloud Messaging

Herramientas
GitHub: https://github.com

Figma: https://figma.com

Supabase: https://supabase.com

Flutter: https://flutter.dev
