using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using Wpf10_Shawarmas.MVVM.Model;
using Wpf10_Shawarmas.Services;

namespace Wpf10_Shawarmas.MVVM.ViewModel
{
    public class ViewEffortsViewModel : ViewModelBase
    {
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

        public ViewEffortsViewModel()
        {
            _serviceOrder = new ServiceOrder();
            Pedidos = new ObservableCollection<ModelOrderSummary>(
                _serviceOrder.GetPedidos());

            SeleccionarPedidoCommand =
                new RelayCommand<ModelOrderSummary>(SeleccionarPedido);
        }

        private void SeleccionarPedido(ModelOrderSummary pedido)
        {
            PedidoSeleccionado =
                _serviceOrder.GetPedidoDetalle(pedido.IdPedido);
        }
    }
}
