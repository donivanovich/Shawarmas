using System.Text.Json.Nodes;
using Shawarmas.MVVM.Model;

namespace Shawarmas.Services
{
    public class ServiceProduct
    {
        public List<string> GetAllSizes() => Lookup("/catalog/sizes", "talla");
        public List<string> GetAllCategories() => Lookup("/catalog/categories", "categoria");
        public List<string> GetAllColours() => Lookup("/catalog/colors", "color");

        public async Task<bool> InsertProduct(string marca, string modelo, string categoria, string color, string talla, int stock, decimal precio, string rutaImagen)
        {
            try
            {
                var data = await ApiClient.Get("/catalog/categories");
                int categoryId = data.AsArray().First(x => string.Equals(x?["categoria"]?.GetValue<string>(), categoria, StringComparison.OrdinalIgnoreCase))!["id_categoria"]!.GetValue<int>();
                var colors = await ApiClient.Get("/catalog/colors");
                int colorId = colors.AsArray().First(x => string.Equals(x?["color"]?.GetValue<string>(), color, StringComparison.OrdinalIgnoreCase))!["id_color"]!.GetValue<int>();
                var sizes = await ApiClient.Get("/catalog/sizes");
                int sizeId = sizes.AsArray().First(x => string.Equals(x?["talla"]?.GetValue<string>(), talla, StringComparison.OrdinalIgnoreCase))!["id_talla"]!.GetValue<int>();
                await ApiClient.Post("/products", new { marca, modelo, precio, fk_categoria = categoryId, imagen = rutaImagen, variants = new[] { new { fk_color = colorId, fk_talla = sizeId, stock, imagen = rutaImagen } } });
                return true;
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine(ex.Message); return false; }
        }

        private static List<string> Lookup(string path, string name)
        {
            try
            {
                var data = ApiClient.Get(path).GetAwaiter().GetResult();
                return data.AsArray().Select(x => x?[name]?.GetValue<string>()).Where(x => x is not null).Select(x => x!).ToList();
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine(ex.Message); return new(); }
        }
    }
}
