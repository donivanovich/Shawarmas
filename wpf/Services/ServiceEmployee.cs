using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Security.Cryptography;
using MySql.Data.MySqlClient;
using System.Threading.Tasks;
using System.Windows;
using Shawarmas.MVVM.Model;

namespace Shawarmas.Services
{
    class ServiceEmployee
    {
        public ServiceEmployee()
        {
            _db = new ServiceDatabase();
        }

        private readonly ServiceDatabase _db;

        public async Task<List<Empleado>> GetAllEmployees()
        {
            return await Task.Run(() =>
            {
                var dt = _db.ExecuteQuery("SELECT * FROM empleados");
                var lista = new List<Empleado>();

                foreach (DataRow row in dt.Rows)
                {
                    lista.Add(new Empleado
                    {
                        Id = Convert.ToInt32(row["id_empleado"]),
                        Nombre = row["nombre"].ToString() ?? "",
                        Apellido1 = row["apellido1"].ToString() ?? "",
                        Apellido2 = row["apellido2"]?.ToString() ?? "",
                        Mail = row["mail"].ToString() ?? "",
                        Passw = row["passw"]?.ToString()?.Trim() ?? "",
                        Fullscreen = Convert.ToBoolean(row["fullscreen"]),
                        Mute = Convert.ToBoolean(row["mute"]),
                        ModeUse = row["mode_use"].ToString() ?? "",
                        Volume = Convert.ToInt32(row["volume"]),
                        FkTienda = Convert.ToInt32(row["fk_tienda"])
                    });
                }
                return lista;
            });
        } 

        public async Task<bool> CreateEmpleyee(Empleado nuevoEmpleado)
        {
            try
            {
                string passwordHash = GeneratePasswordHash(nuevoEmpleado.Passw);

                const string sql = @"INSERT INTO empleados
                    (nombre, apellido1, apellido2, mail, passw, fullscreen, mute, mode_use, volume, fk_tienda)
                    VALUES (@nombre, @apellido1, @apellido2, @mail, @passw, @fullscreen, @mute, @mode, @volume, @tienda)";
                await Task.Run(() => _db.ExecuteCommand(sql,
                    new MySqlParameter("@nombre", nuevoEmpleado.Nombre),
                    new MySqlParameter("@apellido1", nuevoEmpleado.Apellido1),
                    new MySqlParameter("@apellido2", nuevoEmpleado.Apellido2),
                    new MySqlParameter("@mail", nuevoEmpleado.Mail),
                    new MySqlParameter("@passw", passwordHash),
                    new MySqlParameter("@fullscreen", nuevoEmpleado.Fullscreen),
                    new MySqlParameter("@mute", nuevoEmpleado.Mute),
                    new MySqlParameter("@mode", nuevoEmpleado.ModeUse),
                    new MySqlParameter("@volume", nuevoEmpleado.Volume),
                    new MySqlParameter("@tienda", nuevoEmpleado.FkTienda)));
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.Message);
                return false;
            }
        } 

        public async Task<bool> EmailExists(string mail)
        {
            try
            {
                var resultado = await Task.Run(() =>
                {
                    var dt = _db.ExecuteQuery("SELECT COUNT(*) as total FROM empleados WHERE mail = @mail", new MySqlParameter("@mail", mail));
                    return Convert.ToInt32(dt.Rows[0]["total"]) > 0;
                });
                return resultado;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.Message);
                return false;
            }
        } 

        public bool UpdateEmployeeConfig(Empleado empleado)
        {
            int volumeSeguro = Math.Max(0, Math.Min(255, empleado.Volume));

            const string sql = @"UPDATE empleados SET fullscreen = @fullscreen, mute = @mute,
                mode_use = @mode, volume = @volume WHERE id_empleado = @id";

            try
            {
                _db.ExecuteCommand(sql,
                    new MySqlParameter("@fullscreen", empleado.Fullscreen),
                    new MySqlParameter("@mute", empleado.Mute),
                    new MySqlParameter("@mode", empleado.ModeUse),
                    new MySqlParameter("@volume", volumeSeguro),
                    new MySqlParameter("@id", empleado.Id));
                return true;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"ID {empleado.Id}\n{ex.Message}");
                return false;
            }
        } 

        private static string GeneratePasswordHash(string password)
        {
            if (string.IsNullOrWhiteSpace(password)) return "";

            byte[] salt = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
                rng.GetBytes(salt);

            string saltB64 = Convert.ToBase64String(salt);
            string toHash = password + saltB64;

            using var derive = new Rfc2898DeriveBytes(password, salt, 120000, HashAlgorithmName.SHA256);
            return $"pbkdf2${Convert.ToBase64String(salt)}${Convert.ToBase64String(derive.GetBytes(32))}";
        } 

        public static bool VerifyPassword(string password, string storedHash)
        {
            if (string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(storedHash))
                return false;

            try
            {
                var parts = storedHash.Split('$');
                if (parts.Length != 3 || parts[0] != "pbkdf2") return false;
                var salt = Convert.FromBase64String(parts[1]);
                var expected = Convert.FromBase64String(parts[2]);
                using var derive = new Rfc2898DeriveBytes(password, salt, 120000, HashAlgorithmName.SHA256);
                return CryptographicOperations.FixedTimeEquals(derive.GetBytes(expected.Length), expected);
            }
            catch (FormatException) { return false; }
        } 
    }
}
