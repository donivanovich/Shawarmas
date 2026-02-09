using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Wpf10_Shawarmas.MVVM.Model
{
    public class Pedido
    {
        public int IdPedido { get; set; }
        public DateTime FechaPedido { get; set; }
        public bool Entregado { get; set; }
        public string Pais { get; set; } = "";
        public string Ciudad { get; set; } = "";
        public string Calle { get; set; } = "";
        public string Postal { get; set; } = "";
        public int FkCliente { get; set; }
        public int FkTienda { get; set; }

        public Cliente Cliente { get; set; } = new();
        public List<LineaPedido> Lineas { get; set; } = new();

        public decimal Total => Lineas.Sum(l => l.Producto.Precio * l.Cantidad);
        public string ClienteNombre => $"{Cliente.Nombre} {Cliente.Apellido1}";
    }

    public class Cliente
    {
        public int IdCliente { get; set; }
        public string Nombre { get; set; } = "";
        public string Apellido1 { get; set; } = "";
        public string Apellido2 { get; set; } = "";
        public string Mail { get; set; } = "";
        public string Passw { get; set; } = "";
    }

    public class LineaPedido
    {
        public int Id { get; set; }
        public int FkProducto { get; set; }
        public int FkPedido { get; set; }
        public int Cantidad { get; set; }
        public Producto Producto { get; set; } = new();
    }

    public class Producto
    {
        public int IdProducto { get; set; }
        public string Marca { get; set; } = "";
        public string Modelo { get; set; } = "";
        public decimal Precio { get; set; }
        public int Stock { get; set; }
        public int FkCategoria { get; set; }
        public int FkTalla { get; set; }
        public int FkColor { get; set; }
        public string Imagen { get; set; } = "";
    }
}
