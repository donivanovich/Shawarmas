using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
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
using System.Windows.Navigation;
using System.Windows.Shapes;
using Wpf10_Shawarmas.MVVM.Model;
using Wpf10_Shawarmas.MVVM.ViewModel;
using Wpf10_Shawarmas.Services;

namespace Wpf10_Shawarmas.MVVM.View
{
    /// <summary>
    /// Lógica de interacción para ViewShopping.xaml
    /// </summary>
    public partial class ViewEfforts : Page
    {
        public ViewEfforts()
        {
            InitializeComponent();
            var serviceProduct = new ServiceProduct();
            CmbCategory.ItemsSource = serviceProduct.GetAllCategories();
            CmbColour.ItemsSource = serviceProduct.GetAllColours();
            CmbSize.ItemsSource = serviceProduct.GetAllSizes();

            DataContext = new ViewModelEfforts();
        }

        private void BtnInitialize_Click(object sender, RoutedEventArgs e)
        {
            TxtFilas.GetBindingExpression(TextBox.TextProperty)?.UpdateSource();
            TxtColumnas.GetBindingExpression(TextBox.TextProperty)?.UpdateSource();
        }

        string imagenNombre;

        private void BtnBrowseImage_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new OpenFileDialog
            {
                Title = "Selecciona imagen del producto",
                Filter = "Imágenes|*.jpg;*.jpeg;*.png;*.bmp|Todos|*.*"
            };

            if (dialog.ShowDialog() == true)
            {
                string nombreNuevo = $"producto_{DateTime.Now:yyyyMMdd_HHmmss}{System.IO.Path.GetExtension(dialog.FileName)}";

                imagenNombre = nombreNuevo;

                var directorioActual = new System.IO.DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
                string rutaProyecto = null;
                
                while (directorioActual != null && directorioActual.Name != "Wpf10_Shawarmas")
                {
                    directorioActual = directorioActual.Parent;
                }
                
                if (directorioActual != null)
                {
                    rutaProyecto = System.IO.Path.Combine(directorioActual.FullName, "Resources", "productos", nombreNuevo);
                    System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(rutaProyecto));
                    System.IO.File.Copy(dialog.FileName, rutaProyecto, true);
                }

                string rutaEjecutable = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Resources", "productos", nombreNuevo);
                System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(rutaEjecutable));
                System.IO.File.Copy(dialog.FileName, rutaEjecutable, true);

                MessageBox.Show($"¡Copiada en proyecto!\nResources/productos/{nombreNuevo}", "Listo!");
            }
        }

        private void BtnAddProduct_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var service = new ServiceProduct();

                // Lee TODOS controles (ajusta nombres a tu XAML)
                string marca = TxtBrand?.Text?.Trim();
                string modelo = TxtModel?.Text?.Trim();
                string categoria = CmbCategory?.SelectedItem?.ToString();
                string color = CmbColour?.SelectedItem?.ToString();
                string talla = CmbSize?.SelectedItem?.ToString();
                int stock = int.TryParse(TxtStock?.Text, out int s) ? s : 0;
                decimal precio = decimal.TryParse(TxtPrice?.Text, out decimal p) ? p : 0;
                string rutaImagen = string.IsNullOrEmpty(imagenNombre) ? "" : $"/productos/{imagenNombre}";

                string debugInfo = $"🔍 DEBUG DATOS:\n" +
                          $"Marca: '{marca}'\n" +
                          $"Modelo: '{modelo}'\n" +
                          $"Categoría: '{categoria}'\n" +
                          $"Color: '{color}'\n" +
                          $"Talla: '{talla}'\n" +
                          $"Stock: {stock}\n" +
                          $"Precio: {precio}\n" +
                          $"Imagen: '{rutaImagen}'";

                MessageBox.Show(debugInfo, "Datos antes de INSERT", MessageBoxButton.OK, MessageBoxImage.Information);

                // Validaciones
                if (string.IsNullOrEmpty(marca) || string.IsNullOrEmpty(modelo) ||
                    string.IsNullOrEmpty(categoria) || string.IsNullOrEmpty(color) || string.IsNullOrEmpty(talla))
                {
                    MessageBox.Show("❌ Completa marca, modelo, categoría, color y talla", "Error",
                                   MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                // LLAMA InsertProducto (ajusta parámetros a tu Service)
                bool exito = service.InsertProducto(marca, modelo, categoria, color, talla, stock, precio, rutaImagen);

                MessageBox.Show($"RESULTADO service.InsertProducto:\n✅ = {exito}\n\n" +
                       $"Revisa Output/Debug para 'Filas/LastID'",
                       "POST-INSERT", MessageBoxButton.OK, MessageBoxImage.Question);

                if (exito)
                {

                    // Limpia TODO
                    TxtBrand?.Clear();
                    TxtModel?.Clear();
                    TxtPrice?.Clear();
                    TxtStock?.Clear();
                    CmbCategory.SelectedIndex = -1;
                    CmbColour.SelectedIndex = -1;
                    CmbSize.SelectedIndex = -1;
                    imagenNombre = null;
                }
                else
                {
                    MessageBox.Show("❌ Error: Verifica datos en tablas categorias/colores/tallas", "Error",
                                   MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"❌ Error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

    }
}