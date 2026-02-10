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

        public ObservableCollection<Pedido> Pedidos { get; set; }

        private Pedido _pedidoSeleccionado;
        public Pedido PedidoSeleccionado
        {
            get => _pedidoSeleccionado;
            set
            {
                _pedidoSeleccionado = value;
                OnPropertyChanged();
                CommandManager.InvalidateRequerySuggested();
            }
        }

        public ICommand SeleccionarPedidoCommand { get; }
        public ICommand MarcarComoCompletadoCommand { get; }

        private ServiceOrder _serviceOrder;

        public ViewModelEfforts()
        {
            _serviceOrder = new ServiceOrder();

            var pedidosOriginales = _serviceOrder.GetAllPedidos();
            Pedidos = new ObservableCollection<Pedido>(pedidosOriginales);

            SeleccionarPedidoCommand = new RelayCommand<Pedido>(SeleccionarPedido); 
            MarcarComoCompletadoCommand = new RelayCommand<object>(MarcarComoCompletado, CanMarcarComoCompletadoObj);
        }

        private void SeleccionarPedido(Pedido pedido)
        {
            PedidoSeleccionado = pedido;
        }

        private void MarcarComoCompletado(object obj)
        {
            if (PedidoSeleccionado != null)
            {
                PedidoSeleccionado.Entregado = true;
                _serviceOrder.SetPedidoAsEntregado(PedidoSeleccionado.IdPedido, true);

                var pedidosActualizados = _serviceOrder.GetAllPedidos();
                Pedidos.Clear();
                foreach (var p in pedidosActualizados)
                {
                    Pedidos.Add(p);
                }

                CommandManager.InvalidateRequerySuggested();
            }
        }

        private bool CanMarcarComoCompletadoObj(object obj)
        {
            return PedidoSeleccionado != null && !PedidoSeleccionado.Entregado;
        }
    }
}