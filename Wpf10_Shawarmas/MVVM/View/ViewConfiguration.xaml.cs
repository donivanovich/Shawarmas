using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using Wpf10_Shawarmas.MVVM.Model;
using Wpf10_Shawarmas.Services;

namespace Wpf10_Shawarmas.MVVM.View
{
    public static class WindowStateService
    {
        public static bool IsFullscreen { get; set; } = false;

        public static WindowState OriginalState { get; set; }
        public static WindowStyle OriginalStyle { get; set; }
        public static ResizeMode OriginalResizeMode { get; set; }

        public static bool IsInitialized { get; set; } = false;
    }

    public partial class ViewConfiguration : Page
    {
        private Window _parentWindow;
        private readonly Empleado _usuario;

        public ViewConfiguration(Empleado usuario = null)
        {
            InitializeComponent();
            _usuario = usuario ?? new Empleado();
            Loaded += ViewConfiguration_Loaded;
        }

        private void ViewConfiguration_Loaded(object sender, RoutedEventArgs e)
        {
            _parentWindow = FindParentWindow(this);
            if (_parentWindow == null) return;

            ToggleFullScreen.IsChecked = _usuario.Fullscreen;
            SliderVolume.Value = _usuario.Volume;

            switch (_usuario.ModeUse.Trim())
            {
                case "writter":
                    ComboBoxModeOfUse.SelectedIndex = 0;
                    break;
                case "editor":
                    ComboBoxModeOfUse.SelectedIndex = 1;
                    break;
                case "admin":
                    ComboBoxModeOfUse.SelectedIndex = 2;
                    break;
                default:
                    ComboBoxModeOfUse.SelectedIndex = 0;
                    break;
            }

            WindowsMainMenu.BgMusicInstance.Volume = _usuario.Mute ? 0.0 : (_usuario.Volume / 100.0);

            if (!WindowStateService.IsInitialized)
            {
                WindowStateService.OriginalState = _parentWindow.WindowState;
                WindowStateService.OriginalStyle = _parentWindow.WindowStyle;
                WindowStateService.OriginalResizeMode = _parentWindow.ResizeMode;
                WindowStateService.IsInitialized = true;
            }

        }

        private void ToggleFullScreen_Checked(object sender, RoutedEventArgs e)
        {
            if (_parentWindow == null) return;

            _parentWindow.WindowStyle = WindowStyle.None;
            _parentWindow.ResizeMode = ResizeMode.NoResize;
            _parentWindow.WindowState = WindowState.Maximized;

            WindowStateService.IsFullscreen = true;
        }

        private void ToggleFullScreen_Unchecked(object sender, RoutedEventArgs e)
        {
            if (_parentWindow == null) return;

            _parentWindow.WindowStyle = WindowStateService.OriginalStyle;
            _parentWindow.ResizeMode = WindowStateService.OriginalResizeMode;
            _parentWindow.WindowState = WindowStateService.OriginalState;

            WindowStateService.IsFullscreen = false;
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
        }

        private void BtnSave_Click(object sender, RoutedEventArgs e)
        {
            if (_usuario == null || _usuario.Id == 0)
            {
                MessageBox.Show("No hay usuario logueado");
                return;
            }

            // 🔥 Lee controles actualizados
            _usuario.Fullscreen = ToggleFullScreen.IsChecked ?? false;
            //_usuario.Mute = MuteToggle.IsChecked ?? false;  // Tu toggle
            _usuario.ModeUse = ((ComboBoxItem)ComboBoxModeOfUse.SelectedItem)?.Content?.ToString() ?? "writter";
            _usuario.Volume = (int)SliderVolume.Value;  // 0.0-1.0 → 0-100

            var service = new ServiceWorker();

            if (service.ActualizarConfig(_usuario))
            {
                MessageBox.Show("✅ Configuración guardada en DB!");

                // Aplica inmediatamente
                WindowsMainMenu.BgMusicInstance.Volume = _usuario.Mute ? 0.0 : (SliderVolume.Value);
                //MuteToggle.IsChecked = _usuario.Mute;
            }
            else
            {
                MessageBox.Show("❌ Error al guardar");
            }
        }

        private void VolumeSlider_ValueChanged(object sender, RoutedEventArgs e)
        {
            WindowsMainMenu.BgMusicInstance.Volume = SliderVolume.Value;
        }

        private Window FindParentWindow(DependencyObject child)
        {
            DependencyObject parent = child;

            while (parent != null)
            {
                if (parent is Window window)
                    return window;

                parent = VisualTreeHelper.GetParent(parent);
            }

            return null;
        }
    }
}

