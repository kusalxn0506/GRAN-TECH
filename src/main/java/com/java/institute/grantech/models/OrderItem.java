package com.java.institute.grantech.models;

public class OrderItem {
    private int id;
    private int orderId;
    private int productId;
    private String productName;
    private String productImage;
    private String variantSummary;
    private double unitPrice;
    private int quantity;
    private double subtotal;

    public OrderItem() {}

    public OrderItem(int id, int orderId, int productId, String productName, String productImage, String variantSummary, double unitPrice, int quantity, double subtotal) {
        this.id = id;
        this.orderId = orderId;
        this.productId = productId;
        this.productName = productName;
        this.productImage = productImage;
        this.variantSummary = variantSummary;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.subtotal = subtotal;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }

    public String getVariantSummary() { return variantSummary; }
    public void setVariantSummary(String variantSummary) { this.variantSummary = variantSummary; }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }
}
