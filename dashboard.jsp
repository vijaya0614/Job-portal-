<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in
    String userName = (String) session.getAttribute("userName");
    String userType = (String) session.getAttribute("userType");
    
    if (userName == null) {
%>
        <script>window.location.href = "login.jsp";</script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | JobPortal</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: #f8f9fa;
        }

        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 50px;
            background-color: white;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .logo {
            font-size: 24px;
            font-weight: 800;
            color: #FA976A;
            text-decoration: none;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .welcome {
            color: #2C3E50;
            font-weight: 600;
        }

        .logout-btn {
            background: #FA976A;
            color: white;
            padding: 8px 15px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 600;
        }

        .dashboard-container {
            max-width: 800px;
            margin: 50px auto;
            padding: 0 20px;
        }

        .dashboard-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        .welcome-title {
            color: #2C3E50;
            font-size: 32px;
            margin-bottom: 10px;
        }

        .user-type {
            color: #FA976A;
            font-size: 20px;
            margin-bottom: 30px;
        }

        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }

        .feature-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            border: 2px solid #e0e0e0;
        }

        .feature-card h3 {
            color: #2C3E50;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <header class="navbar">
        <a href="index.jsp" class="logo">JobPortal.io</a>
        <div class="user-info">
            <span class="welcome">Welcome, <%= userName %>!</span>
            <a href="logout.jsp" class="logout-btn">Logout</a>
        </div>
    </header>

    <!-- Dashboard Content -->
    <div class="dashboard-container">
        <div class="dashboard-card">
            <h1 class="welcome-title">Welcome to Your Dashboard!</h1>
            <div class="user-type">
                <%= userType.equals("jobseeker") ? "Job Seeker" : "Recruiter" %>
            </div>
            
            <div class="features">
                <% if (userType.equals("jobseeker")) { %>
                    <div class="feature-card">
                        <h3>🔍 Search Jobs</h3>
                        <p>Find your dream job</p>
                    </div>
                    <div class="feature-card">
                        <h3>📊 Profile</h3>
                        <p>Manage your profile</p>
                    </div>
                    <div class="feature-card">
                        <h3>📨 Applications</h3>
                        <p>Track your applications</p>
                    </div>
                <% } else { %>
                    <div class="feature-card">
                        <h3>📝 Post Job</h3>
                        <p>Create new job listings</p>
                    </div>
                    <div class="feature-card">
                        <h3>👥 Manage Candidates</h3>
                        <p>View and manage applicants</p>
                    </div>
                    <div class="feature-card">
                        <h3>🏢 Company Profile</h3>
                        <p>Update company information</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>