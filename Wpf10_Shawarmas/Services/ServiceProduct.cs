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
        } // Recibir una lista de las tallas

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
        } // Recibir una lista de las categorias

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
        } // Recibir una lista de los colores

        public async Task<bool> InsertProduct(string marca, string modelo, string categoria, string color, string talla, int stock, decimal precio, string rutaImagen)
        {
            try
            {
                var db = new ServiceDatabase();

                string sqlCat = $"SELECT id_categoria FROM categorias WHERE TRIM(categoria) = '{categoria?.Trim().Replace("'", "''")}' LIMIT 1";
                var dtCat = await Task.Run(() => db.ExecuteQuery(sqlCat));
                if (dtCat.Rows.Count == 0)
                {
                    return false;
                }
                int idCategoria = Convert.ToInt32(dtCat.Rows[0]["id_categoria"]);

                string sqlColor = $"SELECT id_color FROM colores WHERE TRIM(color) = '{color?.Trim().Replace("'", "''")}' LIMIT 1";
                var dtColor = await Task.Run(() => db.ExecuteQuery(sqlColor));
                if (dtColor.Rows.Count == 0)
                {
                    return false;
                }
                int idColor = Convert.ToInt32(dtColor.Rows[0]["id_color"]);

                string sqlTalla = $"SELECT id_talla FROM tallas WHERE TRIM(talla) = '{talla?.Trim().Replace("'", "''")}' LIMIT 1";
                var dtTalla = await Task.Run(() => db.ExecuteQuery(sqlTalla));
                if (dtTalla.Rows.Count == 0)
                {
                    return false;
                }
                int idTalla = Convert.ToInt32(dtTalla.Rows[0]["id_talla"]);

                string sqlInsert = $@"INSERT INTO productos (marca, modelo, fk_categoria, fk_color, fk_talla, stock, precio, imagen) 
                              VALUES ('{marca?.Trim().Replace("'", "''")}', 
                                      '{modelo?.Trim().Replace("'", "''")}', 
                                      {idCategoria}, {idColor}, {idTalla}, {stock}, {precio}, 
                                      '{rutaImagen?.Replace("'", "''")}')";

                await Task.Run(() => db.ExecuteCommand(sqlInsert));
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"💥 CRITICAL ERROR: {ex.Message}");
                return false;
            }
        } // Crear un nuevo producto
    }
}
