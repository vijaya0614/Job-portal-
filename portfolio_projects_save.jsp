[file name]: portfolio_projects_save.jsp
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

    // Get form parameters
    String projectName = request.getParameter("projectName");
    String projectDescription = request.getParameter("projectDescription");
    String technologiesUsed = request.getParameter("technologiesUsed");
    String projectUrl = request.getParameter("projectUrl");
    String githubUrl = request.getParameter("githubUrl");
    
    // Validate required fields
    if (projectName == null || projectName.trim().isEmpty() || 
        projectDescription == null || projectDescription.trim().isEmpty() ||
        technologiesUsed == null || technologiesUsed.trim().isEmpty()) {
        sess.setAttribute("errorMessage", "Project name, description, and technologies are required.");
        response.sendRedirect("portfolio_projects.jsp");
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
        
        // Insert project into database
        String sql = "INSERT INTO portfolio_projects (user_id, project_name, project_description, technologies_used, project_url, github_url) VALUES (?, ?, ?, ?, ?, ?)";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        stmt.setString(2, projectName.trim());
        stmt.setString(3, projectDescription.trim());
        stmt.setString(4, technologiesUsed.trim());
        stmt.setString(5, projectUrl != null && !projectUrl.trim().isEmpty() ? projectUrl.trim() : null);
        stmt.setString(6, githubUrl != null && !githubUrl.trim().isEmpty() ? githubUrl.trim() : null);
        
        int rowsAffected = stmt.executeUpdate();
        
        if (rowsAffected > 0) {
            sess.setAttribute("successMessage", "Project added successfully!");
        } else {
            sess.setAttribute("errorMessage", "Failed to add project. Please try again.");
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
    
    response.sendRedirect("portfolio_projects.jsp");
%>
[file content end]