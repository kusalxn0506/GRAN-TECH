package com.java.institute.grantech.servlets;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@WebServlet("/api/upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 20     // 20MB
)
public class FileUploadServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Map<String, Object> responseData = new HashMap<>();

        try {
            Part filePart = req.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                responseData.put("success", false);
                responseData.put("message", "No file selected for upload.");
            } else {
                String submittedFileName = filePart.getSubmittedFileName();
                String fileExt = "";
                if (submittedFileName != null && submittedFileName.contains(".")) {
                    fileExt = submittedFileName.substring(submittedFileName.lastIndexOf(".")).toLowerCase();
                }

                // Allowed extensions: images, pdf, txt, docs, audio, video
                String uniqueName = "upload_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + fileExt;

                // Determine upload directory inside web application
                String uploadPath = req.getServletContext().getRealPath("/uploads");
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                File targetFile = new File(uploadDir, uniqueName);
                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }

                String relativeUrl = "uploads/" + uniqueName;
                responseData.put("success", true);
                responseData.put("message", "File uploaded successfully.");
                responseData.put("filePath", relativeUrl);
                responseData.put("fileName", submittedFileName);
                responseData.put("fileSize", filePart.getSize());
                responseData.put("contentType", filePart.getContentType());
            }
        } catch (Exception e) {
            System.err.println("File upload error: " + e.getMessage());
            responseData.put("success", false);
            responseData.put("message", "File upload failed: " + e.getMessage());
        }

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(responseData));
            out.flush();
        }
    }
}
