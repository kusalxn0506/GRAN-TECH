package com.java.institute.grantech.models;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "wishlists")
public class WishlistItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "user_id", nullable = false)
    private int userId;

    @Column(name = "product_id", nullable = false)
    private int productId;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Timestamp createdAt;

    @Transient
    private Product product;

    public WishlistItem() {}

    public WishlistItem(int userId, int productId) {
        this.userId = userId;
        this.productId = productId;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
}
