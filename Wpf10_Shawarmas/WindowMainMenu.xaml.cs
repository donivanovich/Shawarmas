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
using Wpf10_Shawarmas.MVVM.View;
using Wpf10_Shawarmas.Services;

namespace Wpf10_Shawarmas
{
    /// <summary>
    /// Lógica de interacción para ViewMainMenu.xaml
    /// </summary>
    public partial class WindowsMainMenu : Window
    {
        public WindowsMainMenu(Empleado? usuario = null)
        {
            InitializeComponent();
            _usuarioLogueado = usuario ?? new Empleado();
            BgMusicInstance = bgMusic;
            ApplyUserConfig();
            MainFrame.Navigate(new ViewEfforts());
        }

        public static MediaElement? BgMusicInstance { get; private set; }
        private readonly Empleado _usuarioLogueado;

        private void BtnEfforts_Click(object sender, RoutedEventArgs e) // Boton para comprar
        {
            MainFrame.Navigate(new ViewEfforts());
        }

        private void BtnConfiguration_Click(object sender, RoutedEventArgs e) // Boton para configuracion
        {
            MainFrame.Navigate(new ViewConfiguration(_usuarioLogueado));
        }

        private void BtnAbout_Click(object sender, RoutedEventArgs e) // Boton acerca de
        {
            MainFrame.Navigate(new ViewAbout());
        }

        private void BtnExit_Click(object sender, RoutedEventArgs e) // Boton para salir
        {
            MessageBoxResult result = MessageBox.Show(
                "¿Seguro que quieres salir de Shawarmas?",
                "Confirmar Salida",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                Application.Current.Shutdown();
            }
        }

        private void MuteToggle_Click(object sender, RoutedEventArgs e)
        {
            if (MuteToggle.IsChecked == true)
            {
                bgMusic.Volume = 0.0;
            }
            else
            {
                bgMusic.Volume = 1.0;
            }
        } // Toggle para mutear la musica

        private void ApplyUserConfig()
        {
            if (!WindowStateService.IsInitialized)
            {
                WindowStateService.OriginalState = WindowState;
                WindowStateService.OriginalStyle = WindowStyle;
                WindowStateService.OriginalResizeMode = ResizeMode;
                WindowStateService.IsInitialized = true;
            }

            if (_usuarioLogueado.Mute)
            {
                bgMusic.Volume = 0.0;
                MuteToggle.IsChecked = true;
            }
            else
            {
                bgMusic.Volume = 1.0;
                MuteToggle.IsChecked = false;
            }

            bgMusic.Volume = _usuarioLogueado.Volume / 100.0;

            if (_usuarioLogueado.Fullscreen)
            {
                WindowState = WindowState.Normal;
                WindowStyle = WindowStyle.None;
                ResizeMode = ResizeMode.NoResize;
                WindowState = WindowState.Maximized;
                WindowStateService.IsFullscreen = true;
            }
            else
            {
                WindowStyle = WindowStateService.OriginalStyle;
                ResizeMode = WindowStateService.OriginalResizeMode;
                WindowState = WindowStateService.OriginalState;
                WindowStartupLocation = WindowStartupLocation.CenterScreen;
                WindowStateService.IsFullscreen = false;
            }

        } // Funcion para aplicar la configuracion del empleado desde la BBDD

        private void BgMusic_MediaEnded(object sender, RoutedEventArgs e)
        {
            bgMusic.Position = TimeSpan.Zero;
            bgMusic.Play();
        } // Control de Musica

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            bgMusic.Play();
            bgMusic.Source = new Uri("Resources/Music/music.mp3", UriKind.Relative);

            bgMusic.Source = new Uri(System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Resources/Music/music.mp3"));
            bgMusic.Play();

        } // Evento para iniciar musica antes de que cargue la ventana
    }
}
