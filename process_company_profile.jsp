<%@ page import="java.sql.*, java.util.*, java.io.*, com.oreilly.servlet.MultipartRequest, com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userType = (String) session.getAttribute("userType");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userName == null || !"recruiter".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String action = request.getParameter("action");
    String message = "";
    String messageType = "";

    // Handle file upload
    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "company";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs();
    }

    int maxFileSize = 2 * 1024 * 1024; // 2MB

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String username = "root";
        String dbPassword = "navya@2006";
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, dbPassword);

        if ("remove_logo".equals(action)) {
            // Remove logo
            int companyId = Integer.parseInt(request.getParameter("company_id"));
            
            // Get current logo path
            String getLogoSql = "SELECT file_path FROM company_media WHERE company_id = ? AND file_type = 'logo' AND is_active = TRUE";
            stmt = conn.prepareStatement(getLogoSql);
            stmt.setInt(1, companyId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                String filePath = rs.getString("file_path");
                // Delete physical file
                File file = new File(getServletContext().getRealPath("") + filePath);
                if (file.exists()) {
                    file.delete();
                }
            }
            
            // Update database
            String removeLogoSql = "UPDATE company_media SET is_active = FALSE WHERE company_id = ? AND file_type = 'logo'";
            stmt = conn.prepareStatement(removeLogoSql);
            stmt.setInt(1, companyId);
            stmt.executeUpdate();
            
            message = "Logo removed successfully";
            messageType = "success";
            
        } else {
            MultipartRequest mrequest = new MultipartRequest(request, uploadPath, maxFileSize, new DefaultFileRenamePolicy());
            
            if ("update".equals(action)) {
                // Update existing company
                int companyId = Integer.parseInt(mrequest.getParameter("company_id"));
                
                // Update company table
                String updateCompanySql = "UPDATE companies SET company_name=?, legal_name=?, company_email=?, phone=?, website=?, industry=?, company_size=?, founded_year=?, description=?, mission=?, linkedin_url=?, twitter_url=?, facebook_url=?, instagram_url=?, updated_at=CURRENT_TIMESTAMP WHERE id=? AND user_id=?";
                stmt = conn.prepareStatement(updateCompanySql);
                stmt.setString(1, mrequest.getParameter("company_name"));
                stmt.setString(2, mrequest.getParameter("legal_name"));
                stmt.setString(3, mrequest.getParameter("company_email"));
                stmt.setString(4, mrequest.getParameter("phone"));
                stmt.setString(5, mrequest.getParameter("website"));
                stmt.setString(6, mrequest.getParameter("industry"));
                stmt.setString(7, mrequest.getParameter("company_size"));
                
                String foundedYear = mrequest.getParameter("founded_year");
                if (foundedYear != null && !foundedYear.isEmpty()) {
                    stmt.setInt(8, Integer.parseInt(foundedYear));
                } else {
                    stmt.setNull(8, java.sql.Types.INTEGER);
                }
                
                stmt.setString(9, mrequest.getParameter("description"));
                stmt.setString(10, mrequest.getParameter("mission"));
                stmt.setString(11, mrequest.getParameter("linkedin_url"));
                stmt.setString(12, mrequest.getParameter("twitter_url"));
                stmt.setString(13, mrequest.getParameter("facebook_url"));
                stmt.setString(14, mrequest.getParameter("instagram_url"));
                stmt.setInt(15, companyId);
                stmt.setInt(16, userId);
                
                int rowsUpdated = stmt.executeUpdate();
                
                if (rowsUpdated > 0) {
                    message = "Company profile updated successfully";
                    messageType = "success";
                } else {
                    message = "Failed to update company profile";
                    messageType = "error";
                }
                
            } else {
                // Create new company
                String insertCompanySql = "INSERT INTO companies (user_id, company_name, legal_name, company_email, phone, website, industry, company_size, founded_year, description, mission, linkedin_url, twitter_url, facebook_url, instagram_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                stmt = conn.prepareStatement(insertCompanySql, Statement.RETURN_GENERATED_KEYS);
                stmt.setInt(1, userId);
                stmt.setString(2, mrequest.getParameter("company_name"));
                stmt.setString(3, mrequest.getParameter("legal_name"));
                stmt.setString(4, mrequest.getParameter("company_email"));
                stmt.setString(5, mrequest.getParameter("phone"));
                stmt.setString(6, mrequest.getParameter("website"));
                stmt.setString(7, mrequest.getParameter("industry"));
                stmt.setString(8, mrequest.getParameter("company_size"));
                
                String foundedYear = mrequest.getParameter("founded_year");
                if (foundedYear != null && !foundedYear.isEmpty()) {
                    stmt.setInt(9, Integer.parseInt(foundedYear));
                } else {
                    stmt.setNull(9, java.sql.Types.INTEGER);
                }
                
                stmt.setString(10, mrequest.getParameter("description"));
                stmt.setString(11, mrequest.getParameter("mission"));
                stmt.setString(12, mrequest.getParameter("linkedin_url"));
                stmt.setString(13, mrequest.getParameter("twitter_url"));
                stmt.setString(14, mrequest.getParameter("facebook_url"));
                stmt.setString(15, mrequest.getParameter("instagram_url"));
                
                int rowsInserted = stmt.executeUpdate();
                
                if (rowsInserted > 0) {
                    // Get the generated company ID
                    rs = stmt.getGeneratedKeys();
                    int companyId = 0;
                    if (rs.next()) {
                        companyId = rs.getInt(1);
                    }
                    
                    message = "Company profile created successfully";
                    messageType = "success";
                } else {
                    message = "Failed to create company profile";
                    messageType = "error";
                }
            }

            // Handle address
            String addressLine1 = mrequest.getParameter("address_line_1");
            if (addressLine1 != null && !addressLine1.trim().isEmpty()) {
                int companyId = 0;
                if ("update".equals(action)) {
                    companyId = Integer.parseInt(mrequest.getParameter("company_id"));
                } else {
                    rs = stmt.getGeneratedKeys();
                    if (rs.next()) {
                        companyId = rs.getInt(1);
                    }
                }
                
                if (companyId > 0) {
                    // Check if address exists
                    String checkAddressSql = "SELECT id FROM company_addresses WHERE company_id = ? AND is_primary = TRUE";
                    stmt = conn.prepareStatement(checkAddressSql);
                    stmt.setInt(1, companyId);
                    rs = stmt.executeQuery();
                    
                    if (rs.next()) {
                        // Update existing address
                        String updateAddressSql = "UPDATE company_addresses SET address_line_1=?, address_line_2=?, city=?, state=?, country=?, postal_code=? WHERE company_id=? AND is_primary=TRUE";
                        stmt = conn.prepareStatement(updateAddressSql);
                        stmt.setString(1, addressLine1);
                        stmt.setString(2, mrequest.getParameter("address_line_2"));
                        stmt.setString(3, mrequest.getParameter("city"));
                        stmt.setString(4, mrequest.getParameter("state"));
                        stmt.setString(5, mrequest.getParameter("country"));
                        stmt.setString(6, mrequest.getParameter("postal_code"));
                        stmt.setInt(7, companyId);
                        stmt.executeUpdate();
                    } else {
                        // Insert new address
                        String insertAddressSql = "INSERT INTO company_addresses (company_id, address_line_1, address_line_2, city, state, country, postal_code, is_primary) VALUES (?, ?, ?, ?, ?, ?, ?, TRUE)";
                        stmt = conn.prepareStatement(insertAddressSql);
                        stmt.setInt(1, companyId);
                        stmt.setString(2, addressLine1);
                        stmt.setString(3, mrequest.getParameter("address_line_2"));
                        stmt.setString(4, mrequest.getParameter("city"));
                        stmt.setString(5, mrequest.getParameter("state"));
                        stmt.setString(6, mrequest.getParameter("country"));
                        stmt.setString(7, mrequest.getParameter("postal_code"));
                        stmt.executeUpdate();
                    }
                }
            }

            // Handle logo upload
            File logoFile = mrequest.getFile("logo");
            if (logoFile != null) {
                int companyId = 0;
                if ("update".equals(action)) {
                    companyId = Integer.parseInt(mrequest.getParameter("company_id"));
                } else {
                    rs = stmt.getGeneratedKeys();
                    if (rs.next()) {
                        companyId = rs.getInt(1);
                    }
                }
                
                if (companyId > 0) {
                    // Deactivate old logos
                    String deactivateLogoSql = "UPDATE company_media SET is_active = FALSE WHERE company_id = ? AND file_type = 'logo'";
                    stmt = conn.prepareStatement(deactivateLogoSql);
                    stmt.setInt(1, companyId);
                    stmt.executeUpdate();
                    
                    // Insert new logo
                    String fileName = mrequest.getFilesystemName("logo");
                    String filePath = "/uploads/company/" + fileName;
                    
                    String insertLogoSql = "INSERT INTO company_media (company_id, file_name, file_path, file_type) VALUES (?, ?, ?, 'logo')";
                    stmt = conn.prepareStatement(insertLogoSql);
                    stmt.setInt(1, companyId);
                    stmt.setString(2, fileName);
                    stmt.setString(3, filePath);
                    stmt.executeUpdate();
                }
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
        message = "Error processing request: " + e.getMessage();
        messageType = "error";
    } finally {
        try { 
            if (rs != null) rs.close(); 
            if (stmt != null) stmt.close(); 
            if (conn != null) conn.close(); 
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Redirect with message
    session.setAttribute("message", message);
    session.setAttribute("messageType", messageType);
    response.sendRedirect("company_profile.jsp");
%>