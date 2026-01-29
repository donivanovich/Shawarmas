using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Wpf10_Shawarmas.MVVM.Model
{
    public class ModelOrderDetail
    {
        public int IdPedido { get; set; }
        public List<ModelProductOrder> Productos { get; set; }
        public decimal PrecioTotal =>
            Productos.Sum(p => p.Precio * p.Cantidad);
    }
}
