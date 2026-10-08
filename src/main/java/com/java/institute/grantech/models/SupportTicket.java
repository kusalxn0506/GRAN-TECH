package com.java.institute.grantech.models;

import java.sql.Timestamp;

public class SupportTicket {
    private int id;
    private String ticketNo;
    private String name;
    private String email;
    private String subject;
    private String message;
    private String status;
    private Timestamp createdAt;

    public SupportTicket() {}

    public SupportTicket(int id, String ticketNo, String name, String email, String subject, String message, String status, Timestamp createdAt) {
        this.id = id;
        this.ticketNo = ticketNo;
        this.name = name;
        this.email = email;
        this.subject = subject;
        this.message = message;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTicketNo() { return ticketNo; }
    public void setTicketNo(String ticketNo) { this.ticketNo = ticketNo; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
