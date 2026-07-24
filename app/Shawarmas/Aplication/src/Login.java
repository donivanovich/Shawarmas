package src;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.sql.*;

public class Login {

	private JFrame frmShawarSignIn;
	private JTextField txtMail;
	private JPasswordField password;
	private ImageIcon logo;

	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					Login window = new Login();
					window.frmShawarSignIn.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	public Login() {
		initialize();
	}
	
	private void initialize() {
		logo = new ImageIcon(new ImageIcon(getClass().getResource("/img/logo.png")).getImage().getScaledInstance(176, 176, Image.SCALE_SMOOTH));
		frmShawarSignIn = new JFrame();
		frmShawarSignIn.setIconImage(new ImageIcon(getClass().getResource("/img/faviconLogin.png")).getImage());
		frmShawarSignIn.setTitle("Login");
		frmShawarSignIn.setBackground(new Color(255, 255, 255));
		frmShawarSignIn.getContentPane().setForeground(new Color(0, 0, 0));
		frmShawarSignIn.getContentPane().setBackground(new Color(255, 255, 255));
		frmShawarSignIn.setBounds(100, 100, 403, 272);
		frmShawarSignIn.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frmShawarSignIn.getContentPane().setLayout(null);
		
		JLabel lblMail = new JLabel("Mail");
		lblMail.setForeground(new Color(0, 0, 0));
		lblMail.setFont(new Font("Yu Gothic Medium", Font.BOLD, 14));
		lblMail.setHorizontalAlignment(SwingConstants.LEFT);
		lblMail.setBounds(216, 48, 46, 31);
		frmShawarSignIn.getContentPane().add(lblMail);
		
		txtMail = new JTextField();
		txtMail.setForeground(new Color(0, 0, 0));
		txtMail.setBackground(new Color(255, 255, 255));
		txtMail.setBounds(216, 74, 155, 20);
		txtMail.setCaretColor(Color.BLACK);
		frmShawarSignIn.getContentPane().add(txtMail);
		txtMail.setColumns(10);
		
		JLabel lblPassword = new JLabel("Password");
		lblPassword.setForeground(new Color(0, 0, 0));
		lblPassword.setFont(new Font("Yu Gothic Medium", Font.BOLD, 14));
		lblPassword.setHorizontalAlignment(SwingConstants.LEFT);
		lblPassword.setBounds(216, 105, 86, 31);
		frmShawarSignIn.getContentPane().add(lblPassword);
		
		password = new JPasswordField();
		password.setForeground(new Color(0, 0, 0));
		password.setBackground(new Color(255, 255, 255));
		password.setBounds(216, 131, 155, 20);
		password.setCaretColor(Color.BLACK);
		frmShawarSignIn.getContentPane().add(password);
		
		JButton btnIcon = new JButton("");
		btnIcon.setBackground(new Color(255, 255, 255));
		btnIcon.setBounds(20, 21, 176, 176);
		btnIcon.setIcon(logo);
		btnIcon.setFocusPainted(false);      
		btnIcon.setBorderPainted(false);       
		btnIcon.setContentAreaFilled(false);   
		btnIcon.setOpaque(false);              
		btnIcon.setFocusable(false);           
		frmShawarSignIn.getContentPane().add(btnIcon);
		
		JButton btnLogIn = new JButton("Log In");
		btnLogIn.setForeground(new Color(255, 255, 255));
		btnLogIn.setFocusPainted(false);
		btnLogIn.setBorderPainted(false);
		btnLogIn.setVerticalAlignment(SwingConstants.BOTTOM);
		btnLogIn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				logIn(); //Verifica las credenciales de clientes y empleados y abre ventana Customer o Employee respectivamente
			}		
		});
		btnLogIn.setBackground(new Color(0, 0, 0));
		btnLogIn.setFont(new Font("Yu Gothic Medium", Font.BOLD, 11));
		btnLogIn.setBounds(297, 177, 74, 31);
		frmShawarSignIn.getContentPane().add(btnLogIn);
		
		JButton btnSignIn = new JButton("Sign In");
		btnSignIn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				signIn(); //Despliega una ventana para dar de alta un cliente
			}
		});
		btnSignIn.setVerticalAlignment(SwingConstants.BOTTOM);
		btnSignIn.setForeground(new Color(0, 0, 0));
		btnSignIn.setFont(new Font("Yu Gothic Medium", Font.ITALIC, 11));
		btnSignIn.setFocusPainted(false);
		btnSignIn.setBorderPainted(false);
		btnSignIn.setBackground(new Color(255, 255, 255));
		btnSignIn.setBounds(216, 177, 74, 31);
		frmShawarSignIn.getContentPane().add(btnSignIn);
		
	}
	
private void signIn() {
    JTextField nombreField = new JTextField();
    JTextField ap1Field = new JTextField();
    JTextField ap2Field = new JTextField();
    JTextField mailField = new JTextField();
    JPasswordField passwField = new JPasswordField();

    while(true) {
        JPanel panel = new JPanel(new GridLayout(0, 1));
        panel.add(new JLabel("Nombre:"));
        panel.add(nombreField);
        panel.add(new JLabel("Apellido 1:"));
        panel.add(ap1Field);
        panel.add(new JLabel("Apellido 2:"));
        panel.add(ap2Field);
        panel.add(new JLabel("Email:"));
        panel.add(mailField);
        panel.add(new JLabel("Contraseña:"));
        panel.add(passwField);

        int result = JOptionPane.showConfirmDialog(null, panel, "Registro", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);

        if(result != JOptionPane.OK_OPTION) break;

        String nombre = nombreField.getText();
        String ap1 = ap1Field.getText();
        String ap2 = ap2Field.getText();
        String mail = mailField.getText().trim();
        String passw = new String(passwField.getPassword()).trim();

        if(nombre.isEmpty() || ap1.isEmpty() || mail.isEmpty() || passw.isEmpty()) {
            JOptionPane.showMessageDialog(null, "Por favor, completa todos los campos", "Campos vacíos", JOptionPane.ERROR_MESSAGE);
            continue;
        }

        if(!mail.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            JOptionPane.showMessageDialog(null, "Introduce un correo electrónico válido", "Email inválido", JOptionPane.ERROR_MESSAGE);
            continue;
        }

        if(passw.length() < 8) {
            JOptionPane.showMessageDialog(null, "La contraseña debe tener al menos 8 caracteres", "Error Contraseña", JOptionPane.ERROR_MESSAGE);
            continue;
        }

        try(Connection conn = DBConnection.getConnection()){
            String sql = "INSERT INTO clientes (nombre, apellido1, apellido2, mail, passw) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, nombre);
            stmt.setString(2, ap1);
            stmt.setString(3, ap2);
            stmt.setString(4, mail);
            stmt.setString(5, passw);

            int rowsInserted = stmt.executeUpdate();
            if(rowsInserted > 0) JOptionPane.showMessageDialog(null, "Te has registrado correctamente.");
            
        } catch(SQLException ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(null, "Error al insertar registrarse.", "Error", JOptionPane.ERROR_MESSAGE);
        }

        break;
    }
}

	
private void logIn() {
    String mail = txtMail.getText().trim();
    String passw = new String(password.getPassword()).trim();

    if(mail.isEmpty() || passw.isEmpty()) {
        JOptionPane.showMessageDialog(null, "Por favor, completa todos los campos", "Campos vacíos", JOptionPane.ERROR_MESSAGE);
        return;
    }

    try(Connection conn = DBConnection.getConnection()){
    	String sqlCliente = "SELECT * FROM clientes WHERE mail = ? AND passw = ?";
        PreparedStatement stmtCliente = conn.prepareStatement(sqlCliente);
        stmtCliente.setString(1, mail);
        stmtCliente.setString(2, passw);
        ResultSet rsCliente = stmtCliente.executeQuery();

        if(rsCliente.next()) {
            frmShawarSignIn.dispose();
            Customer window = new Customer();
            window.customerMail = mail;
            window.main(null);
            return;
        }
        
        String sqlEmpleado = "SELECT * FROM empleados WHERE mail = ? AND passw = ?";
        PreparedStatement psEmpleado = conn.prepareStatement(sqlEmpleado);
        psEmpleado.setString(1, mail);
        psEmpleado.setString(2, passw);
        ResultSet rsEmpleado = psEmpleado.executeQuery();

        if(rsEmpleado.next()) {
            frmShawarSignIn.dispose();
            Employee window = new Employee();
            window.mail = mail;
            window.main(null);
        } else {
            JOptionPane.showMessageDialog(null, "Usuario o contraseña incorrectos", "Error", JOptionPane.ERROR_MESSAGE);
        }

    } catch(SQLException ex) {
        ex.printStackTrace();
        JOptionPane.showMessageDialog(null, "Error de conexión", "Error", JOptionPane.ERROR_MESSAGE);
    }
}


}
