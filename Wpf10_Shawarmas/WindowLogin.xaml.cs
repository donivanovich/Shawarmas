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

        private void BtnLogin_Click(object sender, RoutedEventArgs e)
        {
            username = TxtUsername.Text;
            password = PwdPassword.Password;

            if (username == "donnie" && password == "1234"){
                WindowsMainMenu mainmenuWindow = new WindowsMainMenu();
                mainmenuWindow.Show();
                this.Close();
            }
        }

        private void BtnSignUp_Click(object sender, RoutedEventArgs e)
        {
            ViewSignUp signUpWindow = new ViewSignUp();
            signUpWindow.Show();
            this.Close();
        }

        private void BtnGuest_Click(object sender, RoutedEventArgs e)
        {
            username = "donnie@shawarmas.com";
            password = "1234";

        }
    }
}