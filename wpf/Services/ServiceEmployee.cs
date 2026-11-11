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

        public async Task<bool> CreateEmpleyee(Empleado employee)
        {
            await ApiClient.Post("/admin/employees", new
            {
                nombre = employee.Nombre.Trim(), apellido1 = employee.Apellido1.Trim(),
                apellido2 = string.IsNullOrWhiteSpace(employee.Apellido2) ? null : employee.Apellido2.Trim(),
                email = employee.Mail.Trim(), password = employee.Passw,
                mode_use = string.IsNullOrWhiteSpace(employee.ModeUse) ? "writter" : employee.ModeUse,
                fk_tienda = employee.FkTienda, fullscreen = employee.Fullscreen, mute = employee.Mute,
                volume = Math.Clamp(employee.Volume, 0, 100)
            });
            return true;
        }

        public async Task<bool> EmailExists(string mail)
        {
            var result = await ApiClient.Get("/admin/email-availability?email=" + Uri.EscapeDataString(mail.Trim()));
            return result["available"]?.GetValue<bool>() != true;
        }

        public async Task UpdateEmployeeConfigAsync(Empleado employee)
        {
            await ApiClient.Patch("/admin/employees/me/preferences", new { fullscreen = employee.Fullscreen, mute = employee.Mute, volume = Math.Clamp(employee.Volume, 0, 100) });
        }

        public static Empleado FromSession(JsonNode user) => new()
        {
            Id = user["id"]?.GetValue<int>() ?? 0,
            Nombre = user["nombre"]?.GetValue<string>() ?? "",
            Apellido1 = user["apellido1"]?.GetValue<string>() ?? "",
            Apellido2 = user["apellido2"]?.GetValue<string>() ?? "",
            Mail = user["email"]?.GetValue<string>() ?? "",
            ModeUse = user["role"]?.GetValue<string>() ?? "",
            FkTienda = user["fk_tienda"]?.GetValue<int>() ?? 0,
            Fullscreen = user["fullscreen"]?.GetValue<bool>() ?? false,
            Mute = user["mute"]?.GetValue<bool>() ?? false,
            Volume = user["volume"]?.GetValue<int>() ?? 50
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
