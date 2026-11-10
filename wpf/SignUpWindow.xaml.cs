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
using Shawarmas.MVVM.Model;
using Shawarmas.Services;

namespace Shawarmas.MVVM.View
{
    public partial class SignUpWindow : Window
    {
        public SignUpWindow()
        {
            InitializeComponent();
            BrandAssets.SetWindowIcon(this, "favicon.ico");
        }

        private async void BtnSignUp_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(TxtName.Text) ||
                string.IsNullOrWhiteSpace(TxtSurename1.Text) ||
                string.IsNullOrWhiteSpace(TxtEmail.Text) ||
                string.IsNullOrWhiteSpace(PwdPassword.Password))
            {
                MessageBox.Show("Completa todos los campos");
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
                MessageBox.Show("Ese correo ya está registrado");
                TxtEmail.Focus();
                return;
            }

            if (await service.CreateEmpleyee(nuevoEmpleado))
            {
                MessageBox.Show("Empleado registrado correctamente");
                LoginWindow loginWindow = new LoginWindow();
                loginWindow.Show();
                this.Close();
            }
            else
            {
                MessageBox.Show("Error de registro. Comprueba los datos");
            }

            BtnSignUp.IsEnabled = true;
            BtnReturn.IsEnabled = true;
        } 

        private void BtnReturn_Click(object sender, RoutedEventArgs e)
        {
            LoginWindow loginWindow = new LoginWindow();
            loginWindow.Show();
            this.Close();
        } 
    }
}

