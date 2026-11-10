# Cliente WPF de Shawarmas

## Estructura

La solución `Shawarmas.sln` y `Shawarmas.csproj` están en esta carpeta. Las vistas MVVM están en `MVVM/`, los servicios de datos en `Services/` y los recursos visuales en `Resources/`. `bin/` y `obj/` son salidas locales de compilación.

## Requisitos

- Visual Studio 2022 con .NET 8 Desktop Runtime y la carga de trabajo de escritorio .NET.
- MySQL 8.0 o superior.

## Configuración y ejecución

La aplicación usa por defecto `DB_HOST=127.0.0.1`, `DB_PORT=3307`, `DB_NAME=shawarmas`, `DB_USER=shawarmas_app` y `DB_PASSWORD=1234`, que coinciden con Docker. Puedes sobrescribirlos en el perfil de depuración de Visual Studio. Levanta primero el servicio `db` de Docker. Abre `wpf/Shawarmas.sln` y compila en Debug.

## Funcionalidad

WPF es la referencia visual y de interacción: inicio de sesión, registro, menú, configuración, catálogo, pedidos, información y control de audio. Los textos visibles están en español y los nombres de tipos y miembros siguen en inglés.

## Seguridad aplicada

`ServiceDatabase` centraliza una conexión configurada por entorno y admite parámetros MySQL. Los servicios de empleados, productos y pedidos ya no interpolan entradas en SQL. Las contraseñas nuevas usan PBKDF2-HMAC-SHA256 con sal aleatoria y comparación en tiempo constante. Se eliminó el uso de MD5 y la contraseña de administrador embebida.

## Diagnóstico en Visual Studio

Si la solución conserva referencias al directorio antiguo, ciérrala, abre de nuevo `Shawarmas.sln` desde `wpf/` y ejecuta `Clean` seguido de `Rebuild`. No incluyas `bin/`, `obj/` ni `.vs/` en entregas.
