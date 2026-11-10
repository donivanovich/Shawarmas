using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Shawarmas.MVVM.Model;

namespace Shawarmas.Services
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

        public async Task<bool> InsertProduct(string marca, string modelo, string categoria, string color, string talla, int stock, decimal precio, string rutaImagen)
        {
            try
            {
                var db = new ServiceDatabase();

                const string sqlCat = "SELECT id_categoria FROM categorias WHERE TRIM(categoria) = @categoria LIMIT 1";
                var dtCat = await Task.Run(() => db.ExecuteQuery(sqlCat, new MySqlParameter("@categoria", categoria?.Trim())));
                if (dtCat.Rows.Count == 0)
                {
                    return false;
                }
                int idCategoria = Convert.ToInt32(dtCat.Rows[0]["id_categoria"]);

                const string sqlColor = "SELECT id_color FROM colores WHERE TRIM(color) = @color LIMIT 1";
                var dtColor = await Task.Run(() => db.ExecuteQuery(sqlColor, new MySqlParameter("@color", color?.Trim())));
                if (dtColor.Rows.Count == 0)
                {
                    return false;
                }
                int idColor = Convert.ToInt32(dtColor.Rows[0]["id_color"]);

                const string sqlTalla = "SELECT id_talla FROM tallas WHERE TRIM(talla) = @talla LIMIT 1";
                var dtTalla = await Task.Run(() => db.ExecuteQuery(sqlTalla, new MySqlParameter("@talla", talla?.Trim())));
                if (dtTalla.Rows.Count == 0)
                {
                    return false;
                }
                int idTalla = Convert.ToInt32(dtTalla.Rows[0]["id_talla"]);

                const string sqlInsert = @"INSERT INTO productos
                    (marca, modelo, fk_categoria, fk_color, fk_talla, stock, precio, imagen)
                    VALUES (@marca, @modelo, @categoria, @color, @talla, @stock, @precio, @imagen)";
                await Task.Run(() => db.ExecuteCommand(sqlInsert,
                    new MySqlParameter("@marca", marca?.Trim()),
                    new MySqlParameter("@modelo", modelo?.Trim()),
                    new MySqlParameter("@categoria", idCategoria),
                    new MySqlParameter("@color", idColor),
                    new MySqlParameter("@talla", idTalla),
                    new MySqlParameter("@stock", stock),
                    new MySqlParameter("@precio", precio),
                    new MySqlParameter("@imagen", rutaImagen)));
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"💥 CRITICAL ERROR: {ex.Message}");
                return false;
            }
        } 
    }
}


