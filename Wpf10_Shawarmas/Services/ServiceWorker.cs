using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using Wpf10_Shawarmas.MVVM.Model;

namespace Wpf10_Shawarmas.Services
{
    class ServiceWorker
    {
        private readonly ServiceDatabase _db;

        public ServiceWorker()
        {
            _db = new ServiceDatabase();
        }

        public List<Empleado> ObtenerTodos() // Obtiene todos los empleados de la base de datos
        {
            var dt = _db.EjecutarQuery("SELECT * FROM empleados");
            var lista = new List<Empleado>();

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new Empleado
                {
                    Id = (int)row["id_empleado"],
                    Nombre = row["nombre"].ToString(),
                    Apellido1 = row["apellido1"].ToString(),
                    Apellido2 = row["apellido2"]?.ToString() ?? "",
                    Mail = row["mail"].ToString(),
                    Passw = row["passw"]?.ToString()?.Trim() ?? "",
                    Fullscreen = (bool)row["fullscreen"],
                    Mute = (bool)row["mute"],
                    ModeUse = row["mode_use"].ToString(),
                    Volume = (int)(byte)row["volume"],
                    FkTienda = (int)row["fk_tienda"]
                });
            }
            return lista;
        }

        public bool RegistrarEmpleado(Empleado nuevoEmpleado)
        {
            try
            {
                string sql = $@"INSERT INTO empleados 
                    (nombre, apellido1, apellido2, mail, passw, fullscreen, mute, mode_use, volume, fk_tienda)
                    VALUES (
                        '{nuevoEmpleado.Nombre.Replace("'", "''")}', 
                        '{nuevoEmpleado.Apellido1.Replace("'", "''")}', 
                        '{nuevoEmpleado.Apellido2?.Replace("'", "''") ?? ""}', 
                        '{nuevoEmpleado.Mail.Replace("'", "''")}', 
                        '{nuevoEmpleado.Passw.Replace("'", "''")}', 
                        {(nuevoEmpleado.Fullscreen ? 1 : 0)},
                        {(nuevoEmpleado.Mute ? 1 : 0)},
                        '{nuevoEmpleado.ModeUse.Replace("'", "''")}', 
                        {nuevoEmpleado.Volume},
                        {nuevoEmpleado.FkTienda}
                    )";

                _db.EjecutarComando(sql);
                return true;
            }
            catch
            {
                return false;
            }
        }
        public bool MailExiste(string mail)
        {
            try
            {
                var dt = _db.EjecutarQuery($"SELECT COUNT(*) as total FROM empleados WHERE mail = '{mail.Replace("'", "''")}'");
                return Convert.ToInt32(dt.Rows[0]["total"]) > 0;
            }
            catch
            {
                return false;
            }
        }

        public bool ActualizarConfig(Empleado empleado)
        {
            int volumeSeguro = Math.Max(0, Math.Min(255, empleado.Volume));  // 0-255

            string sql = $@"UPDATE empleados SET 
        fullscreen = {(empleado.Fullscreen ? 1 : 0)},
        mute = {(empleado.Mute ? 1 : 0)},
        mode_use = '{empleado.ModeUse.Replace("'", "''")}',
        volume = {volumeSeguro}
        WHERE id_empleado = {empleado.Id}";

            try
            {
                _db.EjecutarComando(sql);
                return true;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"ID {empleado.Id}\n{ex.Message}");
                return false;
            }
        }


        public string DebugEmpleados()
        {
            var dt = _db.EjecutarQuery("SELECT id_empleado, mail, fullscreen, mute, mode_use, volume FROM empleados");
            string debug = "Empleados en DB:\n\n";

            foreach (DataRow row in dt.Rows)
            {
                debug += $"ID {row["id_empleado"]}: {row["mail"]} | " +
                        $"Fullscreen={row["fullscreen"]} | Mute={row["mute"]} | " +
                        $"Mode={row["mode_use"]} | Vol={row["volume"]}\n";
            }

            return debug;
        }
    }
}