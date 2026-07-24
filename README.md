# Shawarmas

Repositorio unificado del proyecto **Shawarmas**, organizado por plataforma para mantener en un solo lugar las tres versiones de la aplicación.

## Estructura

```text
Shawarmas/
├── web/
├── app/
└── wpf/
```

## Proyectos incluidos

### Web
Versión web del proyecto Shawarmas.

Contenido esperado dentro de `web/`:
- Código fuente de la aplicación web.
- Scripts SQL relacionados con base de datos.
- Recursos específicos del frontend o backend web.

### App
Versión de aplicación de escritorio o Java del proyecto Shawarmas.

Contenido esperado dentro de `app/`:
- Código fuente principal de la app.
- Archivo ejecutable o compilado si se conserva.
- Scripts SQL y recursos asociados.

### WPF
Versión desarrollada con WPF.

Contenido esperado dentro de `wpf/`:
- Solución y proyecto WPF.
- Scripts SQL asociados.
- Recursos de interfaz y configuración propios del proyecto.

## Objetivo

Este repositorio agrupa las tres implementaciones de Shawarmas para:
- Centralizar el desarrollo en un único repositorio.
- Separar claramente cada tecnología en su propia carpeta.
- Facilitar el mantenimiento, revisión y presentación del proyecto.

## Organización recomendada

Cada carpeta debe contener únicamente los archivos necesarios del proyecto. Se recomienda evitar incluir archivos generados por el IDE o temporales, por ejemplo:
- `.vs/`
- `.metadata/`
- `bin/`
- `obj/`

## Base de datos

Si varias versiones comparten la misma estructura de base de datos, conviene:
- Mantener un único script común en una carpeta dedicada, o
- Dejar una copia en cada subproyecto si cada versión tiene diferencias propias.

## Notas

- `web/` contiene la implementación web.
- `app/` contiene la implementación de aplicación.
- `wpf/` contiene la implementación en WPF.
- Los repositorios originales pueden mantenerse como copia histórica o archivarse tras comprobar que la migración es correcta.
