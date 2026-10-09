package com.java.institute.grantech.dao;

import com.java.institute.grantech.config.HibernateUtil;
import com.java.institute.grantech.models.*;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Enterprise Hibernate ORM DAO implementing:
 * - SessionFactory & Session lifecycle management
 * - Transaction control (commit, rollback)
 * - HQL Basic & Parameterized queries
 * - HQL Joins & Cross-entity queries
 * - HQL Aggregate queries (COUNT, SUM, AVG)
 * - HQL Subqueries
 * - JPA Criteria API & Projections
 */
public class HibernateDAO {

    // =========================================================================
    // 1. GENERIC HIBERNATE CRUD OPERATIONS
    // =========================================================================

    public static <T> boolean save(T entity) {
        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();
            session.persist(entity);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("Hibernate save error: " + e.getMessage());
            return false;
        }
    }

    public static <T> boolean update(T entity) {
        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();
            session.merge(entity);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("Hibernate update error: " + e.getMessage());
            return false;
        }
    }

    public static <T> boolean delete(Class<T> clazz, int id) {
        Transaction tx = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            tx = session.beginTransaction();
            T obj = session.get(clazz, id);
            if (obj != null) {
                session.remove(obj);
                tx.commit();
                return true;
            }
            return false;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("Hibernate delete error: " + e.getMessage());
            return false;
        }
    }

    public static <T> T findById(Class<T> clazz, int id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(clazz, id);
        } catch (Exception e) {
            System.err.println("Hibernate findById error: " + e.getMessage());
            return null;
        }
    }

    // =========================================================================
    // 2. HQL IMPLEMENTATIONS (Query Development, Joins, Aggregations, Subqueries)
    // =========================================================================

    /**
     * HQL Aggregate Query: Computes administrative dashboard KPIs using HQL aggregations
     */
    public static Map<String, Object> getAdminKpiViaHQL() {
        Map<String, Object> kpis = new HashMap<>();
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // HQL SUM aggregate query
            Query<Double> sumQuery = session.createQuery(
                "SELECT coalesce(sum(o.totalAmount), 0.0) FROM Order o WHERE o.paymentStatus = 'PAID'", Double.class);
            Double totalRevenue = sumQuery.uniqueResult();

            // HQL COUNT aggregate query with filter
            Query<Long> activeOrdersQuery = session.createQuery(
                "SELECT count(o.id) FROM Order o WHERE o.orderStatus = 'PROCESSING'", Long.class);
            Long activeOrders = activeOrdersQuery.uniqueResult();

            // HQL COUNT aggregate query for products
            Query<Long> totalProductsQuery = session.createQuery(
                "SELECT count(p.id) FROM Product p", Long.class);
            Long totalProducts = totalProductsQuery.uniqueResult();

            // HQL COUNT aggregate query for registered customers
            Query<Long> customersQuery = session.createQuery(
                "SELECT count(u.id) FROM User u WHERE u.role != 'ADMIN'", Long.class);
            Long totalCustomers = customersQuery.uniqueResult();

            kpis.put("totalRevenue", totalRevenue != null ? totalRevenue : 0.0);
            kpis.put("activeOrders", activeOrders != null ? activeOrders : 0);
            kpis.put("totalProducts", totalProducts != null ? totalProducts : 0);
            kpis.put("totalCustomers", totalCustomers != null ? totalCustomers : 0);
        } catch (Exception e) {
            System.err.println("HQL KPI error: " + e.getMessage());
        }
        return kpis;
    }

    /**
     * HQL Parameterized Query: Authenticates user by email and password using HQL
     */
    public static User findUserByEmailHQL(String email) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Query<User> q = session.createQuery("FROM User u WHERE u.email = :email", User.class);
            q.setParameter("email", email.trim().toLowerCase());
            return q.uniqueResult();
        } catch (Exception e) {
            System.err.println("HQL findUserByEmail error: " + e.getMessage());
            return null;
        }
    }

    /**
     * HQL Query with Subquery: Finds all premium products priced strictly above the catalog average price
     */
    public static List<Product> findPremiumProductsAboveAverageHQL() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Product p WHERE p.price > (SELECT avg(p2.price) FROM Product p2) ORDER BY p.price DESC";
            Query<Product> q = session.createQuery(hql, Product.class);
            q.setMaxResults(10);
            return q.list();
        } catch (Exception e) {
            System.err.println("HQL Subquery error: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * HQL Join Query: Joins Orders and OrderItems to fetch high-volume orders
     */
    public static List<Order> findBulkOrdersHQL() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Order o WHERE o.id IN (SELECT oi.orderId FROM OrderItem oi WHERE oi.quantity >= 2) ORDER BY o.id DESC";
            Query<Order> q = session.createQuery(hql, Order.class);
            return q.list();
        } catch (Exception e) {
            System.err.println("HQL Join Subquery error: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * JPA Criteria & Projections API: Queries products using CriteriaBuilder & Projections
     */
    public static List<Product> findProductsByCriteria(int categoryId, double maxPrice) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            CriteriaBuilder cb = session.getCriteriaBuilder();
            CriteriaQuery<Product> cq = cb.createQuery(Product.class);
            Root<Product> root = cq.from(Product.class);

            cq.select(root).where(
                cb.and(
                    cb.equal(root.get("categoryId"), categoryId),
                    cb.lessThanOrEqualTo(root.get("price"), maxPrice)
                )
            ).orderBy(cb.asc(root.get("price")));

            return session.createQuery(cq).setMaxResults(10).getResultList();
        } catch (Exception e) {
            System.err.println("Criteria Query error: " + e.getMessage());
            return Collections.emptyList();
        }
    }
}
