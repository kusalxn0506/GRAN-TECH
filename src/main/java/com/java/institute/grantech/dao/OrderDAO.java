package com.java.institute.grantech.dao;

import com.java.institute.grantech.config.DBConnection;
import com.java.institute.grantech.models.CartItem;
import com.java.institute.grantech.models.Order;
import com.java.institute.grantech.models.OrderItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderDAO {

    public static synchronized String generateNextOrderNo(Connection conn) throws SQLException {
        String sql = "SELECT MAX(CAST(SUBSTRING(order_no, 4) AS UNSIGNED)) AS max_no FROM orders WHERE order_no LIKE 'GT-%'";
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            if (rs.next()) {
                int maxNo = rs.getInt("max_no");
                if (maxNo > 0) {
                    return "GT-" + (maxNo + 1);
                }
            }
        }
        return "GT-8493";
    }

    public static Order createOrder(Integer userId, String customerName, String customerEmail,
                                    String address, String city, String postalCode,
                                    List<CartItem> cartItems, String paymentMethod) {

        if (cartItems == null || cartItems.isEmpty()) {
            return null;
        }

        double subtotal = 0.0;
        for (CartItem item : cartItems) {
            subtotal += item.getSubtotal();
        }
        double shippingFee = 0.0; // Free premium shipping as per SRS
        double tax = 0.0;
        double totalAmount = subtotal + shippingFee + tax;

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // ACID Transaction start

            String orderNo = generateNextOrderNo(conn);

            String orderSql = "INSERT INTO orders (order_no, user_id, customer_name, customer_email, " +
                              "shipping_address, shipping_city, shipping_postal_code, subtotal, shipping_fee, tax, " +
                              "total_amount, payment_method, payment_status, order_status) " +
                              "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PAID', 'PROCESSING')";

            int orderId = 0;
            try (PreparedStatement ps = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, orderNo);
                if (userId != null && userId > 0) {
                    ps.setInt(2, userId);
                } else {
                    ps.setNull(2, Types.INTEGER);
                }
                ps.setString(3, customerName.trim());
                ps.setString(4, customerEmail.trim());
                ps.setString(5, address.trim());
                ps.setString(6, (city != null && !city.isBlank()) ? city.trim() : "Colombo");
                ps.setString(7, (postalCode != null && !postalCode.isBlank()) ? postalCode.trim() : "00300");
                ps.setDouble(8, subtotal);
                ps.setDouble(9, shippingFee);
                ps.setDouble(10, tax);
                ps.setDouble(11, totalAmount);
                ps.setString(12, (paymentMethod != null) ? paymentMethod : "CREDIT_CARD");

                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        orderId = keys.getInt(1);
                    }
                }
            }

            if (orderId == 0) {
                conn.rollback();
                return null;
            }

            String itemSql = "INSERT INTO order_items (order_id, product_id, product_name, product_image, " +
                             "variant_summary, unit_price, quantity, subtotal) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            String stockSql = "UPDATE products SET stock_quantity = GREATEST(0, stock_quantity - ?) WHERE id = ?";

            try (PreparedStatement psItem = conn.prepareStatement(itemSql);
                 PreparedStatement psStock = conn.prepareStatement(stockSql)) {

                for (CartItem item : cartItems) {
                    psItem.setInt(1, orderId);
                    psItem.setInt(2, item.getProduct().getId());
                    psItem.setString(3, item.getProduct().getName());
                    psItem.setString(4, item.getProduct().getMainImage());
                    psItem.setString(5, item.getVariantSummary());
                    psItem.setDouble(6, item.getUnitPrice());
                    psItem.setInt(7, item.getQuantity());
                    psItem.setDouble(8, item.getSubtotal());
                    psItem.addBatch();

                    // Deduct stock
                    psStock.setInt(1, item.getQuantity());
                    psStock.setInt(2, item.getProduct().getId());
                    psStock.addBatch();
                }

                psItem.executeBatch();
                psStock.executeBatch();
            }

            conn.commit(); // ACID Commit
            conn.setAutoCommit(true);

            return getOrderById(orderId);

        } catch (SQLException e) {
            System.err.println("Order transaction failed: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Rollback failed: " + ex.getMessage());
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
        return null;
    }

    public static Order getOrderById(int orderId) {
        String sql = "SELECT * FROM orders WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = mapOrder(rs);
                    order.setItems(getOrderItems(conn, orderId));
                    return order;
                }
            }
        } catch (SQLException e) {
            System.err.println("Get order error: " + e.getMessage());
        }
        return null;
    }

    public static Order getOrderByNumber(String orderNo) {
        String sql = "SELECT * FROM orders WHERE order_no = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, orderNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = mapOrder(rs);
                    order.setItems(getOrderItems(conn, order.getId()));
                    return order;
                }
            }
        } catch (SQLException e) {
            System.err.println("Get order by number error: " + e.getMessage());
        }
        return null;
    }

    public static List<Order> getOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapOrder(rs);
                    order.setItems(getOrderItems(conn, order.getId()));
                    list.add(order);
                }
            }
        } catch (SQLException e) {
            System.err.println("User orders error: " + e.getMessage());
        }
        return list;
    }

    public static List<Order> getAllOrders(int limit, int offset) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders ORDER BY created_at DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit > 0 ? limit : 20);
            ps.setInt(2, offset >= 0 ? offset : 0);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapOrder(rs);
                    order.setItems(getOrderItems(conn, order.getId()));
                    list.add(order);
                }
            }
        } catch (SQLException e) {
            System.err.println("All orders error: " + e.getMessage());
        }
        return list;
    }

    public static boolean updateOrderStatus(int orderId, String newStatus) {
        String sql = "UPDATE orders SET order_status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            int rows = ps.executeUpdate();
            return rows >= 0;
        } catch (SQLException e) {
            System.err.println("Update order status error: " + e.getMessage());
        }
        return false;
    }

    public static Map<String, Object> getAdminKPIStats() {
        Map<String, Object> kpi = new HashMap<>();

        try (Connection conn = DBConnection.getConnection()) {
            // Total Revenue
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE payment_status = 'PAID'")) {
                if (rs.next()) {
                    kpi.put("totalRevenue", rs.getDouble(1));
                }
            }

            // Active Orders
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM orders WHERE order_status = 'PROCESSING'")) {
                if (rs.next()) {
                    kpi.put("activeOrders", rs.getInt(1));
                }
            }

            // Total Products
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM products")) {
                if (rs.next()) {
                    kpi.put("totalProducts", rs.getInt(1));
                }
            }

            // Total Customers
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'CUSTOMER'")) {
                if (rs.next()) {
                    kpi.put("totalCustomers", rs.getInt(1));
                }
            }

            // Recent Transactions (top 5)
            List<Order> recent = getAllOrders(5, 0);
            kpi.put("recentOrders", recent);

        } catch (SQLException e) {
            System.err.println("KPI stats error: " + e.getMessage());
        }
        return kpi;
    }

    private static List<OrderItem> getOrderItems(Connection conn, int orderId) {
        List<OrderItem> list = new ArrayList<>();
        String sql = "SELECT * FROM order_items WHERE order_id = ? ORDER BY id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem it = new OrderItem();
                    it.setId(rs.getInt("id"));
                    it.setOrderId(rs.getInt("order_id"));
                    it.setProductId(rs.getInt("product_id"));
                    it.setProductName(rs.getString("product_name"));
                    it.setProductImage(rs.getString("product_image"));
                    it.setVariantSummary(rs.getString("variant_summary"));
                    it.setUnitPrice(rs.getDouble("unit_price"));
                    it.setQuantity(rs.getInt("quantity"));
                    it.setSubtotal(rs.getDouble("subtotal"));
                    list.add(it);
                }
            }
        } catch (SQLException e) {
            System.err.println("Order items error: " + e.getMessage());
        }
        return list;
    }

    private static Order mapOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id"));
        o.setOrderNo(rs.getString("order_no"));
        o.setUserId(rs.getObject("user_id") != null ? rs.getInt("user_id") : null);
        o.setCustomerName(rs.getString("customer_name"));
        o.setCustomerEmail(rs.getString("customer_email"));
        o.setShippingAddress(rs.getString("shipping_address"));
        o.setShippingCity(rs.getString("shipping_city"));
        o.setShippingPostalCode(rs.getString("shipping_postal_code"));
        o.setSubtotal(rs.getDouble("subtotal"));
        o.setShippingFee(rs.getDouble("shipping_fee"));
        o.setTax(rs.getDouble("tax"));
        o.setTotalAmount(rs.getDouble("total_amount"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setPaymentStatus(rs.getString("payment_status"));
        o.setOrderStatus(rs.getString("order_status"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        return o;
    }
}
