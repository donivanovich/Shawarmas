# Deployment

## Local Compose

Create `db/.env` and `server/.env` from their `.env.example` files, then replace example secrets with unique values. Start with `docker compose up --build -d`; inspect readiness with `docker compose ps` and logs with `docker compose logs -f db web image-server`.

Compose starts MySQL 8.4, Apache/PHP and the Express image server. MySQL is published only on `127.0.0.1:3307`; web-to-database connections use `db:3306`. Web and image storage persist in named volumes. The initial SQL runs only on an empty database volume.

## Desktop applications

Start the database service and provide `DB_HOST=127.0.0.1`, `DB_PORT=3307`, `DB_NAME`, `DB_USER` and `DB_PASSWORD` to Java or WPF. Set `IMAGE_BASE_URL=http://localhost:3000` when using the local image server. The desktop clients do not read `.env` files automatically; configure variables in the IDE run profile or process environment.

## Production considerations

Use unique credentials, restrict database access to trusted networks, terminate HTTPS at a reverse proxy, and expose only required web/image routes. Configure `IMAGE_BASE_URL` to the public HTTPS image origin. Keep upload/delete API keys server-side. Set backups for both named volumes, and test restoration. Do not publish the database port publicly.

See [the image service guide](../server/README.md) for routes, API usage and storage behavior.
