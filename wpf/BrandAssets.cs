using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Imaging;

namespace Shawarmas
{
    internal static class BrandAssets
    {
        private static readonly string BaseUrl = (Environment.GetEnvironmentVariable("IMAGE_BASE_URL") ?? "http://localhost:3000").TrimEnd('/');

        public static void SetWindowIcon(Window window, string filename)
        {
            try
            {
                var image = new BitmapImage();
                image.BeginInit();
                image.UriSource = new Uri($"{BaseUrl}/brand/{filename}");
                image.CacheOption = BitmapCacheOption.OnLoad;
                image.EndInit();
                window.Icon = image;
            }
            catch (Exception)
            {
                // Keep the window usable when the image server is unavailable.
            }
        }

        public static void SetLogo(Image control)
        {
            try
            {
                control.Source = new BitmapImage(LogoUri);
            }
            catch (Exception)
            {
                // Keep the window usable when the image server is unavailable.
            }
        }

        public static Uri LogoUri => new($"{BaseUrl}/brand/logo.png");
    }
}
