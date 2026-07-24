using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Wpf10_Shawarmas.MVVM.Model
{
    public class Empleado
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = "";
        public string Apellido1 { get; set; } = "";
        public string Apellido2 { get; set; } = "";
        public string Mail { get; set; } = "";
        public string Passw { get; set; } = "";
        public bool Fullscreen { get; set; }
        public bool Mute { get; set; }
        public string ModeUse { get; set; } = "";
        public int Volume { get; set; }
        public int FkTienda { get; set; }
    }
}
