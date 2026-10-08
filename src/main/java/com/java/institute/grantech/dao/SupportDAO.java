package com.java.institute.grantech.dao;

import com.java.institute.grantech.config.DBConnection;
import com.java.institute.grantech.models.SupportTicket;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SupportDAO {

    public static synchronized String generateNextTicketNo(Connection conn) throws SQLException {
        String sql = "SELECT MAX(CAST(SUBSTRING(ticket_no, 5) AS UNSIGNED)) AS max_no FROM support_tickets WHERE ticket_no LIKE 'TCK-%'";
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            if (rs.next()) {
                int maxNo = rs.getInt("max_no");
                if (maxNo > 0) {
                    return "TCK-" + (maxNo + 1);
                }
            }
        }
        return "TCK-1043";
    }

    public static SupportTicket createTicket(String name, String email, String subject, String message) {
        String sql = "INSERT INTO support_tickets (ticket_no, name, email, subject, message, status) VALUES (?, ?, ?, ?, ?, 'OPEN')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            String ticketNo = generateNextTicketNo(conn);
            ps.setString(1, ticketNo);
            ps.setString(2, name.trim());
            ps.setString(3, email.trim());
            ps.setString(4, subject.trim());
            ps.setString(5, message.trim());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        int id = keys.getInt(1);
                        return getTicketById(id);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Create ticket error: " + e.getMessage());
        }
        return null;
    }

    public static SupportTicket getTicketById(int id) {
        String sql = "SELECT * FROM support_tickets WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapTicket(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Get ticket error: " + e.getMessage());
        }
        return null;
    }

    public static List<SupportTicket> getAllTickets() {
        List<SupportTicket> list = new ArrayList<>();
        String sql = "SELECT * FROM support_tickets ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                list.add(mapTicket(rs));
            }
        } catch (SQLException e) {
            System.err.println("Get all tickets error: " + e.getMessage());
        }
        return list;
    }

    private static SupportTicket mapTicket(ResultSet rs) throws SQLException {
        SupportTicket t = new SupportTicket();
        t.setId(rs.getInt("id"));
        t.setTicketNo(rs.getString("ticket_no"));
        t.setName(rs.getString("name"));
        t.setEmail(rs.getString("email"));
        t.setSubject(rs.getString("subject"));
        t.setMessage(rs.getString("message"));
        t.setStatus(rs.getString("status"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        return t;
    }
}
