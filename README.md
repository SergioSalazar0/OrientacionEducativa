# Rastro X

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Estado](https://img.shields.io/badge/Estado-MVP%20funcional-6A4C2F?style=for-the-badge)

Aplicación móvil desarrollada con Flutter para gestionar una experiencia de juego por equipos con temática arqueológica. Rastro X permite registrar participantes, asignar avatares, llevar el puntaje por rondas y mostrar al equipo ganador con una pantalla final lista para compartir.

---

## Descripción general

Rastro X fue diseñado para ofrecer una dinámica visual, atractiva y sencilla de usar en actividades escolares, retos grupales o experiencias lúdicas. La aplicación guía al usuario a través de un flujo claro:

1. Pantalla de inicio temática.
2. Registro de equipos y exploradores.
3. Captura de puntajes por ronda.
4. Cálculo automático del equipo ganador.
5. Pantalla de victoria con opción de compartir resultado.

---

## Características principales

- Registro de dos equipos con hasta 4 jugadores por equipo.
- Selección de avatares para personalizar la experiencia.
- Sistema de puntuación por rondas.
- Cálculo automático del marcador total.
- Pantalla final del equipo ganador.
- Animaciones y celebración visual con confeti.
- Generación de captura para compartir resultados.
- Interfaz temática inspirada en exploración e historia.

---

## Tecnologías utilizadas

- Flutter
- Dart
- Riverpod para manejo de estado
- GoRouter para navegación
- Google Fonts para tipografía
- Share Plus para compartir resultados
- Screenshot para captura de pantalla
- Confetti para animaciones finales

---

## Estructura del proyecto

```text
lib/
├── core/
│   ├── constants/
│   ├── router/
│   └── theme/
├── data/
│   └── models/
├── presentation/
│   ├── home/
│   ├── scoreboard/
│   ├── team_registration/
│   └── winner/
├── providers/
├── app.dart
└── main.dart
```

Esta estructura separa responsabilidades para facilitar mantenimiento, escalabilidad y futuras mejoras.

---

## Instalación y ejecución

### Requisitos previos

- Flutter SDK instalado
- Dart SDK compatible
- Android Studio, VS Code o entorno equivalente
- Un emulador o dispositivo físico

### Pasos

```bash
# Clonar el repositorio
git clone https://github.com/sergiodev3/rastro-x-proyect.git

# Entrar al proyecto
cd rastro-x-proyect

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

---

## Pruebas

Para ejecutar las pruebas incluidas en el proyecto:

```bash
flutter test
```

---

## Capturas y diseño

El proyecto incluye recursos visuales y referencias de diseño en la carpeta `design/`, útiles para documentar la evolución de la interfaz y su propuesta gráfica.

---

## Posibles mejoras futuras

- Persistencia local de partidas.
- Historial completo de rondas.
- Configuración dinámica de número de equipos y jugadores.
- Sonidos y efectos inmersivos.
- Exportación de resultados.
- Soporte multilenguaje.

---

## Objetivo del proyecto

Rastro X busca combinar juego, organización y una identidad visual memorable en una aplicación ligera y moderna. Es ideal como base para una experiencia educativa, competitiva o recreativa centrada en retos por equipos.

---

## Autor

Desarrollado por Sergio Dev.

Si deseas contribuir o proponer mejoras, puedes abrir un issue o enviar un pull request.
