using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace Wpf10_Shawarmas.MVVM.View
{
    /// <summary>
    /// Lógica de interacción para ViewAbout.xaml
    /// </summary>
    public partial class ViewAbout : Page
    {
        public ViewAbout()
        {
            InitializeComponent();
        }

        private void BtnReturn_Click(object sender, RoutedEventArgs e)
        {
            if (NavigationService != null && NavigationService.CanGoBack)
            {
                NavigationService.GoBack();
            }

        } // Boton de navegacion de retorno a la Page anterior
    }
}
