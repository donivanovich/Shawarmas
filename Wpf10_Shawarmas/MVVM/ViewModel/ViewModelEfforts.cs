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

        public ObservableCollection<ModelOrderSummary> Pedidos { get; set; }

        private ModelOrderDetail _pedidoSeleccionado;
        public ModelOrderDetail PedidoSeleccionado
        {
            get => _pedidoSeleccionado;
            set
            {
                _pedidoSeleccionado = value;
                OnPropertyChanged();
            }
        }

        public ICommand SeleccionarPedidoCommand { get; }
        private ServiceOrder _serviceOrder;

        public ViewModelEfforts()
        {
            _serviceOrder = new ServiceOrder();
            Pedidos = new ObservableCollection<ModelOrderSummary>(_serviceOrder.GetPedidos());
            SeleccionarPedidoCommand = new RelayCommand<ModelOrderSummary>(SeleccionarPedido);
        }

        private void SeleccionarPedido(ModelOrderSummary pedido)
        {
            PedidoSeleccionado = _serviceOrder.GetPedidoDetalle(pedido.IdPedido);
        }
    }
}