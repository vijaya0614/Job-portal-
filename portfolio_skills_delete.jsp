[file name]: portfolio_skills_delete.jsp
[file content begin]
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%
    // Session check
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Integer userId = (Integer) sess.getAttribute("userId");
    String userType = (String) sess.getAttribute("userType");
    
    if (!"jobseeker".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get skill ID parameter
    String skillIdParam = request.getParameter("skill_id");
    if (skillIdParam == null || skillIdParam.trim().isEmpty()) {
        sess.setAttribute("errorMessage", "Skill ID is required.");
        response.sendRedirect("portfolio_skills.jsp");
        return;
    }
    
    int skillId = Integer.parseInt(skillIdParam);
    
    Connection conn = null;
    PreparedStatement stmt = null;
    
    try {
        // Database connection
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String username = "root";
        String password = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);
        
        // Delete skill (only if it belongs to the current user)
        String sql = "DELETE FROM portfolio_skills WHERE id = ? AND user_id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, skillId);
        stmt.setInt(2, userId);
        
        int rowsAffected = stmt.executeUpdate();
        
        if (rowsAffected > 0) {
            sess.setAttribute("successMessage", "Skill deleted successfully!");
        } else {
            sess.setAttribute("errorMessage", "Skill not found or you don't have permission to delete it.");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        sess.setAttribute("errorMessage", "Database error: " + e.getMessage());
    } finally {
        // Close resources
        try {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    response.sendRedirect("portfolio_skills.jsp");
%>
[file content end]