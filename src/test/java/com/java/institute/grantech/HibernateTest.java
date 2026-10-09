package com.java.institute.grantech;

import com.java.institute.grantech.config.HibernateUtil;
import com.java.institute.grantech.dao.HibernateDAO;
import com.java.institute.grantech.dao.WishlistDAO;
import com.java.institute.grantech.models.Product;
import com.java.institute.grantech.models.User;
import org.hibernate.SessionFactory;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

public class HibernateTest {

    @Test
    public void testHibernateSessionFactoryInitialization() {
        SessionFactory sf = HibernateUtil.getSessionFactory();
        Assertions.assertNotNull(sf, "SessionFactory should be successfully initialized.");
        Assertions.assertFalse(sf.isClosed(), "SessionFactory should be open.");
    }

    @Test
    public void testHQLQueriesAndAggregations() {
        Map<String, Object> kpis = HibernateDAO.getAdminKpiViaHQL();
        Assertions.assertNotNull(kpis, "KPI map should not be null");
        Assertions.assertTrue(kpis.containsKey("totalProducts"), "KPIs should contain totalProducts via HQL");

        List<Product> premium = HibernateDAO.findPremiumProductsAboveAverageHQL();
        Assertions.assertNotNull(premium, "Subquery HQL result should not be null");

        User user = HibernateDAO.findUserByEmailHQL("admin@grantech.com");
        Assertions.assertNotNull(user, "User should be retrieved via HQL parameterized query");
        Assertions.assertEquals("System Administrator", user.getFullName());
    }

    @Test
    public void testHibernateWishlistToggle() {
        // Toggle item for test user 2 (Kusal Nirmala) and product 1
        boolean added = WishlistDAO.toggleWishlist(2, 1);
        // Toggle again to restore original state
        boolean removed = WishlistDAO.toggleWishlist(2, 1);
        Assertions.assertNotEquals(added, removed, "Wishlist toggle should flip state");
    }
}
