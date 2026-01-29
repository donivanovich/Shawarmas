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

        public List<Pedido> ObtenerTodos()
        {
            var dtPedidos = _db.EjecutarQuery("SELECT * FROM pedidos ORDER BY fecha_pedido DESC");
            var listaPedidos = new List<Pedido>();

            foreach (DataRow rowPedido in dtPedidos.Rows)
            {
                var pedido = new Pedido
                {
                    IdPedido = (int)rowPedido["id_pedido"],
                    FechaPedido = (DateTime)rowPedido["fecha_pedido"],
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
                WHERE pp.fk_pedido = {idPedido}");

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