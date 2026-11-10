# Cliente web de Shawarmas

## Estructura

Los PHP y CSS están directamente en `web/`. Las imágenes, fuentes y JavaScript están en `assets/`. El contenedor se construye con `Dockerfile` y sirve Apache en el puerto 8080 mediante el compose de la raíz.

## Requisitos

Para Docker solo se necesita Docker Desktop. Para WAMPServer se requiere Apache, PHP 8.3 o superior, la extensión `mysqli` y MySQL 8.0 o superior.

## Docker

Desde la raíz ejecuta:

```text
docker compose up --build
```

La base de datos se inicializa desde `db/schema.sql` y se publica en `127.0.0.1:3307` para no interferir con WAMP/MySQL en `3306`. El inventario se guarda en `producto_variantes`, con stock independiente por producto, talla y color. Para aplicar el esquema inicial actualizado a una base de datos existente, detén los servicios y elimina únicamente el volumen `shawarmas_shawarmas-db` cuando no necesites conservar datos.

## WAMPServer

Configura las variables de entorno de PHP con los mismos valores de `db/.env.example`, coloca el contenido de `web/` como raíz pública y ejecuta el esquema común. No copies credenciales en `database-connection.php`.

## Datos iniciales de demostración

En el primer arranque con un volumen MySQL vacío, Docker ejecuta `db/schema.sql` y después `db/demo-seed.sql`. Se crean cinco clientes y pedidos de ejemplo. Todas las cuentas semilla usan la contraseña `Shawarmas123!`:

- Cliente: `cliente@shawarmas.local`
- Empleado (tabla `empleados`, perfil `writter`): `empleado@shawarmas.local`
- Clientes: `ana.martinez@gmail.com`, `carlos.rivera@outlook.com`, `laura.gomez@yahoo.com` y `diego.santos@gmail.com`

Los pedidos incluyen productos y direcciones de Madrid, Barcelona, Valencia, Sevilla, Lisboa y Oporto. El antiguo ejemplo `nombre@gmail.com` se elimina junto con sus pedidos. MySQL ejecuta estos scripts solo cuando el volumen está vacío; para la base actual, `db/demo-seed.sql` se puede volver a ejecutar de forma segura.

## Flujo funcional

El cliente ofrece acceso, registro, catálogo, selección de cantidad, carrito y compra. La compra verifica el stock dentro de una transacción y crea líneas de pedido consistentes.

## Portada

`index.php` ofrece la portada editorial en blanco y negro de Shawarmas. Comparte el catálogo, el carrito y el resto del flujo de compra.

## Seguridad aplicada

Se eliminaron las consultas construidas con datos de usuario y se sustituyeron por consultas preparadas. Se añadieron `password_hash`, `password_verify`, regeneración de sesión, cookies HttpOnly/SameSite, tokens CSRF, validación de cantidades y control de stock. Los errores mostrados al cliente no exponen SQL ni credenciales.
