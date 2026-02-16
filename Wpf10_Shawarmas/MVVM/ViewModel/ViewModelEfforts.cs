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
        public class Celda : INotifyPropertyChanged
        {
            public event PropertyChangedEventHandler? PropertyChanged;
            protected void OnPropertyChanged([CallerMemberName] string? propertyName = null)
            {
                PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
            }

            private double _probabilidad;
            private int _estado;
            public double Probabilidad
            {
                get => _probabilidad;
                set { _probabilidad = value; OnPropertyChanged(); }
            }
            public int Estado
            {
                get => _estado;
                set { _estado = value; OnPropertyChanged(); }
            }
        }

        public ViewModelEfforts()
        {
            _serviceOrder = new ServiceOrder();

            var pedidosOriginales = _serviceOrder.GetAllOrders();
            Pedidos = new ObservableCollection<Pedido>(pedidosOriginales);

            SeleccionarPedidoCommand = new RelayCommand<Pedido>(SeleccionarPedido);
            MarcarComoCompletadoCommand = new RelayCommand<object>(MarcarComoCompletado, CanMarcarComoCompletadoObj);
            InicializarGrillaCommand = new RelayCommand<object>(InicializarGrilla, CanInicializarGrilla);
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public ObservableCollection<Pedido> Pedidos { get; set; }
        private Pedido? _pedidoSeleccionado;
        public Pedido? PedidoSeleccionado
        {
            get => _pedidoSeleccionado;
            set
            {
                _pedidoSeleccionado = value;
                OnPropertyChanged();
                CommandManager.InvalidateRequerySuggested();
            }
        }
        private int _numFilas = 5;
        public int NumFilas
        {
            get => _numFilas;
            set { _numFilas = value; OnPropertyChanged(); }
        }
        private int _numColumnas = 8;
        public int NumColumnas
        {
            get => _numColumnas;
            set { _numColumnas = value; OnPropertyChanged(); }
        }
        private double _probInicial = 0.5;
        public double ProbInicial
        {
            get => _probInicial;
            set { _probInicial = value; OnPropertyChanged(); }
        }
        private int _estadoInicial = 0;
        public int EstadoInicial
        {
            get => _estadoInicial;
            set { _estadoInicial = value; OnPropertyChanged(); }
        }
        private ObservableCollection<ObservableCollection<Celda>>? _grilla;
        public ObservableCollection<ObservableCollection<Celda>>? Grilla
        {
            get => _grilla;
            set { _grilla = value; OnPropertyChanged(); }
        }

        public ICommand SeleccionarPedidoCommand { get; }
        public ICommand MarcarComoCompletadoCommand { get; }
        public ICommand InicializarGrillaCommand { get; }

        private ServiceOrder _serviceOrder;

        private void InicializarGrilla(object obj)
        {
            if (NumFilas <= 0 || NumColumnas <= 0) return;

            var nuevaGrilla = new ObservableCollection<ObservableCollection<Celda>>();
            for (int i = 0; i < NumFilas; i++)
            {
                var fila = new ObservableCollection<Celda>();
                for (int j = 0; j < NumColumnas; j++)
                {
                    fila.Add(new Celda { Probabilidad = ProbInicial, Estado = EstadoInicial });
                }
                nuevaGrilla.Add(fila);
            }
            Grilla = nuevaGrilla;
        }

        private bool CanInicializarGrilla(object obj)
        {
            return NumFilas > 0 && NumColumnas > 0;
        }

        private void SeleccionarPedido(Pedido pedido)
        {
            PedidoSeleccionado = pedido;
        }

        private void MarcarComoCompletado(object obj)
        {
            if (obj is Pedido pedido)
            {
                pedido.Entregado = true;
                _serviceOrder.UpdateOrderDeliveredStatus(pedido.IdPedido, true);

                var pedidosActualizados = _serviceOrder.GetAllOrders();
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
