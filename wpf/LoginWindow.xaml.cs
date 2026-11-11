using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Runtime.CompilerServices;
using Shawarmas.MVVM.View;
using Shawarmas.MVVM.Model;
using Shawarmas.Services;

namespace Shawarmas
{
    public partial class LoginWindow : Window
    {
        public LoginWindow()
        {
            InitializeComponent();
            BrandAssets.SetWindowIcon(this, "favicon.ico");
            BrandAssets.SetLogo(BrandLogo);
        }

        string? username;
        string? password;
        private int intentos = 0;
        private DateTime? bloqueo = null;

        private async void BtnLogin_Click(object sender, RoutedEventArgs e) 
        {
            if (bloqueo.HasValue && DateTime.Now < bloqueo.Value)
            {
                TimeSpan resto = bloqueo.Value - DateTime.Now;
                MessageBox.Show($"Espera {resto.Minutes}m {resto.Seconds}s");
                PwdPassword.Clear();
                return;
            }

            username = TxtUsername.Text.Trim();
            password = PwdPassword.Password.Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password)) 
            {
                MessageBox.Show("Introduce el correo y la contraseña");
                return;
            }

            BtnLogin.IsEnabled = false;
            BtnSignUp.IsEnabled = false;
            BtnGuest.IsEnabled = false;

            try
            {
                var user = await ApiClient.Login(username, password);
                if (user["type"]?.GetValue<string>() == "employee")
                {
                    user = await ApiClient.Get("/auth/me");
                    intentos = 0;
                    bloqueo = null;
                    var mainmenu = new MainWindow(ServiceEmployee.FromSession(user));
                    mainmenu.Show();
                    this.Close();
                }
                else
                {
                    await ApiClient.Logout();
                    MessageBox.Show("This desktop application requires an employee account.", "Access restricted");
                    intentos++;
                    if (intentos >= 3)
                    {
                        bloqueo = DateTime.Now.AddMinutes(1);
                        MessageBox.Show("3 intentos fallidos. Espera 1 minuto.");
                        PwdPassword.Clear();
                    }
                    else
                    {
                        MessageBox.Show($"Credenciales no válidas. Intentos restantes: {3 - intentos}");
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"No se pudo conectar con la base de datos.\n{ex.Message}", "Error de conexión");
            }
            finally
            {
                BtnLogin.IsEnabled = true;
                BtnSignUp.IsEnabled = false;
                BtnGuest.IsEnabled = true;
            }
        }

        private void BtnSignUp_Click(object sender, RoutedEventArgs e) 
        {
            MessageBox.Show("Employee accounts are created by an administrator.", "Registration unavailable");
        }

        private async void BtnGuest_Click(object sender, RoutedEventArgs e)
        {
            await Task.CompletedTask;
            MessageBox.Show("El acceso de invitado está desactivado. Regístrate para continuar.", "Acceso restringido");
        }
    }
}
