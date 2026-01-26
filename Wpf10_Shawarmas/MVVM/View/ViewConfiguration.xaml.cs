using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
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
    /// Lógica de interacción para ViewConfiguration.xaml
    /// </summary>
    public partial class ViewConfiguration : Page
    {
        public ViewConfiguration()
        {
            InitializeComponent();
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {

        }

        private void BtnSave_Click(object sender, RoutedEventArgs e)
        {

        }

        private void VolumeSlider_ValueChanged(object sender, RoutedEventArgs e)
        {
            WindowsMainMenu.BgMusicInstance.Volume = SliderVolume.Value;
        }
    }
}
