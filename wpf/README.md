# Shawarmas WPF Client

## Requirements

- Windows and .NET 8 SDK with WPF targeting support.
- Access to the Shawarmas REST API (`API_BASE_URL`, default `http://127.0.0.1:3001/api/v1`).
- Access to the Shawarmas image origin (`IMAGE_BASE_URL`, default `http://localhost:3000`; set `https://shawarmas.donivanovich.dev/cdn` to load brand and product assets from the production CDN).

Build in Release mode with:

```powershell
dotnet build wpf/Shawarmas.sln --configuration Release
```

The client authenticates employee accounts through the REST API, keeps the bearer token in process memory, uploads product images via `POST /api/v1/admin/images/products` (which forwards internally to `image-server:3000`), and creates products using `/categories`, `/colors`, `/sizes`, and `/products`. Public employee registration is disabled; employee accounts are managed by an administrator.

The WPF client has no MySQL connector or database credentials. See [Architecture](../docs/ARCHITECTURE.md) and [Deployment](../docs/DEPLOYMENT.md).
