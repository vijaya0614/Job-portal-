<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%
    // Session check
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userType") == null || !sess.getAttribute("userType").equals("jobseeker")) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer userId = (Integer) sess.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get form data
    String aboutMe = request.getParameter("aboutMe");
    String currentPosition = request.getParameter("currentPosition");
    String education = request.getParameter("education");
    String contactEmail = request.getParameter("contactEmail");
    String phone = request.getParameter("phone");
    String location = request.getParameter("location");
    String linkedinUrl = request.getParameter("linkedinUrl");
    String githubUrl = request.getParameter("githubUrl");
    String websiteUrl = request.getParameter("websiteUrl");

    Connection conn = null;
    PreparedStatement stmt = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String dbUsername = "root";
        String dbPassword = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        // Check if portfolio exists
        String checkSql = "SELECT id FROM job_seeker_portfolios WHERE user_id = ?";
        stmt = conn.prepareStatement(checkSql);
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            // Update existing portfolio
            String updateSql = "UPDATE job_seeker_portfolios SET about_me=?, current_position=?, education=?, contact_email=?, phone=?, location=?, linkedin_url=?, github_url=?, website_url=?, updated_at=CURRENT_TIMESTAMP WHERE user_id=?";
            stmt = conn.prepareStatement(updateSql);
            stmt.setString(1, aboutMe);
            stmt.setString(2, currentPosition);
            stmt.setString(3, education);
            stmt.setString(4, contactEmail);
            stmt.setString(5, phone);
            stmt.setString(6, location);
            stmt.setString(7, linkedinUrl);
            stmt.setString(8, githubUrl);
            stmt.setString(9, websiteUrl);
            stmt.setInt(10, userId);
        } else {
            // Insert new portfolio
            String insertSql = "INSERT INTO job_seeker_portfolios (user_id, about_me, current_position, education, contact_email, phone, location, linkedin_url, github_url, website_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(insertSql);
            stmt.setInt(1, userId);
            stmt.setString(2, aboutMe);
            stmt.setString(3, currentPosition);
            stmt.setString(4, education);
            stmt.setString(5, contactEmail);
            stmt.setString(6, phone);
            stmt.setString(7, location);
            stmt.setString(8, linkedinUrl);
            stmt.setString(9, githubUrl);
            stmt.setString(10, websiteUrl);
        }
        
        int rowsAffected = stmt.executeUpdate();
        
        if (rowsAffected > 0) {
            sess.setAttribute("successMessage", "Portfolio saved successfully!");
        } else {
            sess.setAttribute("errorMessage", "Failed to save portfolio. Please try again.");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        sess.setAttribute("errorMessage", "Database error: " + e.getMessage());
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    response.sendRedirect("portfolio.jsp");
%>