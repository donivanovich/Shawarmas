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
using System.Windows.Shapes;

namespace Wpf10_Shawarmas.MVVM.View
{
    /// <summary>
    /// Lógica de interacción para ViewSignUp.xaml
    /// </summary>
    public partial class ViewSignUp : Window
    {
        public ViewSignUp()
        {
            InitializeComponent();
        }

        private void BtnSignUp_Click(object sender, RoutedEventArgs e)
        {
            string username = TxtName.Text;
            string surename1 = TxtSurename1.Text;
            string surename2 = TxtSurename2.Text;
            string email = TxtEmail.Text;
            string password = PwdPassword.Password;

            // Logica de registro de usuario

            ViewLogin loginWindow = new ViewLogin();
            loginWindow.Show();
            this.Close();
        }
    }
}
