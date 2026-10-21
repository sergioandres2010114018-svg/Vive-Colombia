# ViveColombia App

*Descubre la esencia de Colombia en un solo lugar.*

Aplicación móvil en Flutter para Android. Proyecto formativo del programa Técnico en Programación de Aplicaciones para Dispositivos Móviles, Institución Educativa Técnica Departamental Pijiño del Carmen (Magdalena), SENA, Centro Acuícola y Agroindustrial de Gaira.

## Qué hace

- **Inicio:** buscador, 7 categorías, destino destacado (Pijiño del Carmen), próximas fiestas y regiones.
- **Explorar:** los 32 departamentos, filtrados por región. Magdalena tiene detalle por municipio.
- **Mapa:** mapa de Colombia (OpenStreetMap) con las capitales y los lugares del Magdalena.
- **Mis viajes:** favoritos y una ruta propia que se abre en Google Maps.
- **Perfil:** registro del viajero e información del proyecto.

## Cómo obtener el APK (sin instalar nada)

1. Sube esta carpeta a un repositorio de GitHub.
2. GitHub compila la app solo, en la pestaña **Actions**, en unos 8 minutos.
3. Abre la ejecución terminada y descarga **ViveColombia-APK** en la sección *Artifacts*.
4. Descomprime el .zip, pasa `app-release.apk` al celular y ábrelo. Android pedirá permiso para instalar apps de origen desconocido.

## Estructura

```
assets/data.json   Contenido: departamentos, municipios y lugares
assets/*.png       Logo, pin e icono
lib/main.dart      Arranque y barra de pestañas
lib/screens.dart   Pantallas
lib/ui.dart        Colores, tema y componentes
lib/data.dart      Modelos y carga del contenido
lib/state.dart     Favoritos, ruta y perfil (guardados en el teléfono)
```

Para agregar contenido, edita `assets/data.json`. Cada lugar lleva `c` (sitio, comida, cultura, musica, hotel, restaurante o evento), `n` (nombre), `d` (descripción), `dep` (código del departamento, por ejemplo `co-ma`), `muni` (municipio o `null`), y de forma opcional `lat`, `lon` y `m` (mes del evento).

## Siguiente fase

Conectar Firebase para tener inicio de sesión con correo o Google y un panel de contenido compartido.
