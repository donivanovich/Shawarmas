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

        private void BtnLogin_Click(object sender, RoutedEventArgs e) // Boton para loguearse
        {
            username = TxtUsername.Text.Trim();
            password = PwdPassword.Password.Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password)) // Validacion de campos vacios
            {
                MessageBox.Show("Introduce usuario y contraseña");
                return;
            }

            var empleadoService = new ServiceWorker(); // Servicio para manejar empleados
            var todosEmpleados = empleadoService.ObtenerTodos(); // Obtener todos los empleados

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

        private void BtnSignUp_Click(object sender, RoutedEventArgs e) // Boton para registrarse
        {
            ViewSignUp signUpWindow = new ViewSignUp();
            signUpWindow.Show();
            this.Close();
        }

        private void BtnGuest_Click(object sender, RoutedEventArgs e) // Boton para entrar como invitado
        {
            username = "donnie@shawarmas.com";
            password = "1234";

            var empleadoService = new ServiceWorker(); // Servicio para manejar empleados
            var todosEmpleados = empleadoService.ObtenerTodos(); // Obtener todos los empleados

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