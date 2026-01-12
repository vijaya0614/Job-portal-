<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int jobId = Integer.parseInt(request.getParameter("job_id"));
        int jobSeekerId = Integer.parseInt(request.getParameter("job_seeker_id"));
        
        Connection conn = null;
        PreparedStatement stmt = null;
        PreparedStatement stmt2 = null;  // Use separate statement for second query
        ResultSet rs = null;
        
        try {
            // Database connection
            String url = "jdbc:mysql://localhost:3306/jobportal";
            String username = "root";
            String password = "navya@2006";
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, username, password);
            
            // First, get job details to know which custom fields are enabled
            String jobSql = "SELECT * FROM jobs WHERE id = ?";
            stmt = conn.prepareStatement(jobSql);
            stmt.setInt(1, jobId);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                // Build SQL for job_applications table
                String sql = "INSERT INTO job_applications (job_id, job_seeker_id, recruiter_id, job_title, company_name, job_description, location, job_type, application_date, status";
                
                String values = "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), 'Pending'";
                
                // Add custom field columns
                for(int i = 1; i <= 10; i++) {
                    boolean isEnabled = rs.getBoolean("custom_field" + i + "_enabled");
                    if (isEnabled) {
                        sql += ", custom_field" + i + "_name, custom_field" + i + "_type, custom_field" + i + "_value";
                        values += ", ?, ?, ?";
                    }
                }
                
                sql += ") " + values + ")";
                
                // Create a NEW PreparedStatement for the INSERT operation
                stmt2 = conn.prepareStatement(sql);
                
                // Set basic parameters
                stmt2.setInt(1, jobId);
                stmt2.setInt(2, jobSeekerId);
                stmt2.setInt(3, rs.getInt("recruiter_id"));
                stmt2.setString(4, rs.getString("job_title"));
                stmt2.setString(5, rs.getString("company_name"));
                stmt2.setString(6, rs.getString("job_description"));
                stmt2.setString(7, rs.getString("location"));
                stmt2.setString(8, rs.getString("job_type"));
                
                // Set custom field parameters
                int paramIndex = 9;
                for(int i = 1; i <= 10; i++) {
                    boolean isEnabled = rs.getBoolean("custom_field" + i + "_enabled");
                    if (isEnabled) {
                        String fieldName = rs.getString("custom_field" + i + "_name");
                        String fieldType = rs.getString("custom_field" + i + "_type");
                        String fieldValue = request.getParameter("custom_field" + i);
                        
                        stmt2.setString(paramIndex++, fieldName);
                        stmt2.setString(paramIndex++, fieldType);
                        stmt2.setString(paramIndex++, fieldValue);
                    }
                }
                
                int rowsAffected = stmt2.executeUpdate();
                
                if (rowsAffected > 0) {
%>
                    <!DOCTYPE html>
                    <html>
                    <head>
                        <title>Application Submitted</title>
                        <style>
                            body { font-family: 'Inter', sans-serif; background: #f8f9fa; padding: 50px; text-align: center; }
                            .success { color: #28a745; font-size: 24px; margin: 20px 0; }
                            .btn { display: inline-block; padding: 12px 24px; background: #FA976A; color: white; 
                                   text-decoration: none; border-radius: 8px; margin: 10px; font-weight: 600; }
                        </style>
                    </head>
                    <body>
                        <div class="success">✅ Application Submitted Successfully!</div>
                        <p>Your application has been sent to the employer.</p>
                        <a href="jobseek_dashboard.jsp" class="btn">Back to Dashboard</a>
                        
                    </body>
                    </html>
<%
                }
            }
        } catch (Exception e) {
%>
            <!DOCTYPE html>
            <html>
            <head>
                <title>Error</title>
                <style>
                    body { font-family: 'Inter', sans-serif; background: #f8f9fa; padding: 50px; text-align: center; }
                    .error { color: #dc3545; font-size: 24px; margin: 20px 0; }
                    .btn { display: inline-block; padding: 12px 24px; background: #FA976A; color: white; 
                           text-decoration: none; border-radius: 8px; margin: 10px; font-weight: 600; }
                </style>
            </head>
            <body>
                <div class="error">❌ Error Submitting Application: <%= e.getMessage() %></div>
                <a href="apply_job.jsp?job_id=<%= jobId %>" class="btn">Try Again</a>
                <a href="jobseek_dashboard.jsp" class="btn">Back to Dashboard</a>
            </body>
            </html>
<%
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (stmt2 != null) stmt2.close();  // Close the second statement too
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        response.sendRedirect("jobseek_dashboard.jsp");
    }
%>