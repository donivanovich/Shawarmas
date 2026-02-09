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
        public List<Producto> Productos { get; set; } = new();

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


    public class Producto
    {
        public int IdProducto { get; set; }
        public int Cantidad { get; set; }
        public string Marca { get; set; } = "";
        public string Modelo { get; set; } = "";
        public decimal Precio { get; set; }
        public int Stock { get; set; }
        public string Categoria { get; set; }
        public string Talla { get; set; }
        public string Color { get; set; }
        public string Imagen { get; set; } = "";
    }
}
