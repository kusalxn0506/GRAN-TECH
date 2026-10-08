package com.java.institute.grantech.models;

public class CartItem {
    private Product product;
    private int quantity;
    private String variantSummary; // e.g. "16GB RAM | 1TB SSD"
    private double unitPrice;
    private double subtotal;

    public CartItem() {}

    public CartItem(Product product, int quantity, String variantSummary, double unitPrice) {
        this.product = product;
        this.quantity = quantity;
        this.variantSummary = (variantSummary != null && !variantSummary.isBlank()) ? variantSummary : "";
        this.unitPrice = unitPrice > 0 ? unitPrice : (product != null ? product.getPrice() : 0.0);
        this.subtotal = this.unitPrice * this.quantity;
    }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { 
        this.product = product;
        recalculateSubtotal();
    }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { 
        this.quantity = quantity;
        recalculateSubtotal();
    }

    public String getVariantSummary() { return variantSummary; }
    public void setVariantSummary(String variantSummary) { this.variantSummary = variantSummary; }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { 
        this.unitPrice = unitPrice;
        recalculateSubtotal();
    }

    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }

    public void recalculateSubtotal() {
        this.subtotal = this.unitPrice * this.quantity;
    }
}
