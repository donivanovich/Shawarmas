# Security

- Runtime `.env` files are ignored by Git. Use `.env.example` only as a template and replace all example values before deployment.
- PHP obtains database credentials from its Compose environment. Java and WPF require `DB_PASSWORD`; they do not use a source-coded fallback.
- The image server requires `UPLOAD_API_KEY` at startup and checks it on upload and delete. Retrieval routes remain public for client compatibility.
- Uploads are size-limited and checked against allowed extensions, MIME types and image signatures. Product filenames are restricted before read/delete operations.
- Web database operations use MySQLi prepared statements for user-controlled data. Passwords are stored with PBKDF2 or PHP password hashing, and CSRF/session controls are present in the storefront.
- Keep MySQL bound to loopback for local development. For shared deployments, use a firewall and private Docker networking; do not expose database credentials or upload keys to browsers or desktop distributions.

The checked-in environment examples include deliberately obvious placeholders. They are not production credentials. Existing local runtime `.env` files are ignored and must remain private. If a real secret has ever been committed or shared, rotate it through the relevant service owner; this repository change does not rotate credentials or alter accounts.
