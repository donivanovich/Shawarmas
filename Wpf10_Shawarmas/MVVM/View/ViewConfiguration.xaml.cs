using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

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

        public ViewConfiguration()
        {
            InitializeComponent();
            Loaded += ViewConfiguration_Loaded;
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

            ToggleFullScreen.IsChecked = WindowStateService.IsFullscreen;
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

