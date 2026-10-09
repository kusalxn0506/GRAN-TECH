package com.java.institute.grantech.servlets;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.java.institute.grantech.dao.WishlistDAO;
import com.java.institute.grantech.models.Product;
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
import java.util.*;

@WebServlet("/api/wishlist")
public class WishlistServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        Map<String, Object> responseData = new HashMap<>();

        if (user == null) {
            responseData.put("success", true);
            responseData.put("loggedIn", false);
            responseData.put("wishlist", Collections.emptyList());
            responseData.put("productIds", Collections.emptyList());
        } else {
            List<Product> products = WishlistDAO.getWishlistProducts(user.getId());
            Set<Integer> ids = WishlistDAO.getWishlistProductIds(user.getId());
            responseData.put("success", true);
            responseData.put("loggedIn", true);
            responseData.put("wishlist", products);
            responseData.put("productIds", ids);
            responseData.put("count", products.size());
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

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        Map<String, Object> responseData = new HashMap<>();

        if (user == null) {
            responseData.put("success", false);
            responseData.put("message", "Please sign in to save items to your wishlist.");
        } else {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) sb.append(line);
            }

            int productId = 0;
            if (!sb.toString().isBlank()) {
                try {
                    JsonObject json = gson.fromJson(sb.toString(), JsonObject.class);
                    if (json.has("productId")) productId = json.get("productId").getAsInt();
                } catch (Exception ignored) {}
            }
            if (productId == 0 && req.getParameter("productId") != null) {
                try { productId = Integer.parseInt(req.getParameter("productId")); } catch (Exception ignored) {}
            }

            if (productId > 0) {
                boolean isWishlisted = WishlistDAO.toggleWishlist(user.getId(), productId);
                Set<Integer> ids = WishlistDAO.getWishlistProductIds(user.getId());
                responseData.put("success", true);
                responseData.put("wishlisted", isWishlisted);
                responseData.put("count", ids.size());
                responseData.put("message", isWishlisted ? "Item added to your wishlist." : "Item removed from your wishlist.");
            } else {
                responseData.put("success", false);
                responseData.put("message", "Invalid product ID.");
            }
        }

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(responseData));
            out.flush();
        }
    }
}
