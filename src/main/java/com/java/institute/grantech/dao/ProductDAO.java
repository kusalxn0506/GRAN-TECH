package com.java.institute.grantech.dao;

import com.java.institute.grantech.config.DBConnection;
import com.java.institute.grantech.models.Category;
import com.java.institute.grantech.models.Product;
import com.java.institute.grantech.models.ProductVariant;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public static List<Category> getCategoriesWithCount() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.*, COUNT(p.id) AS product_count " +
                     "FROM categories c " +
                     "LEFT JOIN products p ON c.id = p.category_id " +
                     "GROUP BY c.id ORDER BY c.display_order ASC";

        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                Category cat = new Category();
                cat.setId(rs.getInt("id"));
                cat.setName(rs.getString("name"));
                cat.setSlug(rs.getString("slug"));
                cat.setIconClass(rs.getString("icon_class"));
                cat.setDisplayOrder(rs.getInt("display_order"));
                cat.setProductCount(rs.getInt("product_count"));
                list.add(cat);
            }
        } catch (SQLException e) {
            System.err.println("Categories fetch error: " + e.getMessage());
        }
        return list;
    }

    public static List<Product> getTrendingProducts(int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name AS category_name, c.slug AS category_slug " +
                     "FROM products p JOIN categories c ON p.category_id = c.id " +
                     "ORDER BY p.rating DESC, p.id ASC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit > 0 ? limit : 4);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Trending fetch error: " + e.getMessage());
        }
        return list;
    }

    public static List<Product> searchProducts(Integer categoryId, Double minPrice, Double maxPrice, String query, String sortBy, int limit, int offset) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, c.name AS category_name, c.slug AS category_slug " +
            "FROM products p JOIN categories c ON p.category_id = c.id WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append("AND p.category_id = ? ");
            params.add(categoryId);
        }

        if (minPrice != null && minPrice >= 0) {
            sql.append("AND p.price >= ? ");
            params.add(minPrice);
        }

        if (maxPrice != null && maxPrice > 0) {
            sql.append("AND p.price <= ? ");
            params.add(maxPrice);
        }

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ? OR LOWER(p.sku) LIKE ?) ");
            String q = "%" + query.trim().toLowerCase() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
        }

        if ("price_asc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY p.price ASC ");
        } else if ("price_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY p.price DESC ");
        } else if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY p.rating DESC ");
        } else {
            sql.append("ORDER BY p.id ASC ");
        }

        sql.append("LIMIT ? OFFSET ?");
        params.add(limit > 0 ? limit : 12);
        params.add(offset >= 0 ? offset : 0);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Search products error: " + e.getMessage());
        }
        return list;
    }

    public static int getSearchProductsCount(Integer categoryId, Double minPrice, Double maxPrice, String query) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append("AND p.category_id = ? ");
            params.add(categoryId);
        }
        if (minPrice != null && minPrice >= 0) {
            sql.append("AND p.price >= ? ");
            params.add(minPrice);
        }
        if (maxPrice != null && maxPrice > 0) {
            sql.append("AND p.price <= ? ");
            params.add(maxPrice);
        }
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ? OR LOWER(p.sku) LIKE ?) ");
            String q = "%" + query.trim().toLowerCase() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Count search error: " + e.getMessage());
        }
        return 0;
    }

    public static Product getProductById(int id) {
        String sql = "SELECT p.*, c.name AS category_name, c.slug AS category_slug " +
                     "FROM products p JOIN categories c ON p.category_id = c.id WHERE p.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = mapProduct(rs);
                    p.setGalleryImages(getGalleryImages(conn, id));
                    p.setVariants(getProductVariants(conn, id));
                    return p;
                }
            }
        } catch (SQLException e) {
            System.err.println("Get product by ID error: " + e.getMessage());
        }
        return null;
    }

    public static Product getProductBySlug(String slug) {
        String sql = "SELECT p.*, c.name AS category_name, c.slug AS category_slug " +
                     "FROM products p JOIN categories c ON p.category_id = c.id WHERE p.slug = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, slug);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = mapProduct(rs);
                    p.setGalleryImages(getGalleryImages(conn, p.getId()));
                    p.setVariants(getProductVariants(conn, p.getId()));
                    return p;
                }
            }
        } catch (SQLException e) {
            System.err.println("Get product by slug error: " + e.getMessage());
        }
        return null;
    }

    public static int getTotalProductsCount() {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Count products error: " + e.getMessage());
        }
        return 0;
    }

    private static List<String> getGalleryImages(Connection conn, int productId) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT image_url FROM product_images WHERE product_id = ? ORDER BY display_order ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("image_url"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Gallery error: " + e.getMessage());
        }
        return list;
    }

    private static List<ProductVariant> getProductVariants(Connection conn, int productId) {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT * FROM product_variants WHERE product_id = ? ORDER BY id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setId(rs.getInt("id"));
                    v.setProductId(rs.getInt("product_id"));
                    v.setVariantType(rs.getString("variant_type"));
                    v.setVariantValue(rs.getString("variant_value"));
                    v.setPriceDelta(rs.getDouble("price_delta"));
                    v.setDefault(rs.getBoolean("is_default"));
                    list.add(v);
                }
            }
        } catch (SQLException e) {
            System.err.println("Variants error: " + e.getMessage());
        }
        return list;
    }

    private static Product mapProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setCategoryName(rs.getString("category_name"));
        p.setCategorySlug(rs.getString("category_slug"));
        p.setName(rs.getString("name"));
        p.setSlug(rs.getString("slug"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getDouble("price"));
        p.setOriginalPrice(rs.getDouble("original_price"));
        p.setSku(rs.getString("sku"));
        p.setStockQuantity(rs.getInt("stock_quantity"));
        p.setRating(rs.getDouble("rating"));
        p.setReviewsCount(rs.getInt("reviews_count"));
        p.setMainImage(rs.getString("main_image"));
        p.setBadge(rs.getString("badge"));
        p.setTechSpecs(rs.getString("tech_specs"));
        p.setShippingInfo(rs.getString("shipping_info"));
        p.setWarrantyInfo(rs.getString("warranty_info"));
        return p;
    }
}
