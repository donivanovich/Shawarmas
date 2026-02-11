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
using Wpf10_Shawarmas.MVVM.View;
using Wpf10_Shawarmas.MVVM.Model;
using Wpf10_Shawarmas.Services;

namespace Wpf10_Shawarmas
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class ViewLogin : Window
    {
        public ViewLogin()
        {
            InitializeComponent();
        }

        string username;
        string password;

        private int intentos = 0;
        private DateTime? bloqueo = null;

        private async void BtnLogin_Click(object sender, RoutedEventArgs e) // Boton para loguearse
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

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password)) // Validacion de campos vacios
            {
                MessageBox.Show("Introduce usuario y contraseña");
                return;
            }

            BtnLogin.IsEnabled = false;
            BtnSignUp.IsEnabled = false;
            BtnGuest.IsEnabled = false;

            var empleadoService = new ServiceWorker(); // Servicio para manejar empleados
            var todosEmpleados = await empleadoService.ObtenerTodos(); // Obtener todos los empleados

            BtnLogin.IsEnabled = true;
            BtnSignUp.IsEnabled = true;
            BtnGuest.IsEnabled = true;

            var empleado = todosEmpleados.FirstOrDefault(emp =>
                emp.Mail == username && ServiceWorker.VerifyPassword(password, emp.Passw)); // Buscar empleado con las credenciales proporcionadas

            if (empleado != null) // Si se encuentra el empleado, abrir el menu principal
            {
                intentos = 0;
                bloqueo = null;

                var mainmenu = new WindowsMainMenu(empleado); // Pasar el empleado logueado al menu principal
                mainmenu.Show();
                this.Close();
            }
            else
            {
                intentos++;
                if (intentos >= 3)
                {
                    bloqueo = DateTime.Now.AddMinutes(1);
                    MessageBox.Show("3 intentos fallidos. Espera 1 minuto.");
                    PwdPassword.Clear();
                }
                else
                {
                    MessageBox.Show($"Credenciales incorrectas. Intentos restantes: {3 - intentos}");
                }
                PwdPassword.Clear();
            }
        }

        private void BtnSignUp_Click(object sender, RoutedEventArgs e) // Boton para registrarse
        {
            ViewSignUp signUpWindow = new ViewSignUp();
            signUpWindow.Show();
            this.Close();
        }

        private async void BtnGuest_Click(object sender, RoutedEventArgs e) // Boton para entrar como invitado
        {
            username = "donnie@shawarmas.com";
            password = "1234";

            var empleadoService = new ServiceWorker(); // Servicio para manejar empleados
            var todosEmpleados = await empleadoService.ObtenerTodos(); // Obtener todos los empleados

            var empleado = todosEmpleados.FirstOrDefault(emp =>
                emp.Mail == username && emp.Passw == password); // Buscar empleado con las credenciales proporcionadas

            if (empleado != null) // Si se encuentra el empleado, abrir el menu principal
            {
                var mainmenu = new WindowsMainMenu(empleado); // Pasar el empleado logueado al menu principal
                mainmenu.Show();
                this.Close();
            }
            else
            {
                MessageBox.Show("Usuario o contraseña incorrectos");
                PwdPassword.Clear();
            }
        }
    }
}