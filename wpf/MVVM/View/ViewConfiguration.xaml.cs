using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using Shawarmas.MVVM.Model;
using Shawarmas.Services;

namespace Shawarmas.MVVM.View
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
        public ViewConfiguration(Empleado? usuario = null)
        {
            InitializeComponent();
            _usuario = usuario ?? new Empleado();
            Loaded += ViewConfiguration_Loaded;
        }

        private Window? _parentWindow;
        private readonly Empleado _usuario;

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
            _parentWindow.WindowStartupLocation = WindowStartupLocation.CenterScreen;

            WindowStateService.IsFullscreen = false;
        } 

        private void VolumeSlider_ValueChanged(object sender, RoutedEventArgs e)
        {
            if (MainWindow.BgMusicInstance != null)
            {
                MainWindow.BgMusicInstance.Volume = SliderVolume.Value;
            }

        } 

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            ToggleFullScreen.IsChecked = _usuario.Fullscreen;
            SliderVolume.Value = _usuario.Volume;

            switch (_usuario.ModeUse.Trim()) { 
                case "writter": ComboBoxModeOfUse.SelectedIndex = 0; 
                    break; 
                case "editor": ComboBoxModeOfUse.SelectedIndex = 1; 
                    break; 
                case "admin": ComboBoxModeOfUse.SelectedIndex = 2; 
                    break; 
                default: ComboBoxModeOfUse.SelectedIndex = 0; 
                    break; 
            }

        } 

        private async void BtnSave_Click(object sender, RoutedEventArgs e)
        {
            if (_usuario == null || _usuario.Id == 0)
            {
                MessageBox.Show("No user logged in");
                return;
            }

            _usuario.Fullscreen = ToggleFullScreen.IsChecked ?? false;
            _usuario.Volume = (int)SliderVolume.Value;

            var service = new ServiceEmployee();

            try
            {
                await service.UpdateEmployeeConfigAsync(_usuario);
                MessageBox.Show("Configuration saved successfully");


                if (MainWindow.BgMusicInstance != null)
                {
                    MainWindow.BgMusicInstance.Volume = _usuario?.Mute == true ? 0.0 : SliderVolume.Value;
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error saving");
            }

        } 

        private Window? FindParentWindow(DependencyObject child)
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

        private void ViewConfiguration_Loaded(object sender, RoutedEventArgs e)
        {
            _parentWindow = FindParentWindow(this);
            if (_parentWindow == null) return;

            if (!WindowStateService.IsInitialized)
            {
                WindowStateService.OriginalState = _parentWindow.WindowState;
                WindowStateService.OriginalStyle = _parentWindow.WindowStyle;
                WindowStateService.OriginalResizeMode = _parentWindow.ResizeMode;
                WindowStateService.IsInitialized = true;
            }

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
            ComboBoxModeOfUse.IsEnabled = false;

            if (MainWindow.BgMusicInstance != null && _usuario != null)
            {
                MainWindow.BgMusicInstance.Volume = _usuario.Mute ? 0.0 : (_usuario.Volume / 100.0);
            }

        } 
    }
}



