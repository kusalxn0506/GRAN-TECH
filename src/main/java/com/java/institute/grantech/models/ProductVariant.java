package com.java.institute.grantech.models;

public class ProductVariant {
    private int id;
    private int productId;
    private String variantType; // 'RAM', 'STORAGE'
    private String variantValue; // '16GB RAM', '32GB RAM'
    private double priceDelta;
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
