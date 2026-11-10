# Cliente Java de Shawarmas

## Estructura

El código Java está en `src/`, los recursos en `resources/` y la configuración de Eclipse en `.project`, `.classpath` y `.settings/`. La carpeta `bin/` contiene compilación local y no forma parte del código fuente.

## Requisitos

- Eclipse IDE con Java 17 o superior.
- MySQL Connector/J 8.3 o superior.
- MySQL 8.0 o MariaDB compatible.

## Configuración

Importa `app/` como proyecto Maven existente de Eclipse. Eclipse debe usar un JDK 17 o superior y Maven debe estar habilitado mediante m2e. La aplicación usa por defecto `DB_HOST=127.0.0.1`, `DB_PORT=3307`, `DB_NAME=shawarmas`, `DB_USER=shawarmas_app` y `DB_PASSWORD=1234`, que coinciden con Docker. Puedes sobrescribirlos en la configuración de ejecución. Usa el mismo usuario de aplicación configurado en Docker; no uses `root`.

La base se crea ejecutando una sola vez `db/schema.sql`. La aplicación no crea ni modifica el esquema automáticamente.

## Funcionalidad

El cliente permite iniciar sesión, registrar clientes, consultar productos y gestionar pedidos según el perfil. La interfaz está en español y las clases mantienen nombres en inglés para conservar una API coherente entre plataformas.

## Seguridad aplicada

`DatabaseConnection` no contiene credenciales personales. Las operaciones de registro y autenticación usan sentencias preparadas y PBKDF2-HMAC-SHA256 con sal aleatoria y 120000 iteraciones. Las contraseñas nunca se comparan directamente con SQL.

## Diagnóstico en Eclipse

Si Eclipse conserva rutas antiguas, elimina el proyecto del espacio de trabajo sin borrar archivos. Después usa `File > Import > Maven > Existing Maven Projects`, selecciona la carpeta `app/`, marca `pom.xml` y finaliza. Si no aparece Maven, instala Eclipse IDE for Java Developers o el complemento m2e. Ejecuta `Project > Clean` antes de iniciar `com.shawarmas.Login`.
