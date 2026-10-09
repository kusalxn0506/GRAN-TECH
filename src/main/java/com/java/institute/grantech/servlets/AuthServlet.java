package com.java.institute.grantech.servlets;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.java.institute.grantech.dao.UserDAO;
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
import java.util.Map;

@WebServlet("/api/auth")
public class AuthServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        // Auto-login via persistent "Remember Me" Cookie if session has expired
        if (user == null && req.getCookies() != null) {
            for (jakarta.servlet.http.Cookie c : req.getCookies()) {
                if ("GT_REMEMBER".equals(c.getName())) {
                    String token = c.getValue();
                    User rememberedUser = UserDAO.getUserByRememberToken(token);
                    if (rememberedUser != null) {
                        HttpSession newSession = req.getSession(true);
                        newSession.setAttribute("loggedUser", rememberedUser);
                        user = rememberedUser;
                        break;
                    }
                }
            }
        }

        Map<String, Object> responseData = new HashMap<>();
        if (user != null) {
            responseData.put("loggedIn", true);
            responseData.put("user", user);
        } else {
            responseData.put("loggedIn", false);
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

        if ("login".equalsIgnoreCase(action)) {
            String email = getParam(req, json, "email");
            String password = getParam(req, json, "password");

            if (email == null || email.isBlank() || password == null || password.isBlank()) {
                responseData.put("success", false);
                responseData.put("message", "Please enter both email and password.");
            } else {
                User user = UserDAO.authenticate(email, password);
                if (user != null) {
                    HttpSession session = req.getSession(true);
                    session.setAttribute("loggedUser", user);

                    // Check Remember Me option
                    String rememberParam = getParam(req, json, "rememberMe");
                    boolean rememberMe = "true".equalsIgnoreCase(rememberParam) || "on".equalsIgnoreCase(rememberParam) || "1".equals(rememberParam);
                    if (rememberMe) {
                        String token = java.util.UUID.randomUUID().toString();
                        UserDAO.saveRememberToken(user.getId(), token);
                        jakarta.servlet.http.Cookie c = new jakarta.servlet.http.Cookie("GT_REMEMBER", token);
                        c.setMaxAge(14 * 24 * 60 * 60); // 14 days
                        c.setPath("/");
                        c.setHttpOnly(true);
                        resp.addCookie(c);
                    }

                    responseData.put("success", true);
                    responseData.put("user", user);
                    responseData.put("message", "Welcome back, " + user.getFullName());
                } else {
                    responseData.put("success", false);
                    responseData.put("message", "Invalid email or password.");
                }
            }

        } else if ("register".equalsIgnoreCase(action)) {
            String fullName = getParam(req, json, "fullName");
            String email = getParam(req, json, "email");
            String password = getParam(req, json, "password");
            String phone = getParam(req, json, "phone");
            String address = getParam(req, json, "address");
            String city = getParam(req, json, "city");
            String postalCode = getParam(req, json, "postalCode");

            if (fullName == null || fullName.isBlank() || email == null || email.isBlank() || password == null || password.isBlank()) {
                responseData.put("success", false);
                responseData.put("message", "Full name, email, and password are required.");
            } else if (UserDAO.emailExists(email)) {
                responseData.put("success", false);
                responseData.put("message", "An account with this email already exists.");
            } else {
                User user = UserDAO.register(fullName, email, password, phone, address, city, postalCode);
                if (user != null) {
                    HttpSession session = req.getSession(true);
                    session.setAttribute("loggedUser", user);
                    responseData.put("success", true);
                    responseData.put("user", user);
                    responseData.put("message", "Account created successfully.");
                } else {
                    responseData.put("success", false);
                    responseData.put("message", "Registration failed. Please try again.");
                }
            }

        } else if ("logout".equalsIgnoreCase(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                User u = (User) session.getAttribute("loggedUser");
                if (u != null) {
                    UserDAO.saveRememberToken(u.getId(), null);
                }
                session.removeAttribute("loggedUser");
                session.invalidate();
            }
            // Revoke persistent cookie
            jakarta.servlet.http.Cookie c = new jakarta.servlet.http.Cookie("GT_REMEMBER", "");
            c.setMaxAge(0);
            c.setPath("/");
            resp.addCookie(c);

            responseData.put("success", true);
            responseData.put("message", "Logged out successfully.");

        } else if ("updateProfile".equalsIgnoreCase(action)) {
            HttpSession session = req.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;

            if (user == null) {
                responseData.put("success", false);
                responseData.put("message", "Not logged in.");
            } else {
                String fullName = getParam(req, json, "fullName");
                String phone = getParam(req, json, "phone");
                String address = getParam(req, json, "address");
                String city = getParam(req, json, "city");
                String postalCode = getParam(req, json, "postalCode");

                boolean updated = UserDAO.updateProfile(user.getId(), fullName, phone, address, city, postalCode);
                if (updated) {
                    User refreshed = UserDAO.getUserById(user.getId());
                    session.setAttribute("loggedUser", refreshed);
                    responseData.put("success", true);
                    responseData.put("user", refreshed);
                    responseData.put("message", "Profile updated successfully.");
                } else {
                    responseData.put("success", false);
                    responseData.put("message", "Failed to update profile.");
                }
            }

        } else {
            responseData.put("success", false);
            responseData.put("message", "Invalid action specified.");
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
