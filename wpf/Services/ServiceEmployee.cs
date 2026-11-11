using System.Text.Json.Nodes;
using Shawarmas.MVVM.Model;

namespace Shawarmas.Services
{
    class ServiceEmployee
    {
        public async Task<List<Empleado>> GetAllEmployees()
        {
            var data = await ApiClient.Get("/admin/employees");
            return data.AsArray().Select(row => ToEmployee(row!)).ToList();
        }

        public Task<bool> CreateEmpleyee(Empleado employee) => Task.FromResult(false); // Employee creation requires an administrator account.
        public Task<bool> EmailExists(string mail) => Task.FromResult(false); // The API returns a conflict if an administrator reuses an address.

        public bool UpdateEmployeeConfig(Empleado employee)
        {
            try
            {
                ApiClient.Patch("/admin/employees/me/preferences", new { fullscreen = employee.Fullscreen, mute = employee.Mute, volume = Math.Clamp(employee.Volume, 0, 100) }).GetAwaiter().GetResult();
                return true;
            }
            catch { return false; }
        }

        public static Empleado FromSession(JsonNode user) => new()
        {
            Id = user["id"]?.GetValue<int>() ?? 0,
            Nombre = user["nombre"]?.GetValue<string>() ?? "",
            Apellido1 = user["apellido1"]?.GetValue<string>() ?? "",
            Apellido2 = user["apellido2"]?.GetValue<string>() ?? "",
            Mail = user["email"]?.GetValue<string>() ?? "",
            ModeUse = user["role"]?.GetValue<string>() ?? "",
            FkTienda = user["fk_tienda"]?.GetValue<int>() ?? 0
        };

        private static Empleado ToEmployee(JsonNode row) => new()
        {
            Id = row["id_empleado"]?.GetValue<int>() ?? 0,
            Nombre = row["nombre"]?.GetValue<string>() ?? "",
            Apellido1 = row["apellido1"]?.GetValue<string>() ?? "",
            Apellido2 = row["apellido2"]?.GetValue<string>() ?? "",
            Mail = row["mail"]?.GetValue<string>() ?? "",
            Fullscreen = row["fullscreen"]?.GetValue<bool>() ?? false,
            Mute = row["mute"]?.GetValue<bool>() ?? false,
            ModeUse = row["mode_use"]?.GetValue<string>() ?? "",
            Volume = row["volume"]?.GetValue<int>() ?? 50,
            FkTienda = row["fk_tienda"]?.GetValue<int>() ?? 0
        };
    }
}
