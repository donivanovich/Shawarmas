# Centralized image server

This service provides one public HTTP location for product images used by the
web, Java and WPF clients. Image binaries live in `storage/` in the repository
and on the persistent Docker volume, not in MySQL or in a client application. Product records should store only the
relative path returned by the upload endpoint, such as
`/products/550e8400-e29b-41d4-a716-446655440000.png`.

## Architecture

```text
web / Java / WPF -> HTTP image server -> shawarmas-images Docker volume
                         |
                         +-- MySQL remains responsible for product data
```

The service is stateless apart from the mounted storage directory. Generated
UUID filenames avoid collisions and do not expose the original local filename.
Only PNG, JPG, JPEG and WebP files whose MIME type and file signature agree are
accepted.

The shared brand files live in `storage/brand` and are served publicly at
`/brand/logo.png` and `/brand/favicon.ico`. Web, Java and WPF read them from
`IMAGE_BASE_URL` (default `http://localhost:3000`).

## Structure

```text
server/
├── src/
│   ├── config/env.js
│   ├── middleware/auth.js
│   ├── routes/imageRoutes.js
│   ├── services/imageService.js
│   ├── app.js
│   └── server.js
├── storage/products/.gitkeep
├── test/imageServer.test.js
├── Dockerfile
├── .dockerignore
├── .env.example
└── package.json
```

## Requirements

- Docker Desktop with Docker Compose
- Node.js 20+ only for running tests or the server outside Docker

## Start, stop and restart

Create the untracked runtime configuration:

```powershell
Copy-Item server\.env.example server\.env
# Edit server\.env and replace UPLOAD_API_KEY
docker compose up --build
```

The image server is available at `http://localhost:3000`. The existing web
application remains at `http://localhost:8080`; MySQL remains unchanged.

```powershell
docker compose stop image-server
docker compose restart image-server
docker compose down
```

`docker compose down` removes containers but keeps named volumes. Do not use
`docker compose down -v` unless you intentionally want to delete both the
database and image data.

## API

### Health check

```text
GET /health
```

```powershell
curl http://localhost:3000/health
```

Returns `200 {"status":"ok"}`.

### Upload

```text
POST /api/products
Header: X-API-Key: <UPLOAD_API_KEY>
Multipart field: image
```

```powershell
curl -X POST http://localhost:3000/api/products `
  -H "X-API-Key: <UPLOAD_API_KEY>" `
  -F "image=@.\product.png"
```

The response is `201` and includes `path`, `url`, `filename`, `size` and
`contentType`. Uploads over `MAX_FILE_SIZE_MB`, unsupported extensions, MIME
types, or invalid image signatures return `400` or `413`.

### Retrieve

```text
GET /products/:filename
```

Retrieval is public and returns `404` for a missing or unsafe filename.
Responses use a one-year immutable cache policy because filenames are unique.
For example:

```text
http://localhost:3000/products/550e8400-e29b-41d4-a716-446655440000.png
```

Color swatches are public in the same way:

```text
http://localhost:3000/colors/black.png
```

The product detail page uses one color picker selection at a time. It filters
the size list by the selected color, disables unavailable color/size
combinations, and updates the displayed image using the variant image path.

### Delete

```text
DELETE /api/products/:filename
Header: X-API-Key: <UPLOAD_API_KEY>
```

```powershell
curl -X DELETE http://localhost:3000/api/products/550e8400-e29b-41d4-a716-446655440000.png `
  -H "X-API-Key: <UPLOAD_API_KEY>"
```

Returns `204` on success, `401` without the API key and `404` if the image
does not exist.

## Configuration

Copy `.env.example` to `.env`; `.env` is ignored by Git.

| Variable | Purpose |
| --- | --- |
| `PORT` | HTTP port inside the container (default `3000`) |
| `NODE_ENV` | Runtime environment |
| `IMAGE_STORAGE_PATH` | Local storage root; Compose uses `/app/storage` |
| `MAX_FILE_SIZE_MB` | Maximum upload size |
| `UPLOAD_API_KEY` | Secret required for upload and deletion |
| `IMAGE_BASE_URL` | Public/reverse-proxy base URL used in upload responses |

Compose also accepts `IMAGE_SERVER_PORT` from the shell or root `.env` to
change the published port. Never commit a real API key.

## Client integration

Store `/products/<filename>` in the existing MySQL `imagen` field, not the
full URL. Build the display URL by joining `IMAGE_BASE_URL` and that relative
path. For the current local setup, a product image URL is:

```text
http://localhost:3000/products/<filename>
```

Java example:

```java
String imageBaseUrl = System.getenv().getOrDefault("IMAGE_BASE_URL", "http://localhost:3000");
String imagePath = product.getImagen(); // /products/<filename>
BufferedImage image = ImageIO.read(URI.create(imageBaseUrl + imagePath).toURL());
```

C# example:

```csharp
var imageBaseUrl = Environment.GetEnvironmentVariable("IMAGE_BASE_URL")
                   ?? "http://localhost:3000";
using var client = new HttpClient();
await using var stream = await client.GetStreamAsync(imageBaseUrl + product.Imagen);
var bitmap = new BitmapImage();
bitmap.BeginInit();
bitmap.StreamSource = stream;
bitmap.CacheOption = BitmapCacheOption.OnLoad;
bitmap.EndInit();
```

The browser can use the same URL directly in an `<img src="...">`. Java and
WPF clients running on the host use `localhost`; code running in another
container should use the service's reachable hostname instead.

## Persistent storage and deployment

Compose mounts the named `shawarmas-images` volume at `/app/storage`. It is
independent of the image-server container and survives rebuilds and recreation.
Back up this volume as part of the deployment's backup plan.

For a future VPS, keep the service private on the Docker network and put Nginx,
Caddy or another reverse proxy in front of it. Terminate HTTPS at the proxy,
proxy `/health`, `/products/` and `/api/products` to the image server, set
`IMAGE_BASE_URL=https://images.example.com`, and preserve the `Host` and
`X-Forwarded-Proto` headers. No application changes are required: clients
continue to combine the configured base URL with the relative database path.
Do not expose the container directly to the public internet or place secrets in
the proxy configuration.

## Tests

```powershell
cd server
npm install
npm test
```

The tests cover health, valid retrieval, missing images, upload validation,
authentication, deletion and persistence across app recreation (the same
storage directory).
