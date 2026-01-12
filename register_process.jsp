<%@ page import="java.sql.*, java.util.*" %>
<%
    String userType = request.getParameter("userType");
    String fullName = request.getParameter("fullName");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String phone = request.getParameter("phone");

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        // Database connection - CHANGE PASSWORD!
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String username = "root";
        String dbPassword = "navya@2006"; // CHANGE THIS!
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, dbPassword);
        
        if ("jobseeker".equals(userType)) {
            int experience = Integer.parseInt(request.getParameter("experience"));
            String skills = request.getParameter("skills");
            String education = request.getParameter("education");
            
            String sql = "INSERT INTO job_seekers (full_name, email, password, phone, experience, skills, education) VALUES (?, ?, ?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, fullName);
            stmt.setString(2, email);
            stmt.setString(3, password);
            stmt.setString(4, phone);
            stmt.setInt(5, experience);
            stmt.setString(6, skills);
            stmt.setString(7, education);
            
            stmt.executeUpdate();
%>
            <!DOCTYPE html>
            <html>
            <head>
                <title>Registration Successful</title>
                <style>
                    body { font-family: Arial; background: #f8f9fa; padding: 50px; text-align: center; }
                    .success { color: green; font-size: 24px; margin: 20px 0; }
                    .btn { display: inline-block; padding: 10px 20px; background: #FA976A; color: white; 
                           text-decoration: none; border-radius: 5px; margin: 10px; }
                </style>
            </head>
            <body>
                <div class="success">✅ Job Seeker Registration Successful!</div>
                <a href="login.jsp" class="btn">Login Now</a>
                <a href="index.jsp" class="btn">Go to Home</a>
            </body>
            </html>
<%
        } else if ("recruiter".equals(userType)) {
            String company = request.getParameter("company");
            String position = request.getParameter("position");
            String industry = request.getParameter("industry");
            
            String sql = "INSERT INTO recruiters (full_name, email, password, phone, company, position, industry) VALUES (?, ?, ?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, fullName);
            stmt.setString(2, email);
            stmt.setString(3, password);
            stmt.setString(4, phone);
            stmt.setString(5, company);
            stmt.setString(6, position);
            stmt.setString(7, industry);
            
            stmt.executeUpdate();
%>
            <!DOCTYPE html>
            <html>
            <head>
                <title>Registration Successful</title>
                <style>
                    body { font-family: Arial; background: #f8f9fa; padding: 50px; text-align: center; }
                    .success { color: green; font-size: 24px; margin: 20px 0; }
                    .btn { display: inline-block; padding: 10px 20px; background: #FA976A; color: white; 
                           text-decoration: none; border-radius: 5px; margin: 10px; }
                </style>
            </head>
            <body>
                <div class="success">✅ Recruiter Registration Successful!</div>
                <a href="login.jsp" class="btn">Login Now</a>
                <a href="index.jsp" class="btn">Go to Home</a>
            </body>
            </html>
<%
        }
        conn.close();
    } catch (Exception e) {
%>
        <!DOCTYPE html>
        <html>
        <head>
            <title>Registration Failed</title>
            <style>
                body { font-family: Arial; background: #f8f9fa; padding: 50px; text-align: center; }
                .error { color: red; font-size: 24px; margin: 20px 0; }
                .btn { display: inline-block; padding: 10px 20px; background: #FA976A; color: white; 
                       text-decoration: none; border-radius: 5px; margin: 10px; }
            </style>
        </head>
        <body>
            <div class="error">❌ Registration Failed: <%= e.getMessage() %></div>
            <a href="register.jsp" class="btn">Try Again</a>
            <a href="index.jsp" class="btn">Go to Home</a>
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
%>