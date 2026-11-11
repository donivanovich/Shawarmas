# Shawarmas Java Client

## Requirements and run

- JDK 17 or newer and Maven (Eclipse with m2e is optional).
- The Shawarmas REST API at `http://127.0.0.1:3001/api/v1`, or set `API_BASE_URL` to another API base URL.

Import `app/` as a Maven project and run `com.shawarmas.Login`, or build with `mvn -f app/pom.xml package`. The client uses the API for customer and employee authentication, catalog, orders, inventory, and employee administration. API bearer tokens stay in process memory and are renewed before expiry.

Employee actions are authorized by the API according to the authenticated role. The Java client has no MySQL connector or database credentials. See the root README for the Docker setup and [database guidance](../docs/DATABASE.md).
