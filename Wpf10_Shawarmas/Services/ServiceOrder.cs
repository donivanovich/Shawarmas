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

        // ===============================
        // PEDIDOS RESUMEN (panel izquierdo)
        // ===============================
        public List<ModelOrderSummary> GetPedidos()
        {
            var lista = new List<ModelOrderSummary>();

            var dt = _db.EjecutarQuery(@"
                SELECT p.id_pedido, p.fecha_pedido, p.entregado,
                       c.nombre
                FROM pedidos p
                JOIN clientes c ON p.fk_id_user = c.id_user
                ORDER BY p.fecha_pedido DESC
            ");

            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new ModelOrderSummary
                {
                    IdPedido = (int)row["id_pedido"],
                    FechaPedido = (DateTime)row["fecha_pedido"],
                    Entregado = (bool)row["entregado"],
                    NombreCliente = row["nombre"]?.ToString()?.Trim() ?? ""
                });
            }

            return lista;
        }

        // ===============================
        // DETALLE DEL PEDIDO (panel derecho)
        // ===============================
        public ModelOrderDetail GetPedidoDetalle(int idPedido)
        {
            var pedido = new ModelOrderDetail
            {
                IdPedido = idPedido,
                Productos = new List<ModelProductOrder>()
            };

            var dt = _db.EjecutarQuery($@"
                SELECT pr.marca, pr.modelo, pr.precio, pr.imagen,
                       t.talla, c.color,
                       pp.cantidad
                FROM productos_pedidos pp
                JOIN productos pr ON pp.fk_producto = pr.id_producto
                JOIN tallas t ON pr.fk_talla = t.id_talla
                JOIN colores c ON pr.fk_color = c.id_color
                WHERE pp.fk_pedido = {idPedido}
            ");

            foreach (DataRow row in dt.Rows)
            {
                pedido.Productos.Add(new ModelProductOrder
                {
                    Marca = row["marca"]?.ToString()?.Trim() ?? "",
                    Modelo = row["modelo"]?.ToString()?.Trim() ?? "",
                    Precio = (decimal)row["precio"],
                    Cantidad = (int)row["cantidad"],
                    Talla = row["talla"]?.ToString()?.Trim() ?? "",
                    Color = row["color"]?.ToString()?.Trim() ?? "",
                    Imagen = row["imagen"]?.ToString()?.Trim() ?? ""
                });
            }

            return pedido;
        }

        // =================================================
        // (OPCIONAL) Tu método antiguo, NO rompe nada
        // =================================================
        public List<Pedido> ObtenerTodos()
        {
            var dtPedidos = _db.EjecutarQuery(
                "SELECT * FROM pedidos ORDER BY fecha_pedido DESC");

            var listaPedidos = new List<Pedido>();

            foreach (DataRow rowPedido in dtPedidos.Rows)
            {
                var pedido = new Pedido
                {
                    IdPedido = (int)rowPedido["id_pedido"],
                    FechaPedido = (DateTime)rowPedido["fecha_pedido"],
                    Entregado = (bool)rowPedido["entregado"],
                    Pais = rowPedido["pais"]?.ToString()?.Trim() ?? "",
                    Ciudad = rowPedido["ciudad"]?.ToString()?.Trim() ?? "",
                    Calle = rowPedido["calle"]?.ToString()?.Trim() ?? "",
                    Postal = rowPedido["postal"]?.ToString()?.Trim() ?? "",
                    FkCliente = (int)rowPedido["fk_id_user"],
                    FkTienda = (int)rowPedido["fk_tienda"]
                };

                pedido.Lineas = ObtenerLineasPedido(pedido.IdPedido);
                listaPedidos.Add(pedido);
            }

            return listaPedidos;
        }

        private List<LineaPedido> ObtenerLineasPedido(int idPedido)
        {
            var lineas = new List<LineaPedido>();

            var dtLineas = _db.EjecutarQuery($@"
                SELECT pp.id_producto_pedido, pp.fk_producto, pp.fk_pedido, pp.cantidad,
                       p.marca, p.modelo, p.precio, p.imagen, p.stock
                FROM productos_pedidos pp 
                JOIN productos p ON pp.fk_producto = p.id_producto 
                WHERE pp.fk_pedido = {idPedido}
            ");

            foreach (DataRow row in dtLineas.Rows)
            {
                lineas.Add(new LineaPedido
                {
                    Id = (int)row["id_producto_pedido"],
                    FkProducto = (int)row["fk_producto"],
                    FkPedido = (int)row["fk_pedido"],
                    Cantidad = (int)row["cantidad"],
                    Producto = new Producto
                    {
                        IdProducto = (int)row["fk_producto"],
                        Marca = row["marca"]?.ToString()?.Trim() ?? "",
                        Modelo = row["modelo"]?.ToString()?.Trim() ?? "",
                        Precio = (decimal)row["precio"],
                        Imagen = row["imagen"]?.ToString()?.Trim() ?? "",
                        Stock = (int)row["stock"]
                    }
                });
            }

            return lineas;
        }
    }
}