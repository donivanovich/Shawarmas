package com.shawarmas;


import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import com.fasterxml.jackson.databind.JsonNode;


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
		Image logoImage = BrandAssets.load("logo.png");
		logo = new ImageIcon(logoImage == null ? new ImageIcon().getImage() : logoImage.getScaledInstance(176, 176, Image.SCALE_SMOOTH));
		frmShawarSignIn = new JFrame();
		frmShawarSignIn.setIconImage(BrandAssets.load("favicon.ico"));
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
				logIn(); 
			}		
		});
		btnLogIn.setBackground(new Color(0, 0, 0));
		btnLogIn.setFont(new Font("Yu Gothic Medium", Font.BOLD, 11));
		btnLogIn.setBounds(297, 177, 74, 31);
		frmShawarSignIn.getContentPane().add(btnLogIn);
		
		JButton btnSignIn = new JButton("Sign In");
		btnSignIn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				signIn(); 
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
    while (true) {
        JPanel panel = new JPanel(new GridLayout(0, 1));
        panel.add(new JLabel("Nombre:")); panel.add(nombreField);
        panel.add(new JLabel("Apellido 1:")); panel.add(ap1Field);
        panel.add(new JLabel("Apellido 2:")); panel.add(ap2Field);
        panel.add(new JLabel("Email:")); panel.add(mailField);
        panel.add(new JLabel("Contraseña:")); panel.add(passwField);
        int result = JOptionPane.showConfirmDialog(null, panel, "Registro", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
        if (result != JOptionPane.OK_OPTION) return;
        String nombre = nombreField.getText().trim();
        String ap1 = ap1Field.getText().trim();
        String ap2 = ap2Field.getText().trim();
        String mail = mailField.getText().trim();
        String passw = new String(passwField.getPassword());
        if (nombre.isEmpty() || ap1.isEmpty() || mail.isEmpty() || passw.length() < 8 || !mail.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            JOptionPane.showMessageDialog(null, "Comprueba los campos y usa una contraseña de al menos 8 caracteres.", "Datos no válidos", JOptionPane.ERROR_MESSAGE);
            continue;
        }
        try {
            ApiClient.getInstance().registerCustomer(nombre, ap1, ap2, mail, passw);
            ApiClient.getInstance().logout();
            JOptionPane.showMessageDialog(null, "Te has registrado correctamente.");
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(null, ex.getMessage(), "No se pudo completar el registro", JOptionPane.ERROR_MESSAGE);
        }
        return;
    }
}
private void logIn() {
    String mail = txtMail.getText().trim();
    String passw = new String(password.getPassword());
    if (mail.isEmpty() || passw.isEmpty()) {
        JOptionPane.showMessageDialog(null, "Introduce el correo y la contraseña.", "Datos incompletos", JOptionPane.ERROR_MESSAGE);
        return;
    }
    try {
        com.fasterxml.jackson.databind.JsonNode user = ApiClient.getInstance().login(mail, passw);
        if (user.path("type").asText().equals("customer")) {
            frmShawarSignIn.dispose();
            Customer window = new Customer();
            window.customerMail = mail;
            window.main(null);
        } else if (user.path("type").asText().equals("employee")) {
            frmShawarSignIn.dispose();
            Employee window = new Employee();
            window.mail = mail;
            window.main(null);
        } else {
            JOptionPane.showMessageDialog(null, "La cuenta no tiene acceso a esta aplicación.", "Acceso denegado", JOptionPane.ERROR_MESSAGE);
        }
    } catch (Exception ex) {
        JOptionPane.showMessageDialog(null, ex.getMessage(), "No se pudo conectar con el servicio", JOptionPane.ERROR_MESSAGE);
    }
}
}
