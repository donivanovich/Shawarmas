using System.Text.Json.Nodes;
using Shawarmas.MVVM.Model;

namespace Shawarmas.Services
{
    public class ServiceOrder
    {
        public List<Pedido> GetAllOrders()
        {
            var rows = ApiClient.Get("/orders").GetAwaiter().GetResult().AsArray();
            return rows.Select(row =>
            {
                var order = MapOrder(row!);
                var detail = ApiClient.Get($"/orders/{order.IdPedido}").GetAwaiter().GetResult();
                order.Productos = (detail["items"]?.AsArray() ?? new()).Select(item => new Producto
                {
                    IdProducto = item?["id_producto"]?.GetValue<int>() ?? 0,
                    Cantidad = item?["cantidad"]?.GetValue<int>() ?? 0,
                    Marca = item?["marca"]?.ToString() ?? "", Modelo = item?["modelo"]?.ToString() ?? "",
                    Precio = item?["precio"]?.GetValue<decimal>() ?? 0,
                    Categoria = "", Talla = item?["talla"]?.ToString() ?? "", Color = item?["color"]?.ToString() ?? "",
                    Imagen = item?["imagen"]?.ToString() ?? ""
                }).ToList();
                return order;
            }).ToList();
        }

        public void UpdateOrderDeliveredStatus(int idPedido, bool entregado) =>
            ApiClient.Patch($"/orders/{idPedido}/status", new { entregado }).GetAwaiter().GetResult();

        private static Pedido MapOrder(JsonNode row) => new()
        {
            IdPedido = row["id_pedido"]?.GetValue<int>() ?? 0,
            FechaPedido = DateTime.TryParse(row["fecha_pedido"]?.ToString(), out var date) ? date : DateTime.MinValue,
            Entregado = row["entregado"]?.GetValue<bool>() ?? false,
            Pais = row["pais"]?.ToString() ?? "",
            Ciudad = row["ciudad"]?.ToString() ?? "",
            Calle = row["calle"]?.ToString() ?? "",
            Postal = row["postal"]?.ToString() ?? "",
            FkCliente = row["fk_id_user"]?.GetValue<int>() ?? 0,
            Cliente = new Cliente { Nombre = row["nombre"]?.ToString() ?? "", Apellido1 = row["apellido1"]?.ToString() ?? "", Apellido2 = row["apellido2"]?.ToString() ?? "", Mail = row["mail"]?.ToString() ?? "" },
            Productos = new List<Producto>()
        };
    }
}
