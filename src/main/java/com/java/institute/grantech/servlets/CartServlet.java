package com.java.institute.grantech.servlets;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.java.institute.grantech.dao.ProductDAO;
import com.java.institute.grantech.models.CartItem;
import com.java.institute.grantech.models.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/cart")
public class CartServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @SuppressWarnings("unchecked")
    private List<CartItem> getOrCreateCart(HttpSession session) {
        List<CartItem> cart = (List<CartItem>) session.getAttribute("shoppingCart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("shoppingCart", cart);
        }
        return cart;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(true);
        List<CartItem> cart = getOrCreateCart(session);

        int totalCount = 0;
        double subtotal = 0.0;
        for (CartItem item : cart) {
            totalCount += item.getQuantity();
            subtotal += item.getSubtotal();
        }

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("items", cart);
        responseData.put("totalCount", totalCount);
        responseData.put("subtotal", subtotal);

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
        int productId = 0;
        try {
            productId = Integer.parseInt(getParam(req, json, "productId"));
        } catch (Exception ignored) {}

        int quantity = 1;
        try {
            quantity = Integer.parseInt(getParam(req, json, "quantity"));
        } catch (Exception ignored) {}

        String variantSummary = getParam(req, json, "variantSummary");
        if (variantSummary == null) variantSummary = "";

        double unitPrice = 0.0;
        try {
            unitPrice = Double.parseDouble(getParam(req, json, "unitPrice"));
        } catch (Exception ignored) {}

        HttpSession session = req.getSession(true);
        List<CartItem> cart = getOrCreateCart(session);

        if ("add".equalsIgnoreCase(action)) {
            boolean found = false;
            for (CartItem item : cart) {
                if (item.getProduct().getId() == productId && item.getVariantSummary().equals(variantSummary)) {
                    item.setQuantity(item.getQuantity() + Math.max(1, quantity));
                    found = true;
                    break;
                }
            }
            if (!found) {
                Product p = ProductDAO.getProductById(productId);
                if (p != null) {
                    double finalPrice = (unitPrice > 0) ? unitPrice : p.getPrice();
                    cart.add(new CartItem(p, Math.max(1, quantity), variantSummary, finalPrice));
                }
            }

        } else if ("update".equalsIgnoreCase(action)) {
            for (CartItem item : cart) {
                if (item.getProduct().getId() == productId && item.getVariantSummary().equals(variantSummary)) {
                    if (quantity <= 0) {
                        cart.remove(item);
                    } else {
                        item.setQuantity(quantity);
                    }
                    break;
                }
            }

        } else if ("remove".equalsIgnoreCase(action)) {
            final int targetProductId = productId;
            final String finalVariant = variantSummary;
            cart.removeIf(item -> item.getProduct().getId() == targetProductId && (finalVariant.isEmpty() || item.getVariantSummary().equals(finalVariant)));

        } else if ("clear".equalsIgnoreCase(action)) {
            cart.clear();
        }

        int totalCount = 0;
        double subtotal = 0.0;
        for (CartItem item : cart) {
            totalCount += item.getQuantity();
            subtotal += item.getSubtotal();
        }

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("items", cart);
        responseData.put("totalCount", totalCount);
        responseData.put("subtotal", subtotal);

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
