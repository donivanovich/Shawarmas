package com.shawarmas;

import java.awt.*;
import java.util.*;
import javax.swing.*;
import java.awt.event.*;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

public class Employee {

	private JFrame frmEmployee;
	private String name, surname1, surname2, id, store, country, city, address, zip_code, passw;
	public static String mail;
	private ImageIcon logo;

	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					Employee window = new Employee();
					window.frmEmployee.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	public Employee() {
		initialize();
	}

	private void initialize() {
		Image logoImage = BrandAssets.load("logo.png");
		logo = new ImageIcon(logoImage == null ? new ImageIcon().getImage() : logoImage.getScaledInstance(239, 239, Image.SCALE_SMOOTH));
		frmEmployee = new JFrame();
		frmEmployee.setTitle("Employee Management");
		frmEmployee.setIconImage(BrandAssets.load("favicon.ico"));
	    frmEmployee.setBounds(100, 100, 462, 300);
	    frmEmployee.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    frmEmployee.getContentPane().setLayout(null);
	    
	    JButton btnIcon = new JButton("");
		btnIcon.setBackground(new Color(255, 255, 255));
		btnIcon.setBounds(0, 0, 446, 239);
		btnIcon.setIcon(logo);
		btnIcon.setFocusPainted(false);      
		btnIcon.setBorderPainted(false);       
		btnIcon.setContentAreaFilled(false);   
		btnIcon.setOpaque(false);              
		btnIcon.setFocusable(false);           
		frmEmployee.getContentPane().add(btnIcon);

	    JMenuBar menuBar = new JMenuBar();
	    frmEmployee.setJMenuBar(menuBar);

	    JMenu mnInventario = new JMenu("Inventario"); 										
	    mnInventario.addActionListener(new ActionListener() {
	    	public void actionPerformed(ActionEvent e) {
	    	}
	    });
	    menuBar.add(mnInventario);
	    
		    JMenuItem mntmOrder = new JMenuItem("Hacer Pedido");
		    mntmOrder.addActionListener(new ActionListener() {
		    	public void actionPerformed(ActionEvent e) {
		    		hacerPedido(); 
		    	}
		    });	
		    
		    JMenuItem mntmProducto = new JMenuItem("Añadir Producto");
		    mntmProducto.addActionListener(new ActionListener() {
		    	public void actionPerformed(ActionEvent e) {
		    		addProducto(); 
		    	}
		    });
		    
		    JMenuItem mntmStock = new JMenuItem("Actualizar Stock");
		    mntmStock.addActionListener(new ActionListener() {
		    	public void actionPerformed(ActionEvent e) {
		    		actualizarStock(); 
		    	}
		    });
		    
		    mnInventario.add(mntmOrder);
		    mnInventario.add(mntmProducto);
		    mnInventario.add(mntmStock);
	    
	    JMenu mnNewMenu = new JMenu("Añadir...");                     			   
	    menuBar.add(mnNewMenu);
    	    
    	    JMenuItem mntmColor = new JMenuItem("Color");
    	    mntmColor.addActionListener(new ActionListener() {
    	    	public void actionPerformed(ActionEvent e) {
    	    		addColor(); 
    	    	}
    	    });
    	    
    	    JMenuItem mntmStore = new JMenuItem("Tienda");
    	    mntmStore.addActionListener(new ActionListener() {
    	    	public void actionPerformed(ActionEvent e) {
    	    		addTienda(); 
    	    	}
    	    });
    	    
    	    JMenuItem mntmEmployee = new JMenuItem("Empleado");
    	    mntmEmployee.addActionListener(new ActionListener() {
    	    	public void actionPerformed(ActionEvent e) {
    	    		addEmpleado(); 
    	    	}
    	    });
    	    
    	    JMenuItem mntmTalla = new JMenuItem("Talla");
    	    mntmTalla.addActionListener(new ActionListener() {
    	    	public void actionPerformed(ActionEvent e) {
    	    		addTalla(); 
    	    	}
    	    });
    	    
    	    JMenuItem mntmCategoria = new JMenuItem("Categoría");
    	    mntmCategoria.addActionListener(new ActionListener() {
    	    	public void actionPerformed(ActionEvent e) {
    	    		addCategoria(); 
    	    	}
    	    });
    	    
    	    JMenuItem mntmCustomer = new JMenuItem("Cliente");
    	    mntmCustomer.addActionListener(new ActionListener() {
    	    	public void actionPerformed(ActionEvent e) {
    	    		addCliente(); 
    	    	}
    	    });
    	    
    	    mnNewMenu.add(mntmCustomer);
    	    mnNewMenu.add(mntmCategoria);
    	    mnNewMenu.add(mntmEmployee);
    	    mnNewMenu.add(mntmTalla);
    	    mnNewMenu.add(mntmColor);
    	    mnNewMenu.add(mntmStore);
	    
	    JMenu mnEditar = new JMenu("Modificar...");                                           
	    menuBar.add(mnEditar);
	    
		    JMenuItem mntmClienteEditar = new JMenuItem("Cliente");
		    mntmClienteEditar.addActionListener(new ActionListener() {
		    	public void actionPerformed(ActionEvent e) {
		    		editCliente(); 
		    	}
		    });
		    
		    JMenuItem mntmInfoPersonal = new JMenuItem("Tu Información");
		    mntmInfoPersonal.addActionListener(new ActionListener() {
		    	public void actionPerformed(ActionEvent e) {
		    		editTuInfo(); 
		    	}
		    });
		    
		    JMenuItem mntmEmpleado = new JMenuItem("Empleado");
		    mntmEmpleado.addActionListener(new ActionListener() {
		    	public void actionPerformed(ActionEvent e) {
		    		editEmpleado(); 
		    	}
		    });
		    
		    mnEditar.add(mntmEmpleado);
		    mnEditar.add(mntmInfoPersonal);
		    mnEditar.add(mntmClienteEditar);
	    
	    JMenu mnVer = new JMenu("Ver...");
	    menuBar.add(mnVer);
	    
		    JMenuItem mntmEstadoPedidos = new JMenuItem("Estado Pedidos");
		    mntmEstadoPedidos.addActionListener(new ActionListener() {
		    	public void actionPerformed(ActionEvent e) {
		    		verEstadoPedidos(); 
		    	}
		    });
		    
		    JMenuItem mntmDatos = new JMenuItem("Tus datos");
		    mntmDatos.addActionListener(new ActionListener() {
		    	public void actionPerformed(ActionEvent e) {
		    		verTusDatos(); 
		    	}
		    });
		    
		    mnVer.add(mntmDatos);
		    mnVer.add(mntmEstadoPedidos);
	    	    
	    JMenu mnOpciones = new JMenu("Opciones");
	    menuBar.add(mnOpciones);
	    
    	    JMenuItem mntmCerrar = new JMenuItem("Cerrar Sesión");
    	    mntmCerrar.addActionListener(new ActionListener() {
    	    	public void actionPerformed(ActionEvent e) {
                    ApiClient.getInstance().logout();
    	    		frmEmployee.dispose(); 
    	    		Login.main(null); 
    	    	}
    	    });
    	    
    	    mnOpciones.add(mntmCerrar);
	}
	
private final ApiClient api = ApiClient.getInstance();

private void reportApiError(Exception error) {
    if (error instanceof InterruptedException) Thread.currentThread().interrupt();
    JOptionPane.showMessageDialog(frmEmployee, error.getMessage() == null ? "The API request failed." : error.getMessage(), "API error", JOptionPane.ERROR_MESSAGE);
}

private JsonNode get(String path) throws Exception { return api.get(path); }
private JsonNode post(String path, JsonNode body) throws Exception { return api.post(path, body); }
private JsonNode patch(String path, JsonNode body) throws Exception { return api.patch(path, body); }
private List<JsonNode> rows(JsonNode data) {
    List<JsonNode> result = new ArrayList<>();
    if (data != null && data.isArray()) data.forEach(result::add);
    return result;
}
private String value(JsonNode row, String key) { return row.path(key).isNull() ? "" : row.path(key).asText(""); }
private String[] ask(String title, String... labels) {
    JTextField[] fields = new JTextField[labels.length];
    JPanel panel = new JPanel(new GridLayout(0, 1));
    for (int i = 0; i < labels.length; i++) { panel.add(new JLabel(labels[i])); fields[i] = new JTextField(); panel.add(fields[i]); }
    if (JOptionPane.showConfirmDialog(frmEmployee, panel, title, JOptionPane.OK_CANCEL_OPTION) != JOptionPane.OK_OPTION) return null;
    return Arrays.stream(fields).map(field -> field.getText().trim()).toArray(String[]::new);
}
private void success(String message) { JOptionPane.showMessageDialog(frmEmployee, message, "Shawarmas", JOptionPane.INFORMATION_MESSAGE); }

private void hacerPedido() {
    try {
        String[] shipping = ask("New order", "Customer ID", "Country", "City", "Street", "Postal code");
        if (shipping == null) return;
        int customerId = Integer.parseInt(shipping[0]);
        List<JsonNode> inventory = rows(get("/admin/inventory?pageSize=500"));
        List<JsonNode> available = inventory.stream().filter(item -> item.path("stock").asInt() > 0).toList();
        if (available.isEmpty()) { success("There are no products in stock."); return; }
        ArrayNode items = api.array();
        while (true) {
            String[] labels = available.stream().map(item -> item.path("id_variante").asText() + " | " + item.path("marca").asText() + " " + item.path("modelo").asText() + " | " + item.path("color").asText() + " / " + item.path("talla").asText() + " | stock " + item.path("stock").asText()).toArray(String[]::new);
            JComboBox<String> product = new JComboBox<>(labels);
            JTextField quantity = new JTextField("1");
            JPanel panel = new JPanel(new GridLayout(0, 1)); panel.add(new JLabel("Product variant")); panel.add(product); panel.add(new JLabel("Quantity")); panel.add(quantity);
            if (JOptionPane.showConfirmDialog(frmEmployee, panel, "Add order item", JOptionPane.OK_CANCEL_OPTION) != JOptionPane.OK_OPTION) break;
            JsonNode selected = available.get(product.getSelectedIndex());
            int count = Integer.parseInt(quantity.getText().trim());
            items.add(api.object("productId", selected.path("id_producto").asInt(), "variantId", selected.path("id_variante").asInt(), "quantity", count));
            if (JOptionPane.showConfirmDialog(frmEmployee, "Add another product?", "Order", JOptionPane.YES_NO_OPTION) != JOptionPane.YES_OPTION) break;
        }
        if (items.isEmpty()) return;
        List<JsonNode> stores = rows(get("/admin/stores"));
        if (stores.isEmpty()) throw new IllegalStateException("No store is configured.");
        String[] storeLabels = stores.stream().map(s -> s.path("id_tienda").asText() + " | " + s.path("calle").asText() + ", " + s.path("ciudad").asText()).toArray(String[]::new);
        int storeIndex = JOptionPane.showOptionDialog(frmEmployee, "Choose fulfillment store", "Store", JOptionPane.DEFAULT_OPTION, JOptionPane.QUESTION_MESSAGE, null, storeLabels, storeLabels[0]);
        if (storeIndex < 0) return;
        ObjectNode body = api.object("customerId", customerId, "storeId", stores.get(storeIndex).path("id_tienda").asInt(), "pais", shipping[1], "ciudad", shipping[2], "calle", shipping[3], "postal", shipping[4]);
        body.set("items", items); post("/admin/orders", body); success("Order created.");
    } catch (Exception error) { reportApiError(error); }
}

private void addProducto() {
    try {
        List<JsonNode> categories = rows(get("/categories")), sizes = rows(get("/sizes")), colors = rows(get("/colors"));
        String[] fields = ask("Add product", "Brand", "Model", "Price", "Category ID", "Size ID", "Color ID", "Initial stock");
        if (fields == null) return;
        double price = Double.parseDouble(fields[2]); int category = Integer.parseInt(fields[3]); int size = Integer.parseInt(fields[4]); int color = Integer.parseInt(fields[5]); int stock = Integer.parseInt(fields[6]);
        if (categories.stream().noneMatch(row -> row.path("id_categoria").asInt() == category) || sizes.stream().noneMatch(row -> row.path("id_talla").asInt() == size) || colors.stream().noneMatch(row -> row.path("id_color").asInt() == color)) throw new IllegalArgumentException("Choose category, size and color IDs returned by the API.");
        ObjectNode body = api.object("marca", fields[0], "modelo", fields[1], "precio", price, "fk_categoria", category, "imagen", null);
        ArrayNode variants = api.array(); variants.add(api.object("fk_talla", size, "fk_color", color, "stock", stock, "imagen", null)); body.set("variants", variants);
        post("/products", body); success("Product added.");
    } catch (Exception error) { reportApiError(error); }
}

private void actualizarStock() {
    try {
        List<JsonNode> inventory = rows(get("/admin/inventory?pageSize=500"));
        String[] labels = inventory.stream().map(item -> item.path("id_variante").asText() + " | " + item.path("marca").asText() + " " + item.path("modelo").asText() + " | " + item.path("color").asText() + " / " + item.path("talla").asText() + " | stock " + item.path("stock").asText()).toArray(String[]::new);
        if (labels.length == 0) { success("Inventory is empty."); return; }
        JComboBox<String> variant = new JComboBox<>(labels); JTextField stock = new JTextField(); JPanel panel = new JPanel(new GridLayout(0, 1)); panel.add(variant); panel.add(new JLabel("New stock")); panel.add(stock);
        if (JOptionPane.showConfirmDialog(frmEmployee, panel, "Update stock", JOptionPane.OK_CANCEL_OPTION) != JOptionPane.OK_OPTION) return;
        int selected = variant.getSelectedIndex(), quantity = Integer.parseInt(stock.getText().trim());
        api.put("/variants/" + inventory.get(selected).path("id_variante").asInt() + "/stock", api.object("stock", quantity)); success("Stock updated.");
    } catch (Exception error) { reportApiError(error); }
}

private void addCliente() {
    String[] f = ask("Add customer", "First name", "Surname", "Second surname (optional)", "Email", "Password"); if (f == null) return;
    try { post("/admin/customers", api.object("nombre", f[0], "apellido1", f[1], "apellido2", f[2].isBlank() ? null : f[2], "email", f[3], "password", f[4])); success("Customer created."); } catch (Exception error) { reportApiError(error); }
}

private void addCategoria() { String[] f = ask("Add category", "Category name"); if (f == null) return; try { post("/categories", api.object("categoria", f[0])); success("Category added."); } catch (Exception error) { reportApiError(error); } }

private void addEmpleado() {
    String[] f = ask("Add employee", "First name", "Surname", "Second surname (optional)", "Email", "Password", "Role (writter/editor/admin)", "Store ID"); if (f == null) return;
    try { post("/admin/employees", api.object("nombre", f[0], "apellido1", f[1], "apellido2", f[2].isBlank() ? null : f[2], "email", f[3], "password", f[4], "mode_use", f[5], "fk_tienda", Integer.parseInt(f[6]), "fullscreen", false, "mute", false, "volume", 50)); success("Employee created."); } catch (Exception error) { reportApiError(error); }
}

private void addTalla() { String[] f = ask("Add size", "Size"); if (f == null) return; try { post("/sizes", api.object("talla", f[0])); success("Size added."); } catch (Exception error) { reportApiError(error); } }
private void addColor() { String[] f = ask("Add color", "Color name", "Existing swatch path, e.g. /colors/black.png"); if (f == null) return; try { post("/colors", api.object("color", f[0], "imagen", f[1])); success("Color added."); } catch (Exception error) { reportApiError(error); } }
private void addTienda() { String[] f = ask("Add store", "Country", "City", "Street", "Postal code"); if (f == null) return; try { post("/admin/stores", api.object("pais", f[0], "ciudad", f[1], "calle", f[2], "postal", f[3])); success("Store added."); } catch (Exception error) { reportApiError(error); } }

private void editEmpleado() {
    try {
        String[] found = ask("Find employee", "Employee email"); if (found == null) return;
        List<JsonNode> employees = rows(get("/admin/employees")); JsonNode employee = employees.stream().filter(e -> found[0].equalsIgnoreCase(e.path("mail").asText())).findFirst().orElseThrow(() -> new IllegalArgumentException("Employee not found."));
        String[] f = ask("Edit employee", "First name", "Surname", "Second surname", "Email", "Role (writter/editor/admin)", "Store ID"); if (f == null) return;
        patch("/admin/employees/" + employee.path("id_empleado").asInt(), api.object("nombre", f[0], "apellido1", f[1], "apellido2", f[2], "email", f[3], "mode_use", f[4], "fk_tienda", Integer.parseInt(f[5]))); success("Employee updated.");
    } catch (Exception error) { reportApiError(error); }
}

private void editTuInfo() {
    try {
        JsonNode me = get("/auth/me"); String[] f = ask("Edit my profile", "First name (" + value(me,"nombre") + ")", "Surname (" + value(me,"apellido1") + ")", "Second surname", "Email (" + value(me,"mail") + ")"); if (f == null) return;
        patch("/auth/me", api.object("nombre", f[0], "apellido1", f[1], "apellido2", f[2], "email", f[3])); success("Profile updated.");
    } catch (Exception error) { reportApiError(error); }
}

private void editCliente() {
    try {
        String[] f = ask("Find customer", "Customer email"); if (f == null) return;
        List<JsonNode> customers = rows(get("/admin/customers?q=" + java.net.URLEncoder.encode(f[0], java.nio.charset.StandardCharsets.UTF_8)));
        JsonNode customer = customers.stream().filter(c -> f[0].equalsIgnoreCase(c.path("mail").asText())).findFirst().orElseThrow(() -> new IllegalArgumentException("Customer not found."));
        String[] edit = ask("Edit customer", "First name", "Surname", "Second surname", "Email"); if (edit == null) return;
        patch("/admin/customers/" + customer.path("id_user").asInt(), api.object("nombre", edit[0], "apellido1", edit[1], "apellido2", edit[2], "email", edit[3])); success("Customer updated.");
    } catch (Exception error) { reportApiError(error); }
}

private void verTusDatos() {
    try {
        JsonNode me = get("/auth/me"); JOptionPane.showMessageDialog(frmEmployee, "ID: " + value(me,"id") + "\nName: " + value(me,"nombre") + " " + value(me,"apellido1") + " " + value(me,"apellido2") + "\nEmail: " + value(me,"mail") + "\nRole: " + value(me,"role") + "\nStore ID: " + value(me,"fk_tienda"), "My profile", JOptionPane.INFORMATION_MESSAGE);
    } catch (Exception error) { reportApiError(error); }
}

private void verEstadoPedidos() {
    try {
        List<JsonNode> orders = rows(get("/orders?pageSize=100"));
        if (orders.isEmpty()) { success("There are no orders."); return; }
        String[] labels = orders.stream().map(o -> "(" + o.path("id_pedido").asText() + ") " + o.path("calle").asText() + " | " + o.path("mail").asText() + " | " + (o.path("entregado").asBoolean() ? "delivered" : "pending")).toArray(String[]::new);
        int selected = JOptionPane.showOptionDialog(frmEmployee, "Choose an order", "Orders", JOptionPane.DEFAULT_OPTION, JOptionPane.QUESTION_MESSAGE, null, labels, labels[0]); if (selected < 0) return;
        JsonNode order = orders.get(selected); StringBuilder details = new StringBuilder("Order #").append(order.path("id_pedido").asText()).append("\nDelivery: ").append(order.path("fecha_entrega").asText()).append("\nAddress: ").append(order.path("calle").asText()).append(", ").append(order.path("ciudad").asText()).append(", ").append(order.path("pais").asText()).append(" ").append(order.path("postal").asText()).append("\nCustomer: ").append(order.path("mail").asText()).append("\n");
        order.path("items").forEach(item -> details.append("\n- ").append(item.path("marca").asText()).append(" ").append(item.path("modelo").asText()).append(" | ").append(item.path("color").asText()).append(" / ").append(item.path("talla").asText()).append(" x ").append(item.path("cantidad").asText()));
        JOptionPane.showMessageDialog(frmEmployee, details.toString(), "Order details", JOptionPane.INFORMATION_MESSAGE);
        if (!order.path("entregado").asBoolean() && JOptionPane.showConfirmDialog(frmEmployee, "Mark as delivered?", "Order status", JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION) { api.patch("/orders/" + order.path("id_pedido").asInt() + "/status", api.object("entregado", true)); success("Order status updated."); }
    } catch (Exception error) { reportApiError(error); }
}

}
