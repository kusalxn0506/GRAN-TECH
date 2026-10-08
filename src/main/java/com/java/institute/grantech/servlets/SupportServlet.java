package com.java.institute.grantech.servlets;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.java.institute.grantech.dao.SupportDAO;
import com.java.institute.grantech.models.SupportTicket;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/support")
public class SupportServlet extends HttpServlet {

    private final Gson gson = new Gson();

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

        String name = getParam(req, json, "name");
        String email = getParam(req, json, "email");
        String subject = getParam(req, json, "subject");
        String message = getParam(req, json, "message");

        Map<String, Object> responseData = new HashMap<>();

        if (name == null || name.isBlank() || email == null || email.isBlank() || message == null || message.isBlank()) {
            responseData.put("success", false);
            responseData.put("message", "Please complete all required fields.");
        } else {
            SupportTicket ticket = SupportDAO.createTicket(name, email, subject != null ? subject : "General Inquiry", message);
            if (ticket != null) {
                responseData.put("success", true);
                responseData.put("ticketNo", ticket.getTicketNo());
                responseData.put("message", "Support ticket " + ticket.getTicketNo() + " registered. An agent will respond shortly.");
            } else {
                responseData.put("success", false);
                responseData.put("message", "Could not submit inquiry. Please try again.");
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
