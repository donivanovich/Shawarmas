# Shawarmas Java Client

## Requirements and run

- JDK 17 or newer and Maven (Eclipse with m2e is optional).
- Access to the Shawarmas REST API (`API_BASE_URL`, default `http://127.0.0.1:3001/api/v1`).
- Access to the Shawarmas image origin (`IMAGE_BASE_URL`, default `http://localhost:3000`; set `https://shawarmas.donivanovich.dev/cdn` to load images from the production CDN).

Import `app/` as a Maven project and run `com.shawarmas.Login`, or build with:

```sh
mvn -f app/pom.xml -B clean package
```

The client uses the REST API with explicit UTF-8 JSON requests/responses (`application/json; charset=utf-8`) for customer and employee authentication, catalog, stores (`/stores`), orders, inventory, and employee administration. Bearer tokens stay in process memory and renew automatically before expiry.

Employee actions are authorized by the API according to the authenticated role. The Java client has no MySQL connector or database credentials. See [Architecture](../docs/ARCHITECTURE.md) and [Deployment](../docs/DEPLOYMENT.md).
