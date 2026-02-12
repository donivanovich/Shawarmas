using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using Wpf10_Shawarmas.MVVM.Model;

namespace Wpf10_Shawarmas.Services
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
                        Id = (int)row["id_empleado"],
                        Nombre = row["nombre"].ToString() ?? "",
                        Apellido1 = row["apellido1"].ToString() ?? "",
                        Apellido2 = row["apellido2"]?.ToString() ?? "",
                        Mail = row["mail"].ToString() ?? "",
                        Passw = row["passw"]?.ToString()?.Trim() ?? "",
                        Fullscreen = (bool)row["fullscreen"],
                        Mute = (bool)row["mute"],
                        ModeUse = row["mode_use"].ToString() ?? "",
                        Volume = (int)(byte)row["volume"],
                        FkTienda = (int)row["fk_tienda"]
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

                string sql = $@"INSERT INTO empleados 
                    (nombre, apellido1, apellido2, mail, passw, fullscreen, mute, mode_use, volume, fk_tienda)
                    VALUES (
                        '{nuevoEmpleado.Nombre.Replace("'", "''")}', 
                        '{nuevoEmpleado.Apellido1.Replace("'", "''")}', 
                        '{nuevoEmpleado.Apellido2?.Replace("'", "''") ?? ""}', 
                        '{nuevoEmpleado.Mail.Replace("'", "''")}', 
                        '{passwordHash.Replace("'", "''")}', 
                        {(nuevoEmpleado.Fullscreen ? 1 : 0)},
                        {(nuevoEmpleado.Mute ? 1 : 0)},
                        '{nuevoEmpleado.ModeUse.Replace("'", "''")}', 
                        {nuevoEmpleado.Volume},
                        {nuevoEmpleado.FkTienda}
                    )";

                await Task.Run(() => _db.ExecuteCommand(sql));
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<bool> EmailExists(string mail)
        {
            try
            {
                var resultado = await Task.Run(() =>
                {
                    var dt = _db.ExecuteQuery($"SELECT COUNT(*) as total FROM empleados WHERE mail = '{mail.Replace("'", "''")}'");
                    return Convert.ToInt32(dt.Rows[0]["total"]) > 0;
                });
                return resultado;
            }
            catch
            {
                return false;
            }
        }

        public bool UpdateEmployeeConfig(Empleado empleado)
        {
            int volumeSeguro = Math.Max(0, Math.Min(255, empleado.Volume));

            string sql = $@"UPDATE empleados SET 
                fullscreen = {(empleado.Fullscreen ? 1 : 0)},
                mute = {(empleado.Mute ? 1 : 0)},
                mode_use = '{empleado.ModeUse.Replace("'", "''")}',
                volume = {volumeSeguro}
                WHERE id_empleado = {empleado.Id}";

            try
            {
                _db.ExecuteCommand(sql);
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

            using (var md5 = MD5.Create())
            {
                byte[] hash = md5.ComputeHash(Encoding.UTF8.GetBytes(toHash));

                byte[] result = new byte[32];
                Array.Copy(salt, 0, result, 0, 16);
                Array.Copy(hash, 0, result, 16, 16);
                return Convert.ToBase64String(result);
            }
        }

        public static bool VerifyPassword(string password, string storedHash)
        {
            if (string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(storedHash))
                return false;

            try
            {
                byte[] data = Convert.FromBase64String(storedHash);
                byte[] salt = new byte[16];
                Array.Copy(data, 0, salt, 0, 16);

                string toHash = password + Convert.ToBase64String(salt);
                using (var md5 = MD5.Create())
                {
                    byte[] newHash = md5.ComputeHash(Encoding.UTF8.GetBytes(toHash));
                    byte[] oldHash = new byte[16];
                    Array.Copy(data, 16, oldHash, 0, 16);
                    return CryptographicOperations.FixedTimeEquals(newHash, oldHash);
                }
            }
            catch { return false; }
        }
    }
}