<%@ page import="java.sql.*" %>
<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int recruiterId = Integer.parseInt(request.getParameter("recruiter_id"));
        String jobTitle = request.getParameter("job_title");
        String companyName = request.getParameter("company_name");
        String jobDescription = request.getParameter("job_description");
        String requirements = request.getParameter("requirements");
        String location = request.getParameter("location");
        String salaryRange = request.getParameter("salary_range");
        String jobType = request.getParameter("job_type");

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            // Database connection
            String url = "jdbc:mysql://localhost:3306/jobportal";
            String username = "root";
            String dbPassword = "navya@2006";
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, username, dbPassword);
            
            // Build SQL - EXACTLY SAME AS YOUR ORIGINAL
            String sql = "INSERT INTO jobs (recruiter_id, job_title, company_name, job_description, requirements, location, salary_range, job_type";
            String values = "VALUES (?, ?, ?, ?, ?, ?, ?, ?";
            
            // Add all 10 custom fields to SQL
            for(int i = 1; i <= 10; i++) {
                sql += ", custom_field" + i + "_name, custom_field" + i + "_type, custom_field" + i + "_enabled";
                values += ", ?, ?, ?";
            }
            
            sql += ") " + values + ")";
            
            stmt = conn.prepareStatement(sql);
            
            // Set basic job parameters
            stmt.setInt(1, recruiterId);
            stmt.setString(2, jobTitle);
            stmt.setString(3, companyName);
            stmt.setString(4, jobDescription);
            stmt.setString(5, requirements);
            stmt.setString(6, location);
            stmt.setString(7, salaryRange);
            stmt.setString(8, jobType);
            
            // Set custom field parameters - EXACTLY SAME AS YOUR ORIGINAL
            int paramIndex = 9;
            for(int i = 1; i <= 10; i++) {
                String fieldName = request.getParameter("custom_field" + i + "_name");
                String fieldType = request.getParameter("custom_field" + i + "_type");
                boolean isEnabled = "true".equals(request.getParameter("custom_field" + i + "_enabled"));
                
                // Only store if enabled and has values
                if (isEnabled && fieldName != null && !fieldName.trim().isEmpty() && fieldType != null && !fieldType.isEmpty()) {
                    stmt.setString(paramIndex++, fieldName);
                    stmt.setString(paramIndex++, fieldType);
                    stmt.setBoolean(paramIndex++, true);
                } else {
                    // Store as NULL/disabled
                    stmt.setNull(paramIndex++, java.sql.Types.VARCHAR);
                    stmt.setNull(paramIndex++, java.sql.Types.VARCHAR);
                    stmt.setBoolean(paramIndex++, false);
                }
            }
            
            int rowsAffected = stmt.executeUpdate();
            
%>
            <!DOCTYPE html>
            <html>
            <head>
                <title>Job Posted Successfully</title>
                <style>
                    body { font-family: Arial; background: #f8f9fa; padding: 50px; text-align: center; }
                    .success { color: green; font-size: 24px; margin: 20px 0; }
                    .btn { display: inline-block; padding: 10px 20px; background: #FA976A; color: white; 
                           text-decoration: none; border-radius: 5px; margin: 10px; }
                </style>
            </head>
            <body>
                <div class="success"> Job Posted Successfully!</div>
                <p>Your job has been posted with custom application form.</p>
                <a href="recruiter_dashboard.jsp" class="btn">Back to Dashboard</a>
                <a href="post_job.jsp" class="btn">Post Another Job</a>
            </body>
            </html>
<%
        } catch (Exception e) {
%>
            <!DOCTYPE html>
            <html>
            <head>
                <title>Error Posting Job</title>
                <style>
                    body { font-family: Arial; background: #f8f9fa; padding: 50px; text-align: center; }
                    .error { color: red; font-size: 24px; margin: 20px 0; }
                    .btn { display: inline-block; padding: 10px 20px; background: #FA976A; color: white; 
                           text-decoration: none; border-radius: 5px; margin: 10px; }
                </style>
            </head>
            <body>
                <div class="error">Error Posting Job: <%= e.getMessage() %></div>
                <a href="post_job.jsp" class="btn">Try Again</a>
                <a href="recruiter_dashboard.jsp" class="btn">Back to Dashboard</a>
            </body>
            </html>
<%
            e.printStackTrace();
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        response.sendRedirect("post_job.jsp");
    }
%>