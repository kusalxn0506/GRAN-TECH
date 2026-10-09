package com.java.institute.grantech.models;

import jakarta.persistence.*;

@Entity
@Table(name = "product_variants")
public class ProductVariant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "product_id", nullable = false)
    private int productId;

    @Column(name = "variant_type", nullable = false)
    private String variantType; // 'RAM', 'STORAGE'

    @Column(name = "variant_value", nullable = false)
    private String variantValue; // '16GB RAM', '32GB RAM'

    @Column(name = "price_delta")
    private double priceDelta;

    @Column(name = "is_default")
    private boolean isDefault;

    public ProductVariant() {}

    public ProductVariant(int id, int productId, String variantType, String variantValue, double priceDelta, boolean isDefault) {
        this.id = id;
        this.productId = productId;
        this.variantType = variantType;
        this.variantValue = variantValue;
        this.priceDelta = priceDelta;
        this.isDefault = isDefault;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getVariantType() { return variantType; }
    public void setVariantType(String variantType) { this.variantType = variantType; }

    public String getVariantValue() { return variantValue; }
    public void setVariantValue(String variantValue) { this.variantValue = variantValue; }

    public double getPriceDelta() { return priceDelta; }
    public void setPriceDelta(double priceDelta) { this.priceDelta = priceDelta; }

    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean aDefault) { isDefault = aDefault; }
}
