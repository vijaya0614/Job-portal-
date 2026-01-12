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
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");

    Connection conn = null;
    PreparedStatement stmt = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String dbUsername = "root";
        String dbPassword = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        String sql = "UPDATE job_seekers SET email = ?, phone = ? WHERE id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, email);
        stmt.setString(2, phone);
        stmt.setInt(3, userId);
        
        int rowsAffected = stmt.executeUpdate();
        
        if (rowsAffected > 0) {
            sess.setAttribute("successMessage", "Profile updated successfully!");
        } else {
            sess.setAttribute("errorMessage", "Failed to update profile.");
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
    
    response.sendRedirect("profile_settings.jsp");
%>