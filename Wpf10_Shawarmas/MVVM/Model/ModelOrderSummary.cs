using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Wpf10_Shawarmas.MVVM.Model
{
    public class ModelOrderSummary
    {
        public int IdPedido { get; set; }
        public DateTime FechaPedido { get; set; }
        public bool Entregado { get; set; }
        public string NombreCliente { get; set; }
    }
}
