package com.java.institute.grantech.servlets;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.java.institute.grantech.dao.OrderDAO;
import com.java.institute.grantech.models.CartItem;
import com.java.institute.grantech.models.Order;
import com.java.institute.grantech.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/checkout")
public class CheckoutServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String orderNo = req.getParameter("orderNo");
        String myOrders = req.getParameter("myOrders");

        Map<String, Object> responseData = new HashMap<>();

        if (orderNo != null && !orderNo.isBlank()) {
            Order order = OrderDAO.getOrderByNumber(orderNo.trim());
            if (order != null) {
                responseData.put("success", true);
                responseData.put("order", order);
            } else {
                responseData.put("success", false);
                responseData.put("message", "Order not found.");
            }
        } else if ("true".equalsIgnoreCase(myOrders)) {
            HttpSession session = req.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;

            if (user != null) {
                List<Order> orders = OrderDAO.getOrdersByUserId(user.getId());
                responseData.put("success", true);
                responseData.put("orders", orders);
            } else {
                responseData.put("success", false);
                responseData.put("message", "Please log in to view your orders.");
            }
        } else {
            responseData.put("success", false);
            responseData.put("message", "Invalid request parameters.");
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

        HttpSession session = req.getSession(true);
        @SuppressWarnings("unchecked")
        List<CartItem> cart = (List<CartItem>) session.getAttribute("shoppingCart");

        Map<String, Object> responseData = new HashMap<>();

        if (cart == null || cart.isEmpty()) {
            responseData.put("success", false);
            responseData.put("message", "Your shopping bag is empty. Please add items before checking out.");
        } else {
            User user = (User) session.getAttribute("loggedUser");
            Integer userId = (user != null) ? user.getId() : null;

            String name = getParam(req, json, "name");
            String email = getParam(req, json, "email");
            String address = getParam(req, json, "address");
            String city = getParam(req, json, "city");
            String postalCode = getParam(req, json, "postalCode");
            String paymentMethod = getParam(req, json, "paymentMethod");

            if (name == null || name.isBlank()) {
                name = (user != null) ? user.getFullName() : "Customer";
            }
            if (email == null || email.isBlank()) {
                email = (user != null) ? user.getEmail() : "customer@grantech.com";
            }
            if (address == null || address.isBlank()) {
                address = (user != null && user.getAddress() != null) ? user.getAddress() : "Standard Delivery Address";
            }
            if (city == null || city.isBlank()) city = "Colombo";
            if (postalCode == null || postalCode.isBlank()) postalCode = "00300";

            Order order = OrderDAO.createOrder(userId, name, email, address, city, postalCode, cart, paymentMethod);

            if (order != null) {
                // Clear cart on successful order
                cart.clear();
                session.setAttribute("shoppingCart", cart);

                responseData.put("success", true);
                responseData.put("orderId", order.getId());
                responseData.put("orderNo", order.getOrderNo());
                responseData.put("total", order.getTotalAmount());
                responseData.put("order", order);
                responseData.put("message", "Payment authorized. Order confirmed successfully.");
            } else {
                responseData.put("success", false);
                responseData.put("message", "Failed to process transaction. Please verify stock availability.");
            }
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
