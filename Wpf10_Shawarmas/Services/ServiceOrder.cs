using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using Wpf10_Shawarmas.Services;
using Wpf10_Shawarmas.MVVM.Model;

namespace Wpf10_Shawarmas.Services
{
    public class ServiceOrder
    {
        private readonly ServiceDatabase _db;

        public ServiceOrder()
        {
            _db = new ServiceDatabase();
        }

        public List<Pedido> GetAllPedidos()
        {
            var pedidos = new Dictionary<int, Pedido>();

            string sql = @"
                SELECT
                    p.id_pedido,
                    p.fecha_pedido,
                    p.entregado,
                    p.pais,
                    p.ciudad,
                    p.calle,
                    p.postal,
                    p.fk_id_user,
                    p.fk_tienda,

                    c.nombre,
                    c.apellido1,
                    c.apellido2,
                    c.mail,

                    pr.id_producto,
                    pr.marca,
                    pr.modelo,
                    pr.precio,
                    pr.stock,
                    pr.fk_categoria,
                    pr.fk_talla,
                    pr.fk_color,
                    pr.imagen,

                    ca.categoria,
                    t.talla,
                    co.color,

                    pp.cantidad
                FROM pedidos p
                JOIN clientes c ON p.fk_id_user = c.id_user
                LEFT JOIN productos_pedidos pp ON p.id_pedido = pp.fk_pedido
                LEFT JOIN productos pr ON pp.fk_producto = pr.id_producto
                LEFT JOIN categorias ca ON pr.fk_categoria = ca.id_categoria
                LEFT JOIN tallas t ON pr.fk_talla = t.id_talla
                LEFT JOIN colores co ON pr.fk_color = co.id_color
                ORDER BY p.id_pedido
            ";


            var dt = _db.EjecutarQuery(sql);

            foreach (DataRow row in dt.Rows)
            {
                int idPedido = Convert.ToInt32(row["id_pedido"]);

                if (!pedidos.TryGetValue(idPedido, out var pedido))
                {
                    pedido = new Pedido
                    {
                        IdPedido = idPedido,
                        FechaPedido = (DateTime)row["fecha_pedido"],
                        Entregado = Convert.ToBoolean(row["entregado"]),
                        Pais = row["pais"]?.ToString()?.Trim() ?? "",
                        Ciudad = row["ciudad"]?.ToString()?.Trim() ?? "",
                        Calle = row["calle"]?.ToString()?.Trim() ?? "",
                        Postal = row["postal"]?.ToString()?.Trim() ?? "",
                        FkCliente = Convert.ToInt32(row["fk_id_user"]),
                        FkTienda = Convert.ToInt32(row["fk_tienda"]),
                        Cliente = new Cliente
                        {
                            Nombre = row["nombre"]?.ToString()?.Trim() ?? "",
                            Apellido1 = row["apellido1"]?.ToString()?.Trim() ?? "",
                            Apellido2 = row["apellido2"]?.ToString()?.Trim() ?? "",
                            Mail = row["mail"]?.ToString()?.Trim() ?? ""
                        },
                        Productos = new List<Producto>()
                    };

                    pedidos.Add(idPedido, pedido);
                }

                if (!row.IsNull("id_producto"))
                {
                    pedido.Productos.Add(new Producto
                    {
                        IdProducto = Convert.ToInt32(row["id_producto"]),
                        Marca = row["marca"]?.ToString()?.Trim() ?? "",
                        Modelo = row["modelo"]?.ToString()?.Trim() ?? "",
                        Precio = Convert.ToDecimal(row["precio"]),
                        Stock = Convert.ToInt32(row["stock"]),
                        Categoria = row["categoria"]?.ToString()?.Trim() ?? "",
                        Talla = row["talla"]?.ToString()?.Trim() ?? "",
                        Color = row["color"]?.ToString()?.Trim() ?? "",
                        Imagen = row["imagen"]?.ToString()?.Trim() ?? "",
                        Cantidad = Convert.ToInt32(row["cantidad"])
                    });
                }
            }

            return new List<Pedido>(pedidos.Values);
        }

        public void SetPedidoAsEntregado(int idPedido, bool entregado)
        {
            string sql = $"UPDATE pedidos SET entregado = {(entregado ? 1 : 0)} WHERE id_pedido = {idPedido}";
            _db.EjecutarQuery(sql);
        }

    }
}