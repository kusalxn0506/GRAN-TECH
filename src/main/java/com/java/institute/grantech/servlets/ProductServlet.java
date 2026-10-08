package com.java.institute.grantech.servlets;

import com.google.gson.Gson;
import com.java.institute.grantech.dao.ProductDAO;
import com.java.institute.grantech.models.Category;
import com.java.institute.grantech.models.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/products")
public class ProductServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String idParam = req.getParameter("id");
        String slugParam = req.getParameter("slug");
        String trendingParam = req.getParameter("trending");
        String categoriesParam = req.getParameter("categories");

        Map<String, Object> responseData = new HashMap<>();

        try {
            if (idParam != null && !idParam.isBlank()) {
                int id = Integer.parseInt(idParam);
                Product p = ProductDAO.getProductById(id);
                if (p != null) {
                    responseData.put("success", true);
                    responseData.put("product", p);
                } else {
                    responseData.put("success", false);
                    responseData.put("message", "Product not found");
                }
            } else if (slugParam != null && !slugParam.isBlank()) {
                Product p = ProductDAO.getProductBySlug(slugParam.trim());
                if (p != null) {
                    responseData.put("success", true);
                    responseData.put("product", p);
                } else {
                    responseData.put("success", false);
                    responseData.put("message", "Product not found");
                }
            } else if ("true".equalsIgnoreCase(trendingParam)) {
                List<Product> trending = ProductDAO.getTrendingProducts(4);
                responseData.put("success", true);
                responseData.put("products", trending);
            } else if ("true".equalsIgnoreCase(categoriesParam)) {
                List<Category> categories = ProductDAO.getCategoriesWithCount();
                responseData.put("success", true);
                responseData.put("categories", categories);
            } else {
                // Search / Filter / Archive query
                Integer categoryId = null;
                if (req.getParameter("categoryId") != null && !req.getParameter("categoryId").isBlank()) {
                    categoryId = Integer.parseInt(req.getParameter("categoryId"));
                }

                Double minPrice = null;
                if (req.getParameter("minPrice") != null && !req.getParameter("minPrice").isBlank()) {
                    minPrice = Double.parseDouble(req.getParameter("minPrice"));
                }

                Double maxPrice = null;
                if (req.getParameter("maxPrice") != null && !req.getParameter("maxPrice").isBlank()) {
                    maxPrice = Double.parseDouble(req.getParameter("maxPrice"));
                }

                String query = req.getParameter("query");
                String sortBy = req.getParameter("sortBy");

                int page = 1;
                if (req.getParameter("page") != null) {
                    try { page = Math.max(1, Integer.parseInt(req.getParameter("page"))); } catch (NumberFormatException ignored) {}
                }

                int pageSize = 12;
                if (req.getParameter("pageSize") != null) {
                    try { pageSize = Math.max(1, Integer.parseInt(req.getParameter("pageSize"))); } catch (NumberFormatException ignored) {}
                }

                int offset = (page - 1) * pageSize;

                List<Product> products = ProductDAO.searchProducts(categoryId, minPrice, maxPrice, query, sortBy, pageSize, offset);
                int totalCount = ProductDAO.getSearchProductsCount(categoryId, minPrice, maxPrice, query);
                int totalPages = (int) Math.ceil((double) totalCount / pageSize);

                List<Category> categories = ProductDAO.getCategoriesWithCount();

                responseData.put("success", true);
                responseData.put("products", products);
                responseData.put("totalCount", totalCount);
                responseData.put("currentPage", page);
                responseData.put("totalPages", totalPages);
                responseData.put("categories", categories);
            }
        } catch (Exception e) {
            responseData.put("success", false);
            responseData.put("message", "Internal server error: " + e.getMessage());
        }

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(responseData));
            out.flush();
        }
    }
}
