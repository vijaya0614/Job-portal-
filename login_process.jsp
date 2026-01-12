<%@ page import="java.sql.*, java.util.*" %>
<%
String userType = request.getParameter("userType");
String email = request.getParameter("email");
String password = request.getParameter("password");

Connection conn = null;
PreparedStatement stmt = null;
ResultSet rs = null;

try {
    // Database connection - USE SAME PASSWORD AS register_process.jsp!
    String url = "jdbc:mysql://localhost:3306/jobportal";
    String username = "root";
    String dbPassword = "navya@2006"; // ← MUST MATCH!
    
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(url, username, dbPassword);

    boolean isValidUser = false;
    String userName = "";
    int userId = 0;

    if ("jobseeker".equals(userType)) {
        String sql = "SELECT * FROM job_seekers WHERE email = ? AND password = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, email);
        stmt.setString(2, password);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            isValidUser = true;
            userName = rs.getString("full_name");
            userId = rs.getInt("id");
        }
    } else if ("recruiter".equals(userType)) {
        String sql = "SELECT * FROM recruiters WHERE email = ? AND password = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, email);
        stmt.setString(2, password);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            isValidUser = true;
            userName = rs.getString("full_name");
            userId = rs.getInt("id");
        }
    }

    if (isValidUser) {
        // Store user info in session
        session.setAttribute("userId", userId);
        session.setAttribute("userName", userName);
        session.setAttribute("userType", userType);
        session.setAttribute("email", email);
        
        // Redirect to different dashboards based on user type
%>
        <!DOCTYPE html>
        <html>
        <head>
            <title>Login Successful</title>
            <%
    if ("jobseeker".equals(userType)) {
        response.sendRedirect("jobseek_dashboard.jsp");
    } else {
        response.sendRedirect("recruiter_dashboard.jsp");
    }
%>

        </head>
        <body>
            <p>Login successful! Redirecting to dashboard...</p>
        </body>
        </html>
<%
    } else {
%>
        <!DOCTYPE html>
        <html>
        <head>
            <title>Login Failed</title>
            <style>
                body { 
                    font-family: Arial, sans-serif; 
                    background: #f8f9fa; 
                    padding: 50px; 
                    text-align: center; 
                    margin: 0;
                }
                .container {
                    max-width: 500px;
                    margin: 0 auto;
                    background: white;
                    padding: 40px;
                    border-radius: 10px;
                    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                }
                .error { 
                    color: #dc3545; 
                    font-size: 24px; 
                    margin: 20px 0; 
                }
                .btn { 
                    display: inline-block; 
                    padding: 12px 25px; 
                    background: #FA976A; 
                    color: white; 
                    text-decoration: none; 
                    border-radius: 5px; 
                    margin: 10px;
                    font-weight: bold;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="error">❌ Invalid email or password!</div>
                <p>Please check your credentials and try again.</p>
                <div>
                    <a href="login.jsp" class="btn">Try Again</a>
                    <a href="index.jsp" class="btn">Go to Home</a>
                </div>
            </div>
        </body>
        </html>
<%
    }

} catch (Exception e) {
%>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Login Error</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                background: #f8f9fa; 
                padding: 50px; 
                text-align: center; 
                margin: 0;
            }
            .container {
                max-width: 500px;
                margin: 0 auto;
                background: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }
            .error { 
                color: #dc3545; 
                font-size: 24px; 
                margin: 20px 0; 
            }
            .btn { 
                display: inline-block; 
                padding: 12px 25px; 
                background: #FA976A; 
                color: white; 
                text-decoration: none; 
                border-radius: 5px; 
                margin: 10px;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="error">❌ Login Error</div>
            <p>Error: <%= e.getMessage() %></p>
            <div>
                <a href="login.jsp" class="btn">Try Again</a>
                <a href="index.jsp" class="btn">Go to Home</a>
            </div>
        </div>
    </body>
    </html>
<%
    e.printStackTrace();
} finally {
    try {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>
