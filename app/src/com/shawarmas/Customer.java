package com.shawarmas;

import java.awt.*;
import com.fasterxml.jackson.databind.JsonNode;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Set;
import java.util.HashMap;
import java.util.HashSet;

import javax.swing.*;
import java.awt.event.*;
import java.net.URL;

public class Customer {

	private JFrame frameCustomer;
	private String customerName = "";
	public static String customerMail = "";
	private List<Map<String, Object>> carrito = new ArrayList<>(); 
	private String pais, ciudad, calle, cp;

	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					Customer window = new Customer();
					window.frameCustomer.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	public Customer() {
		initialize();
	}
	
	private void initialize() {
		addNombre(); 
		
		frameCustomer = new JFrame();
		frameCustomer.getContentPane().setBackground(new Color(255, 255, 255));
		frameCustomer.setTitle("Bienvenido, " + customerName);
		frameCustomer.setIconImage(BrandAssets.load("favicon.ico"));
		frameCustomer.setBounds(100, 100, 570, 450);
		frameCustomer.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frameCustomer.getContentPane().setLayout(null);
		
		JMenuBar menuBar = new JMenuBar();
		menuBar.setBackground(new Color(255, 255, 255));
		frameCustomer.setJMenuBar(menuBar);
		
		JMenu mnOpciones = new JMenu("Opciones");
		mnOpciones.setForeground(new Color(0, 0, 0));
		mnOpciones.setBackground(new Color(255, 255, 255));
		menuBar.add(mnOpciones);
		
			JMenuItem mntmCuenta = new JMenuItem("Cuenta");
			mntmCuenta.setBackground(new Color(255, 255, 255));
			mntmCuenta.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					cuenta(); 
				}
			});
		
			JMenuItem mntmPedidos = new JMenuItem("Pedidos");
			mntmPedidos.setBackground(new Color(255, 255, 255));
			mntmPedidos.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					pedidos(); 
				}
			});
			
			
			JMenuItem mntmCerrarSesion = new JMenuItem("Cerrar Sesión");
			mntmCerrarSesion.setBackground(new Color(255, 255, 255));
			mntmCerrarSesion.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					ApiClient.getInstance().logout();
					frameCustomer.dispose(); 
		    		Login.main(null); 
				}
			});			
			mnOpciones.add(mntmCuenta);
			mnOpciones.add(mntmPedidos);
			mnOpciones.add(mntmCerrarSesion);
		
		JMenu mnCarrito = new JMenu("Carrito");
		mnCarrito.setForeground(new Color(0, 0, 0));
		mnCarrito.setBackground(new Color(255, 255, 255));
		menuBar.add(mnCarrito);
		
			JMenuItem mntmPagar = new JMenuItem("Pagar");
			mntmPagar.setBackground(new Color(255, 255, 255));
			mntmPagar.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					pagar(); 
				}
			});
			mnCarrito.add(mntmPagar);
			
		principal(); 
		
	}
	
private boolean tarjeta() {
    JTextField numeroTarjeta = new JTextField();
    JTextField fechaVencimiento = new JTextField();
    JTextField cvv = new JTextField();
    while (true) {
        JPanel panel = new JPanel(new GridLayout(0, 1));
        panel.add(new JLabel("Número de tarjeta (solo se valida en esta demo):")); panel.add(numeroTarjeta);
        panel.add(new JLabel("Fecha de vencimiento (MM/AA):")); panel.add(fechaVencimiento);
        panel.add(new JLabel("CVV (3 dígitos):")); panel.add(cvv);
        int result = JOptionPane.showConfirmDialog(frameCustomer, panel, "Datos de pago", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
        if (result != JOptionPane.OK_OPTION) return false;
        if (!numeroTarjeta.getText().trim().matches("^\\d{16}$") || !fechaVencimiento.getText().trim().matches("^(0[1-9]|1[0-2])/\\d{2}$") || !cvv.getText().trim().matches("^\\d{3}$")) {
            JOptionPane.showMessageDialog(frameCustomer, "Revisa los datos de pago.", "Datos no válidos", JOptionPane.ERROR_MESSAGE);
            continue;
        }
        return true;
    }
}

private boolean direccion() {
    JTextField paisTxt = new JTextField();
    JTextField ciudadTxt = new JTextField();
    JTextField calleTxt = new JTextField();
    JTextField cpTxt = new JTextField();
    while (true) {
        JPanel panel = new JPanel(new GridLayout(0, 1));
        panel.add(new JLabel("País:")); panel.add(paisTxt);
        panel.add(new JLabel("Ciudad:")); panel.add(ciudadTxt);
        panel.add(new JLabel("Calle:")); panel.add(calleTxt);
        panel.add(new JLabel("Código postal:")); panel.add(cpTxt);
        int result = JOptionPane.showConfirmDialog(frameCustomer, panel, "Dirección de entrega", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
        if (result != JOptionPane.OK_OPTION) return false;
        pais = paisTxt.getText().trim(); ciudad = ciudadTxt.getText().trim(); calle = calleTxt.getText().trim(); cp = cpTxt.getText().trim();
        if (pais.isEmpty() || ciudad.isEmpty() || calle.isEmpty() || cp.isEmpty()) {
            JOptionPane.showMessageDialog(frameCustomer, "Completa todos los datos de envío.", "Datos no válidos", JOptionPane.ERROR_MESSAGE);
            continue;
        }
        return true;
    }
}

private void pagar() {
    if (carrito.isEmpty()) {
        JOptionPane.showMessageDialog(frameCustomer, "Tu carrito está vacío.", "Información", JOptionPane.INFORMATION_MESSAGE);
        return;
    }
    if (!direccion() || !tarjeta()) return;
    try {
        java.util.List<Map<String, Object>> items = new ArrayList<>();
        for (Map<String, Object> cartItem : carrito) {
            items.add(Map.of("productId", cartItem.get("productId"), "variantId", cartItem.get("variantId"), "quantity", cartItem.get("quantity")));
        }
        var result = ApiClient.getInstance().post("/orders", ApiClient.getInstance().object(
            "pais", pais, "ciudad", ciudad, "calle", calle, "postal", cp, "items", items));
        carrito.clear();
        JOptionPane.showMessageDialog(frameCustomer, "Pedido realizado correctamente. Pedido " + result.path("id_pedido").asInt());
    } catch (Exception ex) {
        JOptionPane.showMessageDialog(frameCustomer, ex.getMessage(), "No se pudo completar el pedido", JOptionPane.ERROR_MESSAGE);
    }
}

private void principal() {
    JLabel lblPrecio = new JLabel("0");
    JLabel lblCategoria = new JLabel("Categoría:");
    JButton btnImagen = new JButton("");
    JComboBox<String> comboModelo = new JComboBox<>();
    JComboBox<String> comboTalla = new JComboBox<>();
    JComboBox<String> comboColor = new JComboBox<>();
    JButton btnCarrito = new JButton("Añadir al carrito");
    btnCarrito.setBackground(Color.BLACK); btnCarrito.setForeground(Color.WHITE); btnCarrito.setFocusPainted(false); btnCarrito.setBorderPainted(false);
    btnCarrito.setBounds(40, 324, 140, 23); btnImagen.setBounds(40, 80, 220, 220); btnImagen.setFocusPainted(false); btnImagen.setContentAreaFilled(false); btnImagen.setBorderPainted(false);
    comboModelo.setBounds(406, 107, 150, 24); comboTalla.setBounds(406, 172, 98, 24); comboColor.setBounds(406, 241, 120, 24);
    lblCategoria.setBounds(308, 40, 220, 18); lblPrecio.setBounds(406, 324, 98, 18);
    JLabel lblModelo = new JLabel("Modelo:"); lblModelo.setBounds(308, 111, 80, 18);
    JLabel lblTalla = new JLabel("Talla:"); lblTalla.setBounds(308, 176, 80, 18);
    JLabel lblColor = new JLabel("Color:"); lblColor.setBounds(308, 245, 80, 18);
    frameCustomer.getContentPane().add(btnCarrito); frameCustomer.getContentPane().add(btnImagen);
    frameCustomer.getContentPane().add(comboModelo); frameCustomer.getContentPane().add(comboTalla); frameCustomer.getContentPane().add(comboColor);
    frameCustomer.getContentPane().add(lblModelo); frameCustomer.getContentPane().add(lblTalla); frameCustomer.getContentPane().add(lblColor);
    frameCustomer.getContentPane().add(lblCategoria); frameCustomer.getContentPane().add(lblPrecio);

    Map<String, com.fasterxml.jackson.databind.JsonNode> productsByModel = new java.util.LinkedHashMap<>();
    Map<String, java.util.List<com.fasterxml.jackson.databind.JsonNode>> variantsByModel = new HashMap<>();
    try {
        com.fasterxml.jackson.databind.JsonNode products = ApiClient.getInstance().get("/products?pageSize=100&sort=newest");
        Set<Integer> loadedIds = new HashSet<>();
        for (com.fasterxml.jackson.databind.JsonNode item : products) {
            int productId = item.path("id_producto").asInt();
            if (!loadedIds.add(productId)) continue;
            com.fasterxml.jackson.databind.JsonNode details = ApiClient.getInstance().get("/products/" + productId);
            String key = details.path("marca").asText() + " · " + details.path("modelo").asText();
            if (!productsByModel.containsKey(key)) {
                productsByModel.put(key, details);
                java.util.List<com.fasterxml.jackson.databind.JsonNode> variants = new ArrayList<>();
                details.path("variants").forEach(variants::add);
                variantsByModel.put(key, variants);
                comboModelo.addItem(key);
            }
        }
    } catch (Exception ex) {
        JOptionPane.showMessageDialog(frameCustomer, ex.getMessage(), "No se pudo cargar el catálogo", JOptionPane.ERROR_MESSAGE);
    }

    final boolean[] updating = {false};
    Runnable refreshVariants = () -> {
        if (updating[0]) return;
        String key = (String) comboModelo.getSelectedItem();
        if (key == null) return;
        var product = productsByModel.get(key);
        var variants = variantsByModel.getOrDefault(key, java.util.List.of());
        updating[0] = true;
        String oldSize = (String) comboTalla.getSelectedItem();
        String oldColor = (String) comboColor.getSelectedItem();
        Set<String> sizes = new java.util.TreeSet<>(); Set<String> colors = new java.util.TreeSet<>();
        for (var variant : variants) { sizes.add(variant.path("talla").asText()); colors.add(variant.path("color").asText()); }
        comboTalla.removeAllItems(); sizes.forEach(comboTalla::addItem);
        comboColor.removeAllItems(); colors.forEach(comboColor::addItem);
        if (oldSize != null) comboTalla.setSelectedItem(oldSize);
        if (oldColor != null) comboColor.setSelectedItem(oldColor);
        updating[0] = false;
        lblCategoria.setText("Categoría: " + product.path("categoria").asText());
        lblPrecio.setText(String.format("%.2f €", product.path("precio").asDouble()));
        String imagePath = product.path("imagen").asText("");
        try {
            String imageBase = System.getenv().getOrDefault("IMAGE_BASE_URL", "http://127.0.0.1:3000").replaceAll("/+$", "");
            btnImagen.setIcon(imagePath.isBlank() ? null : new ImageIcon(new ImageIcon(new URL(imageBase + (imagePath.startsWith("/") ? imagePath : "/" + imagePath))).getImage().getScaledInstance(176, 176, Image.SCALE_SMOOTH)));
        } catch (Exception ignored) { btnImagen.setIcon(null); }
    };
    comboModelo.addActionListener(event -> refreshVariants.run());
    comboTalla.addActionListener(event -> { if (!updating[0]) refreshVariants.run(); });
    comboColor.addActionListener(event -> { if (!updating[0]) refreshVariants.run(); });
    btnCarrito.addActionListener(event -> {
        String key = (String) comboModelo.getSelectedItem(); String size = (String) comboTalla.getSelectedItem(); String color = (String) comboColor.getSelectedItem();
        if (key == null || size == null || color == null) return;
        var selected = variantsByModel.getOrDefault(key, java.util.List.of()).stream()
            .filter(v -> v.path("talla").asText().equals(size) && v.path("color").asText().equals(color) && v.path("stock").asInt() > 0).findFirst().orElse(null);
        if (selected == null) { JOptionPane.showMessageDialog(frameCustomer, "La variante seleccionada no tiene stock.", "Sin stock", JOptionPane.WARNING_MESSAGE); return; }
        Map<String, Object> cartItem = new HashMap<>();
        cartItem.put("productId", selected.path("fk_producto").asInt()); cartItem.put("variantId", selected.path("id_variante").asInt()); cartItem.put("quantity", 1);
        carrito.add(cartItem);
        JOptionPane.showMessageDialog(frameCustomer, "Producto añadido al carrito.");
    });
    refreshVariants.run();
}

private void pedidos() {
    try {
        com.fasterxml.jackson.databind.JsonNode orders = ApiClient.getInstance().get("/orders");
        JPanel panel = new JPanel(); panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        boolean found = false;
        for (com.fasterxml.jackson.databind.JsonNode order : orders) {
            found = true;
            int id = order.path("id_pedido").asInt();
            JPanel item = new JPanel(new GridLayout(0, 1));
            item.setBorder(BorderFactory.createTitledBorder("Pedido #" + id));
            item.add(new JLabel("Fecha: " + order.path("fecha_pedido").asText("")));
            item.add(new JLabel(String.format("Total: %.2f €", order.path("total").asDouble())));
            item.add(new JLabel("Estado: " + (order.path("entregado").asBoolean() ? "Entregado" : "Pendiente")));
            com.fasterxml.jackson.databind.JsonNode detail = ApiClient.getInstance().get("/orders/" + id);
            for (com.fasterxml.jackson.databind.JsonNode line : detail.path("items")) {
                item.add(new JLabel(line.path("marca").asText() + " " + line.path("modelo").asText() + " · " + line.path("talla").asText() + " · " + line.path("color").asText() + " × " + line.path("cantidad").asInt()));
            }
            panel.add(item);
        }
        if (!found) panel.add(new JLabel("No tienes pedidos."));
        JOptionPane.showMessageDialog(frameCustomer, panel, "Tus pedidos", JOptionPane.INFORMATION_MESSAGE);
    } catch (Exception ex) {
        JOptionPane.showMessageDialog(frameCustomer, ex.getMessage(), "No se pudieron cargar los pedidos", JOptionPane.ERROR_MESSAGE);
    }
}


private void addNombre() {
    try {
        customerName = ApiClient.getInstance().get("/auth/me").path("nombre").asText("Cliente");
    } catch (Exception ex) {
        customerName = "Cliente";
        JOptionPane.showMessageDialog(null, ex.getMessage(), "No se pudo obtener la cuenta", JOptionPane.ERROR_MESSAGE);
    }
}


private void cuenta() {
    try {
        var user = ApiClient.getInstance().get("/auth/me");
        JPanel panel = new JPanel(new GridLayout(0, 1));
        panel.add(new JLabel("Nombre: " + user.path("nombre").asText()));
        panel.add(new JLabel("Apellidos: " + user.path("apellido1").asText() + " " + user.path("apellido2").asText("")));
        panel.add(new JLabel("Email: " + user.path("mail").asText()));
        JOptionPane.showMessageDialog(frameCustomer, panel, "Tu información", JOptionPane.INFORMATION_MESSAGE);
    } catch (Exception ex) {
        JOptionPane.showMessageDialog(frameCustomer, ex.getMessage(), "No se pudo cargar la cuenta", JOptionPane.ERROR_MESSAGE);
    }
}
}
