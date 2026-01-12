<%@ page import="java.sql.*" %>
<%
    // Check if recruiter is logged in
    String userName = (String) session.getAttribute("userName");
    String userType = (String) session.getAttribute("userType");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userName == null || !"recruiter".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String applicationId = request.getParameter("application_id");
    String status = request.getParameter("status");
    String jobId = request.getParameter("job_id");
    
    if (applicationId == null || status == null || jobId == null) {
        response.sendRedirect("my_jobs.jsp");
        return;
    }
    
    Connection conn = null;
    PreparedStatement stmt = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String dbUsername = "root";
        String dbPassword = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        // Update application status
        String sql = "UPDATE job_applications SET status = ? WHERE id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, status);
        stmt.setInt(2, Integer.parseInt(applicationId));
        stmt.executeUpdate();
        
        // Redirect back to applications page
        response.sendRedirect("view_applications.jsp?job_id=" + jobId);
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("view_applications.jsp?job_id=" + jobId + "&error=1");
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>