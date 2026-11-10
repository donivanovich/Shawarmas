# Shawarmas

Shawarmas es una tienda de ropa con tres clientes que comparten una única base de datos MySQL:

- `web/`: cliente PHP para Apache.
- `app/`: cliente Java Swing para Eclipse.
- `wpf/`: cliente WPF para Visual Studio 2022.
- `db/`: esquema y configuración común de la base de datos.

## Puesta en marcha rápida

1. Copia `db/.env.example` como `db/.env` y cambia las contraseñas. Compose leerá ese archivo automáticamente.
2. Ejecuta `docker compose up --build`.
3. Abre `http://localhost:8080`.
4. Para Java y WPF desde el equipo, usa `DB_HOST=127.0.0.1` y `DB_PORT=3307`. Dentro de Docker la web usa automáticamente `db:3306`.

El esquema se inicializa desde [db/schema.sql](db/schema.sql). No se mantienen copias SQL dentro de los clientes.

## Seguridad

Las contraseñas nuevas se almacenan con funciones de derivación seguras, las consultas de acceso a datos usan parámetros, las sesiones web se regeneran al iniciar sesión y los formularios que modifican datos requieren CSRF. Las credenciales se obtienen del entorno y no se guardan en el código.

Consulta la guía específica de cada cliente:

- [Aplicación Java](app/README.md)
- [Aplicación web](web/README.md)
- [Aplicación WPF](wpf/README.md)
