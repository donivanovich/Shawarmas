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

        private void BtnSignUp_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(TxtName.Text) ||
        string.IsNullOrWhiteSpace(TxtSurename1.Text) ||
        string.IsNullOrWhiteSpace(TxtEmail.Text) ||
        string.IsNullOrWhiteSpace(PwdPassword.Password))
            {
                MessageBox.Show("Rellena todos los campos obligatorios");
                return;
            }

            var nuevoEmpleado = new Empleado
            {
                Nombre = TxtName.Text.Trim(),
                Apellido1 = TxtSurename1.Text.Trim(),
                Apellido2 = string.IsNullOrWhiteSpace(TxtSurename2.Text) ? null : TxtSurename2.Text.Trim(),
                Mail = TxtEmail.Text.Trim(),
                Passw = PwdPassword.Password,

                // 🔥 Valores por DEFECTO (configuración después en ViewConfiguration)
                Fullscreen = false,
                Mute = false,
                ModeUse = "writter",  // Empleado básico
                Volume = 50,          // 50%
                FkTienda = 1          // Tienda 1
            };

            var service = new ServiceWorker();

            if (service.MailExiste(nuevoEmpleado.Mail))
            {
                MessageBox.Show("❌ Ese email ya está registrado");
                TxtEmail.Focus();
                return;
            }

            if (service.RegistrarEmpleado(nuevoEmpleado))
            {
                MessageBox.Show("✅ ¡Empleado registrado! Configura en Ajustes.");
                ViewLogin loginWindow = new ViewLogin();
                loginWindow.Show();
                this.Close();
            }
            else
            {
                MessageBox.Show("❌ Error al registrar. Revisa los datos.");
            }
        }
    }
}