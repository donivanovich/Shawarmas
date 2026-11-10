package com.shawarmas;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class DatabaseConnection {

	public static Connection getConnection() throws SQLException {
        String host = System.getenv().getOrDefault("DB_HOST", "127.0.0.1");
        String port = System.getenv().getOrDefault("DB_PORT", "3307");
        String database = System.getenv().getOrDefault("DB_NAME", "shawarmas");
        String user = System.getenv().getOrDefault("DB_USER", "shawarmas_app");
        String password = System.getenv().getOrDefault("DB_PASSWORD", "1234");

        return DriverManager.getConnection("jdbc:mysql://" + host + ":" + port + "/" + database, user, password);
    }

    public static String hashPassword(String password) throws GeneralSecurityException {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        byte[] hash = derive(password, salt);
        return "pbkdf2$" + Base64.getEncoder().encodeToString(salt) + "$"
                + Base64.getEncoder().encodeToString(hash);
    }

    public static boolean verifyPassword(String password, String stored) throws GeneralSecurityException {
        String[] parts = stored.split("\\$", -1);
        if (parts.length != 3 || !"pbkdf2".equals(parts[0])) {
            return false;
        }
        byte[] salt = Base64.getDecoder().decode(parts[1]);
        byte[] expected = Base64.getDecoder().decode(parts[2]);
        return MessageDigest.isEqual(expected, derive(password, salt));
    }

    private static byte[] derive(String password, byte[] salt) throws GeneralSecurityException {
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 120000, 256);
        return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
    }
}
