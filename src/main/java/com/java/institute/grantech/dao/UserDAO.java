package com.java.institute.grantech.dao;

import com.java.institute.grantech.config.DBConnection;
import com.java.institute.grantech.models.User;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;

public class UserDAO {

    public static String hashPassword(String plainPassword) {
        if (plainPassword == null) return "";
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plainPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }

    public static User authenticate(String email, String plainPassword) {
        String sql = "SELECT * FROM users WHERE email = ? AND password_hash = ?";
        String hash = hashPassword(plainPassword);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim().toLowerCase());
            ps.setString(2, hash);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("User auth error: " + e.getMessage());
        }
        return null;
    }

    public static boolean emailExists(String email) {
        String sql = "SELECT id FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Email check error: " + e.getMessage());
        }
        return false;
    }

    public static User register(String fullName, String email, String plainPassword, String phone, String address, String city, String postalCode) {
        if (emailExists(email)) {
            return null;
        }

        String sql = "INSERT INTO users (full_name, email, password_hash, phone, address, city, postal_code, role) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'CUSTOMER')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, fullName.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, hashPassword(plainPassword));
            ps.setString(4, phone != null ? phone.trim() : "");
            ps.setString(5, address != null ? address.trim() : "");
            ps.setString(6, (city != null && !city.isBlank()) ? city.trim() : "Colombo");
            ps.setString(7, (postalCode != null && !postalCode.isBlank()) ? postalCode.trim() : "00300");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        int id = keys.getInt(1);
                        return getUserById(id);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("User register error: " + e.getMessage());
        }
        return null;
    }

    public static User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Get user error: " + e.getMessage());
        }
        return null;
    }

    public static boolean updateProfile(int userId, String fullName, String phone, String address, String city, String postalCode) {
        String sql = "UPDATE users SET full_name = ?, phone = ?, address = ?, city = ?, postal_code = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName.trim());
            ps.setString(2, phone != null ? phone.trim() : "");
            ps.setString(3, address != null ? address.trim() : "");
            ps.setString(4, city != null ? city.trim() : "Colombo");
            ps.setString(5, postalCode != null ? postalCode.trim() : "00300");
            ps.setInt(6, userId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Update profile error: " + e.getMessage());
        }
        return false;
    }

    public static int getTotalCustomersCount() {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'CUSTOMER'";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Count customers error: " + e.getMessage());
        }
        return 0;
    }

    public static boolean saveRememberToken(int userId, String token) {
        String sql = "UPDATE users SET remember_token = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Save remember token error: " + e.getMessage());
            return false;
        }
    }

    public static User getUserByRememberToken(String token) {
        if (token == null || token.isBlank()) return null;
        String sql = "SELECT * FROM users WHERE remember_token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Get user by remember token error: " + e.getMessage());
        }
        return null;
    }

    private static User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setCity(rs.getString("city"));
        u.setPostalCode(rs.getString("postal_code"));
        u.setRole(rs.getString("role"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}
