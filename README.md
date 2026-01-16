# 🌿 Green Quiz App (Clon de Kahoot)

> **Plataforma educativa interactiva en tiempo real desarrollada con Flutter.**

Proyecto académico de ingeniería de software que permite a los usuarios crear, explorar, jugar y analizar cuestionarios (Quizzes). Este sistema no es solo una aplicación funcional, sino una demostración robusta de arquitectura de software, implementando **Clean Architecture (4 Capas)**, **Inyección de Dependencias** y **Behavior Driven Development (BDD)**.

<p align="center">
   <img src="https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png" alt="Logo-Flutter" width="300">
   <br>
   <img src="https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Version" />
   <img src="https://img.shields.io/badge/Architecture-Clean%20(4%20Layers)-success?style=for-the-badge" alt="Clean Architecture" />
   <img src="https://img.shields.io/badge/Testing-BDD%20%26%20Robot-critical?style=for-the-badge" alt="BDD Testing" />
</p>

---

## 👥 Green Team (Autores)

* **Diego Vellojín**
* **Maria Bolivar**
* **Marcello Sevitad**

---

## 🏛️ Arquitectura de Software: Clean Architecture

Este proyecto no es solo una aplicación, es una implementación de referencia de **Clean Architecture**. La decisión de dividir el software en cuatro capas concéntricas obedece a principios de ingeniería sólidos (SOLID, SoC) que garantizan un ciclo de vida del software saludable y escalable.

### ¿Por qué esta separación?
1.  **Independencia del Framework:** Flutter es solo una herramienta de UI. La lógica de negocio (`Domain`) no sabe que existe Flutter. Esto permitiría, teóricamente, migrar la lógica a Dart Web o CLI sin cambiar una línea de código del núcleo.
2.  **Testabilidad:** Al desacoplar las capas, podemos probar la lógica de negocio (`UseCases`) sin necesidad de emuladores ni internet, simplemente "mockeando" los repositorios.
3.  **Escalabilidad:** Múltiples desarrolladores pueden trabajar en diferentes capas de la misma feature sin conflictos (uno diseña la UI, otro implementa la conexión al API).

### Desglose de Capas

#### 1. Domain (Dominio) - *La Verdad Absoluta*
Es el núcleo inmutable del software. Aquí residen las reglas de negocio que **no deben cambiar** aunque cambiemos de base de datos o de diseño visual.
*   **`entities/`**: Modelos puros (POJOs). Implementan `Equatable` para garantizar que dos objetos con los mismos datos sean considerados iguales.
*   **`repositories/` (Interfaces)**: Aplicamos el **Principio de Inversión de Dependencias (DIP)**. El dominio dice *qué* necesita (un contrato), y la capa de infraestructura obedece implementándolo.

#### 2. Application (Aplicación) - *El Director de Orquesta*
Contiene la lógica transaccional.
*   **`usecases/`**: Cada clase encapsula una única intención del usuario (S.R.P. - Single Responsibility Principle). Ejemplo: `JoinGameUseCase`.
    *   *Input:* Parámetros validados.
    *   *Output:* Un tipo funcional `Either<Failure, Success>`, lo que obliga a quien lo llame a cubrir explícitamente el escenario de error.

#### 3. Infrastructure (Infraestructura) - *El Mundo Real*
Es la capa "sucia" que trata con los detalles técnicos externos.
*   **`datasources/`**: Manejan la comunicación cruda (HTTP con Dio, LocalStorage, WebSockets).
*   **`repositories/` (Implementación)**: Son "traducores". Toman los datos crudos del datasource (JSON, códigos de error HTTP 404/500) y los convierten en Entidades de Dominio y Errores de Negocio (`UserNotFoundFailure`), protegiendo al resto de la app de los detalles de implementación.

#### 4. Presentation (Presentación) - *La Interfaz*
Patrón **BLoC (Business Logic Component)**.
*   La UI es **totalmente pasiva**. No toma decisiones, solo pinta estados (`Loading`, `Success`, `Error`).
*   Los BLoCs reciben eventos (`OnLoginButtonPressed`) y emiten estados resultantes tras consultar a la capa de Aplicación.

### 💉 Inyección de Dependencias (`get_it` + `injectable`)
No creamos objetos manualmente (`new Repository()`). Un contenedor centralizado (Service Locator) se encarga de crear y facilitar las instancias. Esto nos permite intercambiar implementaciones reales por "Simulacros" (Mocks) durante los tests con una sola línea de configuración.

---

## 🛠️ Stack Tecnológico

Definido en `pubspec.yaml`, seleccionamos las herramientas más robustas del ecosistema:

### Gestión de Estado & Arquitectura
* **`flutter_bloc`**: Manejo de estado predecible basado en eventos.
* **`get_it` & `injectable`**: Inyección de dependencias escalable.
* **`fpdart`**: Programación funcional. Usamos tipos `Either<Failure, Success>` para eliminar el manejo de errores mediante `try-catch` desordenados, forzando al desarrollador a manejar ambos escenarios.

### Conectividad Avanzada & Backend
*   **`dio`**: No es solo un cliente HTTP. Hemos configurado una capa de red profesional mediante **Interceptors**:
    *   **AuthInterceptor:** Intercepta cada petición saliente para inyectar automáticamente el Token JWT en los headers, y monitorea las respuestas para detectar `401 Unauthorized` y cerrar sesión globalmente si el token expira.
    *   **Logging:** Trazabilidad completa de Request/Response para depuración.
*   **`socket_io_client`**: Gestión de WebSockets para el **Modo Tiempo Real**. Permite comunicación bidireccional de baja latencia crítica para la sincronización de preguntas en partidas multijugador.
*   **`json_serializable`**: Elimina el "boilerplate" propenso a errores humanos al generar automáticamente la lógica de serialización, asegurando un mapeo de datos Type-Safe.

### Inteligencia Artificial (IA) 🤖
* **`http`**: Integración vía REST con **Gemini API**.
    * **Funcionalidad:** Permite generar preguntas automáticamente ("Magic Create"). Debido a restricciones de versión, la comunicación con la IA se maneja mediante peticiones HTTP directas en lugar del SDK nativo, garantizando estabilidad y control sobre la estructura JSON recibida.

### Utilidades
* **`flutter_secure_storage`**: Almacenamiento encriptado de tokens de sesión (JWT) en el Keychain/Keystore del dispositivo.
* **`mobile_scanner` & `qr_flutter`**: Generación y lectura de códigos QR para unirse a las sesiones de juego sin escribir PINs.

---

## 🛡️ Estrategia de Calidad y Arquitectura de Pruebas (BDD)

Para garantizar la robustez, especialmente en la épica de **Gestión de Grupos (H8)**, implementamos una metodología de **Behavior Driven Development (BDD)**.



### Metodología
En lugar de escribir tests técnicos aislados, definimos los requisitos en archivos `.feature` usando lenguaje **Gherkin**. Esto sirve como documentación viva del proyecto.

**Estructura de Features:**
1.  `manage_my_groups.feature`: Gestión general (Crear, Editar, Eliminar grupos).
2.  `group_members.feature`: Gestión de personas (Invitar, Eliminar miembros).
3.  `group_activities.feature`: Lógica educativa (Asignar Quizzes a grupos).
4.  `group_leaderboard.feature`: Visualización de rankings y competencia interna.

### El Patrón Robot (Robot Pattern) 🤖
Hemos adoptado este patrón de diseño para elevar la calidad de nuestros tests de aceptación y UI.

#### ¿Por qué usar Robots?
Los tests tradicionales de Flutter (`find.text('Login')`) son frágiles. Si un desarrollador cambia el texto "Login" por "Ingresar" o cambia un botón por un icono, **el test se rompe** aunque la funcionalidad siga intacta.

El **Robot actúa como una capa de abstracción (DSL - Domain Specific Language)**:
1.  **Legibilidad:** Los tests se leen como historias de usuario en lenguaje natural:
    ```dart
    await robot.ingresarCredenciales("user", "pass");
    await robot.tocarBotonIngreso();
    await robot.verificarPantallaHome();
    ```
2.  **Mantenibilidad:** Si el botón de ingreso cambia de ID o texto, **solo arreglamos el Robot en un único lugar**, y los 50 tests que usan ese robot vuelven a pasar automáticamente.
3.  **Desacoplamiento:** Separa el *QUÉ* se prueba (Test) del *CÓMO* se interactúa con la pantalla (Robot).

### Herramientas de Testing
* **`flutter_test`**: Ejecución de Widget Tests en memoria (rápido y sin emulador).
* **`mockito`**: Simulamos la capa de datos (Repositories) para probar la UI en aislamiento total del Backend. Probamos escenarios de éxito, carga y error sin depender de internet.
* **`bdd_widget_test`**: Librería que transforma nuestros archivos Gherkin en tests ejecutables de Dart.

---

## 📂 Estructura del Proyecto

### 1. Mapa de Features (`lib/features/`)
El proyecto está modularizado por funcionalidades de negocio. Aquí están todas las features implementadas:

```text
lib/features/
├── auth/            # 🔐 Autenticación y Seguridad (Login, Register, Tokens)
├── discovery/       # 🔍 Exploración (Búsqueda de Kahoots públicos, Categorías)
├── groups/          # 👥 Grupos de Estudio (Creación, Miembros, Leaderboards)
├── kahoot/          # ✍️ Editor de Kahoots (Creador de preguntas, "Magic Create" con IA)
├── library/         # 📚 Librería Real (Mis Kahoots, Favoritos, Historial)
├── media/           # 🖼️ Gestión Multimedia (Carga y optimización de imágenes)
├── menu_navegation/ # 🧭 Navegación Global (Bottom Navigation Bar)
├── multiplayer/     # ⚔️ Modo Multijugador (Lógica Socket.io, Lobby, Podio)
├── reports/         # 📊 Reportes (Estadísticas de sesiones, análisis de rendimiento)
├── single_player/   # 🕹️ Modo Solitario (Motor de juego local)
└── user/            # 👤 Perfil (Edición de datos, Avatar)
```

### 2. Arquitectura Interna por Feature (Clean Architecture)

Tomando como referencia el módulo `groups`, así se organiza internamente cada carpeta:

```text
lib/features/groups/
├── domain/                  # Capa 1: Definiciones (Pura)
│   ├── entities/            # (Group, GroupMember)
│   └── repositories/        # (IGroupsRepository - Contrato)
├── application/             # Capa 2: Lógica de Aplicación
│   └── usecases/            # (CreateGroupUseCase, GetGroupsUseCase)
├── infrastructure/          # Capa 3: Implementación y Datos
│   ├── models/              # (GroupModel, GroupDetailModel)
│   ├── datasources/         # (GroupsRemoteDataSource)
│   └── repositories/        # (GroupsRepositoryImpl)
└── presentation/            # Capa 4: UI y Estado
    ├── bloc/                # (GroupsBloc, GroupDetailBloc)
    ├── pages/               # Pantallas (GroupDetailPage, MyGroupsPage)
    └── widgets/             # Componentes reutilizables
```
<br>

## 🚀 Comenzando (Getting Started)

Sigue estos pasos para ejecutar el proyecto en tu entorno local.

### Prerrequisitos
* **Flutter SDK** (Versión 3.0.0 o superior)
* **IDE**: VSCode o Android Studio con extensiones de Flutter/Dart.
* **Emulador/Dispositivo**: Android o iOS configurado.

### Instalación

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/Green-Team-UCAB/green_frontend.git
    cd green_frontend
    ```

2.  **Instalar dependencias de Flutter:**
    ```bash
    flutter pub get
    ```

3.  **Generación de Código (Vital):**
    Este proyecto utiliza `build_runner` para generar código JSON, rutas e inyección de dependencias. Ejecuta esto antes de compilar:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Ejecutar la App:**
    Selecciona tu dispositivo y corre:
    ```bash
    flutter run
    ```

<br>
<hr>
<p align="center">
  <sub>Hecho con 💚 por el <b>Green Team @ UCAB</b> - Ingeniería de Software</sub>
</p>