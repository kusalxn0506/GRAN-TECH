package com.java.institute.grantech.dao;

import com.java.institute.grantech.config.HibernateUtil;
import com.java.institute.grantech.models.Product;
import com.java.institute.grantech.models.WishlistItem;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class WishlistDAO {

    /**
     * Toggles wishlist state using Hibernate HQL and transactions.
     * Returns true if added, false if removed.
     */
    public static boolean toggleWishlist(int userId, int productId) {
        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();

            // Check if already in wishlist via HQL
            Query<WishlistItem> q = session.createQuery(
                "FROM WishlistItem w WHERE w.userId = :uid AND w.productId = :pid", WishlistItem.class);
            q.setParameter("uid", userId);
            q.setParameter("pid", productId);
            WishlistItem existing = q.uniqueResult();

            if (existing != null) {
                // Remove from wishlist
                session.remove(existing);
                tx.commit();
                return false; // removed
            } else {
                // Add to wishlist
                WishlistItem item = new WishlistItem(userId, productId);
                session.persist(item);
                tx.commit();
                return true; // added
            }
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("WishlistDAO toggle error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Retrieves all wishlisted products for a user using HQL join
     */
    public static List<Product> getWishlistProducts(int userId) {
        List<Product> products = new ArrayList<>();
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // HQL Join between Product and WishlistItem
            String hql = "SELECT p FROM Product p, WishlistItem w WHERE p.id = w.productId AND w.userId = :uid ORDER BY w.id DESC";
            Query<Product> q = session.createQuery(hql, Product.class);
            q.setParameter("uid", userId);
            products = q.list();
        } catch (Exception e) {
            System.err.println("WishlistDAO getProducts error: " + e.getMessage());
        }
        return products;
    }

    /**
     * Retrieves product IDs wishlisted by user (for fast client-side heart icon lookup)
     */
    public static Set<Integer> getWishlistProductIds(int userId) {
        Set<Integer> ids = new HashSet<>();
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Query<Integer> q = session.createQuery(
                "SELECT w.productId FROM WishlistItem w WHERE w.userId = :uid", Integer.class);
            q.setParameter("uid", userId);
            ids.addAll(q.list());
        } catch (Exception e) {
            System.err.println("WishlistDAO getIds error: " + e.getMessage());
        }
        return ids;
    }
}
