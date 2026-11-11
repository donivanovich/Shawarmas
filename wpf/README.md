# Shawarmas WPF Client

## Requirements

- Windows and .NET 8 SDK with WPF targeting support.
- The Shawarmas API running at `http://127.0.0.1:3001/api/v1`, or set `API_BASE_URL` to another API URL.

Build with `dotnet build wpf/Shawarmas.csproj` and run from Visual Studio or the build output. The client authenticates employee accounts through the REST API and keeps the bearer token in process memory. Employee accounts are created by an administrator; public employee registration is disabled.

Product lookups, order listing and delivery status, and employee preferences use the API. Catalog creation requires an employee role. The client does not need MySQL credentials or a MySQL connector.
