<%@ page import="java.sql.*" %>
<%
    // Get session
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userType") == null || 
        !sess.getAttribute("userType").equals("jobseeker")) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (Integer) sess.getAttribute("userId");
    String interests = request.getParameter("interests");

    String url = "jdbc:mysql://localhost:3306/jobportal";
    String dbUser = "root";
    String dbPass = "navya@2006";

    Connection conn = null;
    PreparedStatement stmt = null;
    PreparedStatement jobStmt = null;
    ResultSet rs = null;

    boolean success = false;
    int jobsFound = 0;

    try {
        if (interests != null && !interests.trim().isEmpty()) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPass);

            // First, clear existing preferences for this user
            String deleteSQL = "DELETE FROM job_preferences WHERE job_seeker_id = ?";
            stmt = conn.prepareStatement(deleteSQL);
            stmt.setInt(1, userId);
            stmt.executeUpdate();
            stmt.close();

            // Split user interests into keywords
            String[] keywords = interests.split(",");
            
            // For each keyword, find matching jobs and mark them as preferred
            for (String keyword : keywords) {
                String trimmedKeyword = keyword.trim();
                if (!trimmedKeyword.isEmpty()) {
                    // Search for jobs matching this keyword
                    String jobSQL = "SELECT id FROM jobs WHERE " +
                                   "LOWER(job_title) LIKE LOWER(?) OR " +
                                   "LOWER(requirements) LIKE LOWER(?) OR " +
                                   "LOWER(company_name) LIKE LOWER(?) OR " +
                                   "LOWER(job_description) LIKE LOWER(?)";
                    jobStmt = conn.prepareStatement(jobSQL);
                    String searchTerm = "%" + trimmedKeyword + "%";
                    jobStmt.setString(1, searchTerm);
                    jobStmt.setString(2, searchTerm);
                    jobStmt.setString(3, searchTerm);
                    jobStmt.setString(4, searchTerm);
                    
                    rs = jobStmt.executeQuery();
                    
                    while (rs.next()) {
                        int jobId = rs.getInt("id");
                        
                        // Insert preference for this job
                        String insertSQL = "INSERT INTO job_preferences (job_seeker_id, job_id, is_interested, preference_score) VALUES (?, ?, 1, 5)";
                        stmt = conn.prepareStatement(insertSQL);
                        stmt.setInt(1, userId);
                        stmt.setInt(2, jobId);
                        stmt.executeUpdate();
                        stmt.close();
                        
                        jobsFound++;
                    }
                    
                    rs.close();
                    jobStmt.close();
                }
            }
            
            success = true;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (jobStmt != null) jobStmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Redirect back with message
    if (success) {
        if (jobsFound > 0) {
            response.sendRedirect("job_recommendations.jsp?message=Found+" + jobsFound + "+jobs+matching+your+preferences!");
        } else {
            response.sendRedirect("job_recommendations.jsp?message=No+jobs+found+matching+your+preferences.+Try+different+keywords.");
        }
    } else {
        response.sendRedirect("job_recommendations.jsp?error=Failed+to+save+preferences");
    }
%>