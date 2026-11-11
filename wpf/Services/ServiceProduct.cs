using System.Text.Json.Nodes;
using Shawarmas.MVVM.Model;

namespace Shawarmas.Services
{
    public class ServiceProduct
    {
        public Task<List<string>> GetAllSizesAsync() => LookupAsync("/sizes", "talla");
        public Task<List<string>> GetAllCategoriesAsync() => LookupAsync("/categories", "categoria");
        public Task<List<string>> GetAllColoursAsync() => LookupAsync("/colors", "color");

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
                string? imagePath = null;
                if (!string.IsNullOrWhiteSpace(rutaImagen)) imagePath = (await ApiClient.UploadImage(rutaImagen))["path"]?.GetValue<string>();
                await ApiClient.Post("/products", new { marca, modelo, precio, fk_categoria = categoryId, imagen = imagePath, variants = new[] { new { fk_color = colorId, fk_talla = sizeId, stock, imagen = imagePath } } });
                return true;
            }
            catch (Exception ex) { throw new InvalidOperationException("Could not create the product through the API: " + ex.Message, ex); }
        }

        private static async Task<List<string>> LookupAsync(string path, string name)
        {
            try
            {
                var data = await ApiClient.Get(path);
                return data.AsArray().Select(x => x?[name]?.GetValue<string>()).Where(x => x is not null).Select(x => x!).ToList();
            }
            catch (Exception ex) { throw new InvalidOperationException("Could not load product options from the API: " + ex.Message, ex); }
        }
    }
}
