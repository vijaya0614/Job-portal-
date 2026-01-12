[file name]: portfolio_skills_save.jsp
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

    // Get form parameters - CORRECTED FIELD NAMES
    String skillName = request.getParameter("skillName");
    String skillLevel = request.getParameter("skillLevel");
    String skillCategory = request.getParameter("skillCategory");
    
    // Validate required fields
    if (skillName == null || skillName.trim().isEmpty() || 
        skillLevel == null || skillLevel.trim().isEmpty() ||
        skillCategory == null || skillCategory.trim().isEmpty()) {
        sess.setAttribute("errorMessage", "Skill name, level, and category are required.");
        response.sendRedirect("portfolio_skills.jsp");
        return;
    }
    
    Connection conn = null;
    PreparedStatement stmt = null;
    
    try {
        // Database connection
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String username = "root";
        String password = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);
        
        // Insert skill into database - CORRECTED COLUMN NAMES
        String sql = "INSERT INTO portfolio_skills (user_id, skill_name, skill_level, skill_category) VALUES (?, ?, ?, ?)";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        stmt.setString(2, skillName.trim());
        stmt.setString(3, skillLevel);
        stmt.setString(4, skillCategory);
        
        int rowsAffected = stmt.executeUpdate();
        
        if (rowsAffected > 0) {
            sess.setAttribute("successMessage", "Skill added successfully!");
        } else {
            sess.setAttribute("errorMessage", "Failed to add skill. Please try again.");
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