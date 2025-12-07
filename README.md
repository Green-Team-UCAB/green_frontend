# Green Quiz App (Clon de Kahoot)

Proyecto académico desarrollado en Flutter. Es una plataforma interactiva que permite a los usuarios crear, explorar, jugar y analizar cuestionarios (Quizzes) al estilo de Kahoot.

<p align="center">
   <img src="https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png" alt="Logo-Flutter" width="200">
</p>

Este proyecto implementa prácticas de desarrollo profesional como **Clean Architecture** (Arquitectura Limpia), **Inyección de Dependencias** y **Programación Funcional**.

---

## 👥 Integrantes del Equipo (Green Team)
* **Diego Vellojín**
* **Maria Bolivar**
* **Marcello Sevitad**

---

## 🚀 Comenzando (Getting Started)

Sigue estos pasos para ejecutar el proyecto en tu entorno local.

### Prerrequisitos
* Flutter SDK (Versión >= 3.0.0)
* VSCode o Android Studio con las extensiones de Flutter/Dart instaladas.
* Node.js (Opcional, para el servidor de simulacro/mock).

### Instalación

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/Green-Team-UCAB/green_frontend.git](https://github.com/Green-Team-UCAB/green_frontend.git)
    cd green_frontend
    ```

2.  **Instalar dependencias de Flutter:**
    ```bash
    flutter pub get
    ```

3.  **Ejecutar el Generador de Código (Build Runner):**
    Necesario para generar los archivos `.g.dart` de los modelos JSON y Freezed.
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **(Opcional) Levantar el Servidor Mock (Json Server):**
    Si deseas probar la app con datos simulados externos:
    ```bash
    npm install -g json-server
    json-server --watch db.json --port 3000
    ```

5.  **Ejecutar la App:**
    Selecciona tu dispositivo (Emulador o Físico) y corre:
    ```bash
    flutter run
    ```

---

## 🛠️ Tecnologías y Librerías Clave

Este proyecto utiliza un stack robusto definido en el archivo `pubspec.yaml`:

* **Gestión de Estado:**
    * [`flutter_bloc`](https://pub.dev/packages/flutter_bloc): Para el manejo de estado predecible basado en eventos (Discovery, Reports, Library).
    * [`provider`](https://pub.dev/packages/provider): Para la gestión de estado heredada y navegación global.
* **Arquitectura e Inyección de Dependencias:**
    * [`get_it`](https://pub.dev/packages/get_it): Service Locator para inyección de dependencias desacoplada.
* **Programación Funcional y Manejo de Errores:**
    * [`fpdart`](https://pub.dev/packages/fpdart): Uso de tipos `Either<Failure, Success>` para un manejo de errores robusto sin excepciones no controladas.
* **Red y Datos:**
    * [`dio`](https://pub.dev/packages/dio): Cliente HTTP potente.
    * [`json_serializable`](https://pub.dev/packages/json_serializable): Serialización automática de JSON.
* **Utilidades:**
    * [`equatable`](https://pub.dev/packages/equatable): Comparación de objetos por valor.
    * [`rxdart`](https://pub.dev/packages/rxdart): Programación reactiva (ej. Debounce en búsqueda).

---

## 🏛️ Arquitectura del Proyecto

El proyecto sigue estrictamente los principios de **Clean Architecture**, dividiendo cada funcionalidad (*Feature*) en tres capas concéntricas para garantizar la escalabilidad y testabilidad.


### Estructura de Carpetas (`lib/features/`)

Cada módulo (ej: `reports`, `discovery`, `library`) tiene su propia estructura interna:

1.  **Domain (Dominio):** *El núcleo. Reglas de negocio puras.*
    * `entities/`: Objetos de negocio simples (Dart puro).
    * `usecases/`: Lógica de negocio específica (ej. `SearchKahootsUseCase`).
    * `repositories/`: Contratos (Interfaces) que definen *qué* se hace, no *cómo*.

2.  **Data (Datos):** *La implementación.*
    * `models/`: Adaptadores de datos (parcean JSON a Entidades).
    * `datasources/`: Conexión con APIs externas o bases de datos locales.
    * `repositories/`: Implementación de los contratos del dominio.

3.  **Presentation (Presentación):** *Lo que ve el usuario.*
    * `bloc/`: Gestión de estado que conecta la UI con el Dominio.
    * `pages/` y `widgets/`: Interfaz gráfica construida en Flutter.

### Árbol de Directorios Principal
```text
lib/
├── core/                  # Utilidades compartidas (Themes, Failures, UseCase base)
├── features/              # Módulos de la aplicación
|   ├── single_player/     # Épica 5: Juego Individual
│   ├── discovery/         # Épica 6: Búsqueda y Exploración
│   ├── library/           # Épica 7: Mis Kahoots, Favoritos e Informes
│   ├── reports/           # Épica 10: Estadísticas y Resultados
│   ├── kahoot/            # Épica 2: Creación y Gestión de Kahoots
│   └── menu_navegation/   # Navegación principal (Bottom Bar)
├── injection_container.dart # Configuración de Inyección de Dependencias (GetIt)
└── main.dart              # Punto de entrada e Integración de Providers