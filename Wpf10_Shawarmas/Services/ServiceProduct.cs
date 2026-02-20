using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Wpf10_Shawarmas.MVVM.Model;

namespace Wpf10_Shawarmas.Services
{
    public class ServiceProduct
    {
        public ServiceProduct()
        {
            _db = new ServiceDatabase();
        }

        private readonly ServiceDatabase _db;

        public List<string> GetAllSizes()
        {
            string sql = "SELECT DISTINCT talla FROM tallas ORDER BY talla";

            try
            {
                DataTable dt = _db.ExecuteQuery(sql);
                return dt.AsEnumerable()
                 .Select(row => row.Field<string>("talla"))
                 .Where(size => size is not null)
                 .Select(size => size!)
                 .ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error GetAllSizes: {ex.Message}");
                return new List<string>();
            }
        }

        public List<string> GetAllCategories()
        {
            string sql = "SELECT DISTINCT categoria FROM categorias ORDER BY categoria";

            try
            {
                DataTable dt = _db.ExecuteQuery(sql);
                return dt.AsEnumerable()
                 .Select(row => row.Field<string>("categoria"))
                 .Where(size => size is not null)
                 .Select(size => size!)
                 .ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error GetAllSizes: {ex.Message}");
                return new List<string>();
            }
        }

        public List<string> GetAllColours()
        {
            string sql = "SELECT DISTINCT color FROM colores ORDER BY color";

            try
            {
                DataTable dt = _db.ExecuteQuery(sql);
                return dt.AsEnumerable()
                 .Select(row => row.Field<string>("color"))
                 .Where(size => size is not null)
                 .Select(size => size!)
                 .ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error GetAllColours: {ex.Message}");
                return new List<string>();
            }
        }

        public bool InsertProducto(string marca, string modelo, string categoria, string color, string talla, int stock, decimal precio, string rutaImagen)
        {
            try
            {
                string connectionString = "Server=localhost;Port=3309;Database=shawarmas;Uid=root;Pwd=1234;";
                using var conn = new MySqlConnection(connectionString);
                conn.Open();

                // 1. ID CATEGORÍA (Verifica NULL)
                int idCategoria;
                using (var cmd = new MySqlCommand("SELECT id FROM categorias WHERE categoria = @cat LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@cat", categoria ?? "");
                    var result = cmd.ExecuteScalar();
                    if (result == null)
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ CATEGORÍA NO ENCONTRADA: {categoria}");
                        return false;
                    }
                    idCategoria = Convert.ToInt32(result);
                }

                // 2. ID COLOR (Verifica NULL)
                int idColor;
                using (var cmd = new MySqlCommand("SELECT id FROM colores WHERE color = @color LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@color", color ?? "");
                    var result = cmd.ExecuteScalar();
                    if (result == null)
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ COLOR NO ENCONTRADO: {color}");
                        return false;
                    }
                    idColor = Convert.ToInt32(result);
                }

                // 3. ID TALLA (Verifica NULL)
                int idTalla;
                using (var cmd = new MySqlCommand("SELECT id FROM tallas WHERE talla = @talla LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@talla", talla ?? "");
                    var result = cmd.ExecuteScalar();
                    if (result == null)
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ TALLA NO ENCONTRADA: {talla}");
                        return false;
                    }
                    idTalla = Convert.ToInt32(result);
                }

                // 4. INSERT FINAL (Usa los IDs obtenidos)
                string sql = @"INSERT INTO productos (marca, modelo, categoria_id, color_id, talla_id, stock, precio, imagen) 
                       VALUES (@marca, @modelo, @cat_id, @color_id, @talla_id, @stock, @precio, @imagen)";

                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@marca", marca ?? "");
                    cmd.Parameters.AddWithValue("@modelo", modelo ?? "");
                    cmd.Parameters.AddWithValue("@cat_id", idCategoria);
                    cmd.Parameters.AddWithValue("@color_id", idColor);
                    cmd.Parameters.AddWithValue("@talla_id", idTalla);
                    cmd.Parameters.AddWithValue("@stock", stock);
                    cmd.Parameters.AddWithValue("@precio", precio);
                    cmd.Parameters.AddWithValue("@imagen", rutaImagen ?? "");

                    int filas = cmd.ExecuteNonQuery();
                    return filas > 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"💥 ERROR CRÍTICO: {ex.Message}");
                return false;
            }
        }


    }
}
