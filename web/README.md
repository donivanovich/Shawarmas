# Shawarmas Web Store

The PHP storefront uses the TypeScript REST API for account, catalog, cart and order operations. It does not connect directly to MySQL. In Docker Compose, Apache reaches the API at `http://api:3001/api/v1`; `API_BASE_URL` is set in both the Compose service and the web image.

## Run

Configure `db/.env`, `server/.env` and `services/api/.env` from their examples, using matching API database credentials and image server API key, then rebuild and start the stack:

```sh
docker compose up -d --build --force-recreate web api
```

Open <http://localhost:8080>. MySQL is exposed only on `127.0.0.1:3307`. The API is exposed on `127.0.0.1:3001` for desktop clients; the PHP container uses the internal Compose hostname `api`.

For PHP development outside Docker, set `API_BASE_URL=http://127.0.0.1:3001/api/v1` in the PHP process environment. The image URL used in browser links is configured separately with `IMAGE_BASE_URL`.

The storefront provides registration and login, catalog and product details, variant selection, cart, checkout and order pages. Checkout pricing and inventory changes are validated by the API. PHP session authentication and CSRF protection apply to storefront forms.
