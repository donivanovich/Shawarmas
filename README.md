# Shawarmas

Tienda de ropa con una web PHP, una base MySQL y un servidor centralizado de imágenes. El repositorio también incluye clientes de escritorio Java y WPF opcionales.

## Requisitos

- Git.
- Docker Desktop con Docker Compose v2.
- Para la aplicación Java: JDK 17 o superior, Maven y Eclipse (opcional).
- Para la aplicación WPF: Windows y .NET 8 SDK con soporte WPF (Visual Studio 2022 es opcional).

Para iniciar la tienda web solo hacen falta Git y Docker Desktop.

## Clonar y configurar

En PowerShell, desde la carpeta donde quieras guardar el proyecto:

```powershell
git clone <URL_DEL_REPOSITORIO>
cd shawarmas
Copy-Item db\.env.example db\.env
Copy-Item server\.env.example server\.env
notepad db\.env
notepad server\.env
```

En `db/.env`, cambia `MYSQL_PASSWORD` y `MYSQL_ROOT_PASSWORD` por contraseñas propias. Conserva `MYSQL_DATABASE=shawarmas` y `MYSQL_USER=shawarmas_app` salvo que también actualices la configuración de los clientes.

En `server/.env`, cambia `UPLOAD_API_KEY` por una clave privada. No publiques ni compartas los archivos `.env`; Git los ignora.

En macOS o Linux, las copias iniciales se hacen con:

```bash
cp db/.env.example db/.env
cp server/.env.example server/.env
```

Edita esos dos archivos antes de arrancar.

## Iniciar la web y sus servicios

Desde la raíz del repositorio:

```powershell
docker compose up --build -d
docker compose ps
```

La primera ejecución crea la base desde `db/schema.sql` y puede tardar un poco. Para ver el arranque y diagnosticar errores:

```powershell
docker compose logs -f db web image-server
```

Cuando los servicios estén activos, abre:

- Tienda web: <http://localhost:8080>
- Catálogo: <http://localhost:8080/products.php>
- Estado del servidor de imágenes: <http://localhost:3000/health>
- MySQL desde el equipo: `127.0.0.1:3307`

Dentro de Docker, la web se conecta a MySQL mediante `db:3306`. Los clientes Java y WPF que se ejecutan en el equipo usan `127.0.0.1:3307`.

## Imágenes

Las imágenes se sirven desde el volumen Docker `shawarmas-images`. Los archivos de imagen no se incluyen en Git. Si tienes los recursos del proyecto, colócalos en `server/storage/products/` y `server/storage/colors/`; después de arrancar Docker, cópialos al volumen:

```powershell
docker compose cp .\server\storage\products\. image-server:/app/storage/products/
docker compose cp .\server\storage\colors\. image-server:/app/storage/colors/
```

Puedes comprobar una imagen con `http://localhost:3000/products/<nombre-del-archivo>.png` o `http://localhost:3000/colors/<nombre-del-archivo>.png`.

Para cargar una imagen nueva mediante la API, usa la clave `UPLOAD_API_KEY` de `server/.env`:

```powershell
curl.exe -X POST http://localhost:3000/api/products `
  -H "X-API-Key: <UPLOAD_API_KEY>" `
  -F "image=@C:\ruta\a\imagen.png"
```

La respuesta contiene la ruta relativa que debe guardarse en MySQL, por ejemplo `/products/<filename>.png`. No guardes la URL completa del servidor en la base.

## Base de datos

El esquema inicial y los datos de ejemplo están en `db/schema.sql`. Docker lo ejecuta únicamente al crear el volumen de base de datos por primera vez. Reiniciar los contenedores no reinicia la base ni vuelve a cargar el esquema.

Para una base existente, haz una copia de seguridad y aplica solamente las migraciones que correspondan a su versión. Los archivos `db/migrate-*.sql` son actualizaciones incrementales; no ejecutes todos sobre una base ya actualizada ni vuelvas a cargar `schema.sql` para intentar migrarla.

El inventario por talla y color se almacena en `producto_variantes`. Las imágenes de variantes usan su ruta en la columna `imagen`, y las descripciones de producto están en `productos.descripcion`.

## Ejecutar los clientes de escritorio (opcional)

Arranca primero MySQL con Docker:

```powershell
docker compose up -d db
```

### Java

Configura las variables de conexión del proceso con los valores de `db/.env`:

```text
DB_HOST=127.0.0.1
DB_PORT=3307
DB_NAME=shawarmas
DB_USER=shawarmas_app
DB_PASSWORD=<MYSQL_PASSWORD de db/.env>
```

En Eclipse, importa `app/` como proyecto Maven existente y ejecuta `com.shawarmas.Login`. Para compilar desde una terminal con Maven instalado:

```powershell
mvn -f app/pom.xml package
```

### WPF

Configura las mismas variables de conexión del apartado Java en el entorno desde el que inicies la aplicación. Con Visual Studio, abre `wpf/Shawarmas.sln` y ejecuta el proyecto. También puedes compilar y ejecutar desde PowerShell:

```powershell
dotnet build wpf/Shawarmas.csproj
dotnet run --project wpf/Shawarmas.csproj
```

Las guías específicas están en [app/README.md](app/README.md), [wpf/README.md](wpf/README.md), [web/README.md](web/README.md) y [server/README.md](server/README.md).

## Parar y volver a iniciar

Detener y conservar contenedores y datos:

```powershell
docker compose stop
docker compose start
```

Eliminar contenedores y redes, conservando los volúmenes:

```powershell
docker compose down
```

`docker compose down -v` también elimina la base de datos y todas las imágenes del volumen. Úsalo solo si quieres borrar esos datos intencionadamente.

## Estructura

```text
db/      Esquema, migraciones y ejemplo de configuración MySQL
web/     Tienda PHP y estilos
server/  API HTTP y almacenamiento de imágenes
app/     Cliente Java
wpf/     Cliente de escritorio WPF
```
