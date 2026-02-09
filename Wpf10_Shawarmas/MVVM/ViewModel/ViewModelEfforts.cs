using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using Wpf10_Shawarmas.MVVM.Model;
using Wpf10_Shawarmas.Services;

namespace Wpf10_Shawarmas.MVVM.ViewModel
{
    public class ViewModelEfforts : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        // Lista de pedidos que se bindea a la UI
        public ObservableCollection<Pedido> Pedidos { get; set; }

        // Pedido seleccionado (detalle)
        private Pedido _pedidoSeleccionado;
        public Pedido PedidoSeleccionado
        {
            get => _pedidoSeleccionado;
            set
            {
                _pedidoSeleccionado = value;
                OnPropertyChanged();
            }
        }

        // Comando para cuando se selecciona un pedido en la lista
        public ICommand SeleccionarPedidoCommand { get; }

        private ServiceOrder _serviceOrder;

        public ViewModelEfforts()
        {
            _serviceOrder = new ServiceOrder();

            // Supongo que tu servicio ahora tiene GetAllPedidos() que devuelve List<Pedido>
            var pedidosOriginales = _serviceOrder.GetAllPedidos();
            Pedidos = new ObservableCollection<Pedido>(pedidosOriginales);

            SeleccionarPedidoCommand = new RelayCommand<Pedido>(SeleccionarPedido);
        }

        private void SeleccionarPedido(Pedido pedido)
        {
            // Al seleccionar de la lista, simplemente se convierte en "detalle"
            PedidoSeleccionado = pedido;
        }
    }
}