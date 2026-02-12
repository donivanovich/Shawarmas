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
using Wpf10_Shawarmas.MVVM.Model;
using Wpf10_Shawarmas.Services;

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

        private async void BtnSignUp_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(TxtName.Text) ||
                string.IsNullOrWhiteSpace(TxtSurename1.Text) ||
                string.IsNullOrWhiteSpace(TxtEmail.Text) ||
                string.IsNullOrWhiteSpace(PwdPassword.Password))
            {
                MessageBox.Show("Debes rellenar todos los campos");
                return;
            }

            var nuevoEmpleado = new Empleado
            {
                Nombre = TxtName.Text.Trim(),
                Apellido1 = TxtSurename1.Text.Trim(),
                Apellido2 = TxtSurename2?.Text?.Trim() ?? "",
                Mail = TxtEmail.Text.Trim(),
                Passw = PwdPassword.Password,

                Fullscreen = false,
                Mute = false,
                ModeUse = "writter",
                Volume = 50,
                FkTienda = 1
            };

            BtnSignUp.IsEnabled = false;
            BtnReturn.IsEnabled = false;

            var service = new ServiceEmployee();

            if (await service.EmailExists(nuevoEmpleado.Mail))
            {
                MessageBox.Show("Ese email ya está registrado");
                TxtEmail.Focus();
                return;
            }

            if (await service.CreateEmpleyee(nuevoEmpleado))
            {
                MessageBox.Show("¡Empleado registrado!");
                ViewLogin loginWindow = new ViewLogin();
                loginWindow.Show();
                this.Close();
            }
            else
            {
                MessageBox.Show("Error al registrar. Revisa los datos.");
            }

            BtnSignUp.IsEnabled = true;
            BtnReturn.IsEnabled = true;
        } // Boton para crear cuenta de empleado

        private void BtnReturn_Click(object sender, RoutedEventArgs e)
        {
            ViewLogin loginWindow = new ViewLogin();
            loginWindow.Show();
            this.Close();
        } // Boton para volver al inicio de sesion
    }
}