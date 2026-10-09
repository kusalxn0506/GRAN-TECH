package com.java.institute.grantech.servlets;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.java.institute.grantech.dao.OrderDAO;
import com.java.institute.grantech.dao.ProductDAO;
import com.java.institute.grantech.dao.SupportDAO;
import com.java.institute.grantech.models.CartItem;
import com.java.institute.grantech.models.Order;
import com.java.institute.grantech.models.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/admin")
public class AdminServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        Map<String, Object> responseData = new HashMap<>();

        if ("kpi".equalsIgnoreCase(action) || action == null || action.isBlank()) {
            Map<String, Object> kpi = OrderDAO.getAdminKPIStats();
            responseData.put("success", true);
            responseData.put("kpi", kpi);

        } else if ("orders".equalsIgnoreCase(action)) {
            int page = 1;
            try { page = Math.max(1, Integer.parseInt(req.getParameter("page"))); } catch (Exception ignored) {}
            int pageSize = 20;
            try { pageSize = Math.max(1, Integer.parseInt(req.getParameter("pageSize"))); } catch (Exception ignored) {}
            int offset = (page - 1) * pageSize;

            List<Order> orders = OrderDAO.getAllOrders(pageSize, offset);
            responseData.put("success", true);
            responseData.put("orders", orders);

        } else if ("tickets".equalsIgnoreCase(action)) {
            responseData.put("success", true);
            responseData.put("tickets", SupportDAO.getAllTickets());

        } else if ("exportReport".equalsIgnoreCase(action)) {
            // Generate and stream downloadable Business Intelligence (BI) CSV Sales Report
            resp.setContentType("text/csv");
            resp.setHeader("Content-Disposition", "attachment; filename=\"GRAN-TECH_Sales_BI_Report.csv\"");
            List<Order> allOrders = OrderDAO.getAllOrders(500, 0);
            try (PrintWriter out = resp.getWriter()) {
                out.println("Order No,Customer Name,Customer Email,City,Postal Code,Payment Method,Payment Status,Order Status,Total Amount,Date");
                for (Order o : allOrders) {
                    out.printf("%s,\"%s\",%s,%s,%s,%s,%s,%s,%.2f,%s\n",
                        o.getOrderNo(),
                        o.getCustomerName().replace("\"", "\"\""),
                        o.getCustomerEmail(),
                        o.getShippingCity(),
                        o.getShippingPostalCode(),
                        o.getPaymentMethod(),
                        o.getPaymentStatus(),
                        o.getOrderStatus(),
                        o.getTotalAmount(),
                        o.getCreatedAt()
                    );
                }
                out.flush();
            }
            return;

        } else {
            responseData.put("success", false);
            responseData.put("message", "Unknown admin action.");
        }

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(responseData));
            out.flush();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        JsonObject json = null;
        if (!sb.toString().isBlank()) {
            try {
                json = gson.fromJson(sb.toString(), JsonObject.class);
            } catch (Exception ignored) {}
        }

        String action = getParam(req, json, "action");
        Map<String, Object> responseData = new HashMap<>();

        if ("updateStatus".equalsIgnoreCase(action)) {
            int orderId = 0;
            try { orderId = Integer.parseInt(getParam(req, json, "orderId")); } catch (Exception ignored) {}
            String newStatus = getParam(req, json, "status");

            if (orderId > 0 && newStatus != null) {
                boolean ok = OrderDAO.updateOrderStatus(orderId, newStatus.toUpperCase());
                responseData.put("success", ok);
                responseData.put("message", ok ? "Order status updated." : "Failed to update status.");
            } else {
                responseData.put("success", false);
                responseData.put("message", "Missing order ID or status.");
            }

        } else if ("createOrder".equalsIgnoreCase(action)) {
            // Manual offline order entry from admin panel (admin-create-order.html)
            String customerName = getParam(req, json, "customerName");
            String customerEmail = getParam(req, json, "customerEmail");
            String shippingAddress = getParam(req, json, "shippingAddress");
            String city = getParam(req, json, "city");
            String postalCode = getParam(req, json, "postalCode");
            String paymentMethod = getParam(req, json, "paymentMethod");

            List<CartItem> items = new ArrayList<>();

            if (json != null && json.has("items") && json.get("items").isJsonArray()) {
                JsonArray itemsArr = json.getAsJsonArray("items");
                for (JsonElement el : itemsArr) {
                    if (el.isJsonObject()) {
                        JsonObject itObj = el.getAsJsonObject();
                        int pId = itObj.get("productId").getAsInt();
                        int qty = itObj.has("quantity") ? itObj.get("quantity").getAsInt() : 1;
                        String variant = itObj.has("variant") ? itObj.get("variant").getAsString() : "";
                        double price = itObj.has("price") ? itObj.get("price").getAsDouble() : 0.0;

                        Product p = ProductDAO.getProductById(pId);
                        if (p != null) {
                            items.add(new CartItem(p, qty, variant, price > 0 ? price : p.getPrice()));
                        }
                    }
                }
            }

            if (items.isEmpty()) {
                // If items array wasn't provided, add default product for manual entry test
                Product p = ProductDAO.getProductById(1); // Aether Pro
                if (p != null) {
                    items.add(new CartItem(p, 1, "16GB RAM | 1TB SSD", p.getPrice()));
                }
            }

            Order order = OrderDAO.createOrder(null, customerName, customerEmail, shippingAddress, city, postalCode, items, paymentMethod);
            if (order != null) {
                com.java.institute.grantech.services.EmailService.sendOrderConfirmationAsync(order, order.getItems());
                responseData.put("success", true);
                responseData.put("order", order);
                responseData.put("message", "Manual order #" + order.getOrderNo() + " created successfully.");
            } else {
                responseData.put("success", false);
                responseData.put("message", "Failed to create manual order.");
            }

        } else {
            responseData.put("success", false);
            responseData.put("message", "Invalid action.");
        }

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(responseData));
            out.flush();
        }
    }

    private String getParam(HttpServletRequest req, JsonObject json, String key) {
        if (json != null && json.has(key) && !json.get(key).isJsonNull()) {
            return json.get(key).getAsString();
        }
        return req.getParameter(key);
    }
}
