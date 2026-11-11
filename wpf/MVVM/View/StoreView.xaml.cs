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
using Shawarmas.MVVM.Model;
using Shawarmas.MVVM.ViewModel;
using Shawarmas.Services;

namespace Shawarmas.MVVM.View
{
    public partial class StoreView : Page
    {
        public StoreView()
        {
            InitializeComponent();
            DataContext = new StoreViewModel();
            Loaded += StoreView_Loaded;
        }

        private string imagePath = "";

        private async void StoreView_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                var serviceProduct = new ServiceProduct();
                CmbCategory.ItemsSource = await serviceProduct.GetAllCategoriesAsync();
                CmbColour.ItemsSource = await serviceProduct.GetAllColoursAsync();
                CmbSize.ItemsSource = await serviceProduct.GetAllSizesAsync();
                if (CmbCategory.Items.Count > 0) CmbCategory.SelectedIndex = 0;
                if (CmbColour.Items.Count > 0) CmbColour.SelectedIndex = 0;
                if (CmbSize.Items.Count > 0) CmbSize.SelectedIndex = 0;
                if (DataContext is StoreViewModel viewModel) await viewModel.LoadOrdersAsync();
            }
            catch (Exception ex) { MessageBox.Show(ex.Message, "Could not load store data"); }
        }

        private void NumberValidationHandler(object sender, TextCompositionEventArgs e)
        {
            TextBox txt = sender as TextBox ?? throw new ArgumentNullException(nameof(sender));
            bool isPrice = txt.Name?.Contains("Price") == true || txt.Name?.Contains("Precio") == true;

            if (isPrice)
            {
                string newText = txt.Text.Insert(txt.CaretIndex, e.Text);
                e.Handled = !decimal.TryParse(newText, out _);
            }
            else
            {
                e.Handled = !int.TryParse(e.Text, out _);
            }
        } 

        private void NumberKeyDownHandler(object sender, KeyEventArgs e)
        {
            if (sender is not TextBox txt)
                return;

            bool isPrice = txt.Name?.Contains("Price") == true ||
                           txt.Name?.Contains("Precio") == true;

            if (e.Key >= Key.D0 && e.Key <= Key.D9 ||
                e.Key >= Key.NumPad0 && e.Key <= Key.NumPad9 ||
                e.Key == Key.Back || e.Key == Key.Delete || e.Key == Key.Tab ||
                e.Key == Key.Left || e.Key == Key.Right || e.Key == Key.Home || e.Key == Key.End)
                return;

            if (isPrice && !txt.Text.Contains(".") &&
                (e.Key == Key.Decimal || e.Key == Key.OemPeriod))
                return;

            e.Handled = true;
        } 

        private void BtnInitialize_Click(object sender, RoutedEventArgs e)
        {
            TxtFilas.GetBindingExpression(TextBox.TextProperty)?.UpdateSource();
            TxtColumnas.GetBindingExpression(TextBox.TextProperty)?.UpdateSource();
        } 

        private void BtnBrowseImage_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new OpenFileDialog
            {
                Title = "Selecciona imagen del producto",
                Filter = "Images|*.jpg;*.jpeg;*.png;*.webp"
            };

            if (dialog.ShowDialog() == true)
            {
                imagePath = dialog.FileName;
            }
        } 

        private async void BtnAddProduct_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var service = new ServiceProduct();

                string? marca = TxtBrand?.Text?.Trim();
                string? modelo = TxtModel?.Text?.Trim();
                string? categoria = CmbCategory?.SelectedItem?.ToString()?.Trim();
                string? color = CmbColour?.SelectedItem?.ToString()?.Trim();
                string? talla = CmbSize?.SelectedItem?.ToString()?.Trim();

                int stock = int.TryParse(TxtStock?.Text, out int s) ? s : 0;
                decimal precio = decimal.TryParse(TxtPrice?.Text, out decimal p) ? p : 0;
                string rutaImagen = imagePath;

                if (string.IsNullOrWhiteSpace(marca) || string.IsNullOrWhiteSpace(modelo) ||
                    string.IsNullOrWhiteSpace(categoria) || string.IsNullOrWhiteSpace(color) ||
                    string.IsNullOrWhiteSpace(talla))
                {
                    MessageBox.Show("❌ Please fill all required fields", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                BtnAddProduct.IsEnabled = false;

                bool exito = await service.InsertProduct(marca!, modelo!, categoria!, color!, talla!, stock, precio, rutaImagen);

                BtnAddProduct.IsEnabled = true;

                if (exito)
                {
                    TxtBrand?.Clear();
                    TxtModel?.Clear();
                    TxtPrice?.Clear();
                    TxtStock?.Clear();

                    CmbCategory!.SelectedIndex = -1;
                    CmbColour!.SelectedIndex = -1;
                    CmbSize!.SelectedIndex = -1;

                    imagePath = "";

                    MessageBox.Show("✅ Product uploaded successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"❌ Error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                BtnAddProduct.IsEnabled = true;
            }
        } 
    }
}

