<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%
    // Session check
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userType") == null || !sess.getAttribute("userType").equals("jobseeker")) {
        response.sendRedirect("login.jsp");
        return;
    }

    String jobSeekerName = (String) sess.getAttribute("userName");
    Integer userId = (Integer) sess.getAttribute("userId");
    if (jobSeekerName == null) jobSeekerName = "Job Seeker";
    if (userId == null) userId = 0;

    // Initialize variables
    String aboutMe = "";
    String currentPosition = "";
    String education = "";
    String contactEmail = "";
    String phone = "";
    String location = "";
    String linkedinUrl = "";
    String githubUrl = "";
    String websiteUrl = "";

    // Load portfolio data
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String dbUsername = "root";
        String dbPassword = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        // Load portfolio data
        String sql = "SELECT * FROM job_seeker_portfolios WHERE user_id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            aboutMe = rs.getString("about_me");
            currentPosition = rs.getString("current_position");
            education = rs.getString("education");
            contactEmail = rs.getString("contact_email");
            phone = rs.getString("phone");
            location = rs.getString("location");
            linkedinUrl = rs.getString("linkedin_url");
            githubUrl = rs.getString("github_url");
            websiteUrl = rs.getString("website_url");
        }
        
    } catch (Exception e) {
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

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Portfolio | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #FA976A;
            --primary-light: #ffc9b3;
            --primary-very-light: #fff5f0;
            --text-color: #2C3E50;
            --text-light: #6c7a89;
            --bg-color: #f8f9fa;
            --white: #ffffff;
            --border-color: #eaeaea;
            --sidebar-width: 280px;
            --sidebar-collapsed: 90px;
            --success: #28a745;
            --warning: #ffc107;
            --card-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            --transition: all 0.3s ease;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Inter", sans-serif;
        }

        body {
            background-color: var(--bg-color);
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* Sidebar */
        .sidebar {
            width: var(--sidebar-width);
            background: var(--white);
            color: var(--text-color);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 0;
            transition: width 0.3s ease;
            border-right: 1px solid var(--border-color);
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);
            position: relative;
        }

        .sidebar.collapsed {
            width: var(--sidebar-collapsed);
        }

        .sidebar-header {
            padding: 25px 20px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            font-size: 22px;
            font-weight: 800;
            color: var(--primary-color);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo i {
            font-size: 24px;
        }

        .logo-text {
            transition: opacity 0.3s ease;
        }

        .sidebar.collapsed .logo-text {
            opacity: 0;
            width: 0;
            overflow: hidden;
        }

        .toggle-btn {
            background: none;
            border: none;
            color: var(--text-light);
            cursor: pointer;
            font-size: 18px;
            padding: 5px;
            border-radius: 6px;
            transition: all 0.3s ease;
        }

        .toggle-btn:hover {
            background: var(--primary-very-light);
            color: var(--primary-color);
        }

        .sidebar.collapsed .toggle-btn {
            transform: rotate(180deg);
        }

        .menu {
            display: flex;
            flex-direction: column;
            padding: 20px 0;
            flex: 1;
        }

        .menu-item {
            display: flex;
            align-items: center;
            padding: 14px 20px;
            color: var(--text-color);
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            margin: 2px 15px;
            border-radius: 8px;
            gap: 12px;
        }

        .menu-item i {
            width: 20px;
            text-align: center;
            font-size: 18px;
            color: var(--text-light);
            transition: color 0.3s ease;
        }

        .menu-item:hover {
            background: var(--primary-very-light);
            color: var(--primary-color);
        }

        .menu-item:hover i {
            color: var(--primary-color);
        }

        .menu-item.active {
            background: var(--primary-very-light);
            color: var(--primary-color);
            font-weight: 600;
        }

        .menu-item.active i {
            color: var(--primary-color);
        }

        .menu-text {
            transition: opacity 0.3s ease;
        }

        .sidebar.collapsed .menu-text {
            opacity: 0;
            width: 0;
            overflow: hidden;
        }

        .sidebar-footer {
            padding: 20px;
            border-top: 1px solid var(--border-color);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
            padding: 10px;
            border-radius: 8px;
            transition: background 0.3s ease;
        }

        .user-info:hover {
            background: var(--primary-very-light);
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: var(--primary-color);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 16px;
        }

        .user-details {
            transition: opacity 0.3s ease;
        }

        .sidebar.collapsed .user-details {
            opacity: 0;
            width: 0;
            overflow: hidden;
        }

        .user-name {
            font-weight: 600;
            color: var(--text-color);
        }

        .user-role {
            font-size: 12px;
            color: var(--text-light);
        }

        .logout-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            width: 100%;
            padding: 12px 15px;
            background: var(--primary-very-light);
            color: var(--primary-color);
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .logout-btn:hover {
            background: var(--primary-color);
            color: white;
        }

        .logout-btn i {
            width: 20px;
            text-align: center;
        }

        .logout-text {
            transition: opacity 0.3s ease;
        }

        .sidebar.collapsed .logout-text {
            opacity: 0;
            width: 0;
            overflow: hidden;
        }

        /* Main Content */
        .main-content {
            flex: 1;
            padding: 30px 40px;
            overflow-y: auto;
            transition: margin-left 0.3s ease;
        }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .welcome-text h1 {
            font-size: 32px;
            color: var(--text-color);
            font-weight: 700;
            margin-bottom: 8px;
        }

        .welcome-text p {
            color: var(--text-light);
            font-size: 16px;
        }

        /* Form Section */
        .form-section {
            background: var(--white);
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: var(--card-shadow);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: var(--text-color);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: var(--text-color);
        }

        .form-control {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 1rem;
            transition: var(--transition);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
        }

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-primary {
            background: var(--primary-color);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-light);
        }

        .btn-secondary {
            background: transparent;
            color: var(--primary-color);
            border: 1px solid var(--primary-color);
        }

        .btn-secondary:hover {
            background: var(--primary-very-light);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        /* Scrollbar style */
        ::-webkit-scrollbar {
            width: 6px;
        }

        ::-webkit-scrollbar-thumb {
            background: #ddd;
            border-radius: 8px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #ccc;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .form-row {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                width: var(--sidebar-collapsed);
            }
            
            .sidebar:not(.collapsed) {
                width: var(--sidebar-width);
                z-index: 1000;
            }
            
            .main-content {
                padding: 20px;
            }
            
            .form-section {
                padding: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div>
            <div class="sidebar-header">
                <div class="logo">
                    <i class="fas fa-briefcase"></i>
                    <span class="logo-text">JobPortal.io</span>
                </div>
                <button class="toggle-btn" id="toggleSidebar">
                    <i class="fas fa-chevron-left"></i>
                </button>
            </div>
            
            <div class="menu">
                <a href="jobseek_dashboard.jsp" class="menu-item">
                    <i class="fas fa-home"></i>
                    <span class="menu-text">Overview</span>
                </a>
                <a href="job_recommendations.jsp" class="menu-item">
                    <i class="fas fa-briefcase"></i>
                    <span class="menu-text">Job Recommendations</span>
                </a>
                <a href="application_tracker.jsp" class="menu-item">
                    <i class="fas fa-chart-line"></i>
                    <span class="menu-text">Application Tracker</span>
                </a>
                <a href="portfolio.jsp" class="menu-item">
                    <i class="fas fa-folder-open"></i>
                    <span class="menu-text">View Portfolio</span>
                </a>
                <a href="portfolio_edit.jsp" class="menu-item active">
                    <i class="fas fa-edit"></i>
                    <span class="menu-text">Edit Portfolio</span>
                </a>
                <a href="portfolio_projects.jsp" class="menu-item">
                    <i class="fas fa-project-diagram"></i>
                    <span class="menu-text">Manage Projects</span>
                </a>
                <a href="portfolio_skills.jsp" class="menu-item">
                    <i class="fas fa-code"></i>
                    <span class="menu-text">Manage Skills</span>
                </a>
                <a href="profile_settings.jsp" class="menu-item">
                    <i class="fas fa-cog"></i>
                    <span class="menu-text">Settings</span>
                </a>
            </div>
        </div>
        
        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar">
                    <%= jobSeekerName != null ? jobSeekerName.substring(0, 1).toUpperCase() : "J" %>
                </div>
                <div class="user-details">
                    <div class="user-name"><%= jobSeekerName != null ? jobSeekerName : "Job Seeker" %></div>
                    <div class="user-role">Job Seeker</div>
                </div>
            </div>
            <a href="logout.jsp" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i>
                <span class="logout-text">Logout</span>
            </a>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="top-bar">
            <div class="welcome-text">
                <h1>Edit Your Portfolio</h1>
                <p>Update your professional information to showcase your skills and experience</p>
            </div>
        </div>

        <div class="form-section">
            <h2 class="section-title">
                <i class="fas fa-user-edit"></i> Portfolio Information
            </h2>
            
            <form action="portfolio_save.jsp" method="post">
                <!-- Basic Information -->
                <div class="form-group">
                    <label for="aboutMe">About Me</label>
                    <textarea id="aboutMe" name="aboutMe" class="form-control" placeholder="Tell us about yourself, your passion, and what drives you..."><%= aboutMe != null ? aboutMe : "" %></textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="currentPosition">Current Position</label>
                        <input type="text" id="currentPosition" name="currentPosition" class="form-control" 
                               value="<%= currentPosition != null ? currentPosition : "" %>" placeholder="e.g., Senior Frontend Developer">
                    </div>
                    
                    <div class="form-group">
                        <label for="location">Location</label>
                        <input type="text" id="location" name="location" class="form-control" 
                               value="<%= location != null ? location : "" %>" placeholder="e.g., San Francisco, CA">
                    </div>
                </div>

                <div class="form-group">
                    <label for="education">Education</label>
                    <textarea id="education" name="education" class="form-control" placeholder="Your educational background..."><%= education != null ? education : "" %></textarea>
                </div>

                <!-- Contact Information -->
                <h3 style="margin: 2rem 0 1rem 0; color: var(--text-color);">Contact Information</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="contactEmail">Email</label>
                        <input type="email" id="contactEmail" name="contactEmail" class="form-control" 
                               value="<%= contactEmail != null ? contactEmail : "" %>" placeholder="your.email@example.com">
                    </div>
                    
                    <div class="form-group">
                        <label for="phone">Phone</label>
                        <input type="tel" id="phone" name="phone" class="form-control" 
                               value="<%= phone != null ? phone : "" %>" placeholder="+1 (555) 123-4567">
                    </div>
                </div>

                <!-- Social Links -->
                <h3 style="margin: 2rem 0 1rem 0; color: var(--text-color);">Social Links</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="linkedinUrl">LinkedIn URL</label>
                        <input type="url" id="linkedinUrl" name="linkedinUrl" class="form-control" 
                               value="<%= linkedinUrl != null ? linkedinUrl : "" %>" placeholder="https://linkedin.com/in/yourprofile">
                    </div>
                    
                    <div class="form-group">
                        <label for="githubUrl">GitHub URL</label>
                        <input type="url" id="githubUrl" name="githubUrl" class="form-control" 
                               value="<%= githubUrl != null ? githubUrl : "" %>" placeholder="https://github.com/yourusername">
                    </div>
                </div>

                <div class="form-group">
                    <label for="websiteUrl">Personal Website/Blog</label>
                    <input type="url" id="websiteUrl" name="websiteUrl" class="form-control" 
                           value="<%= websiteUrl != null ? websiteUrl : "" %>" placeholder="https://yourwebsite.com">
                </div>

                <!-- Action Buttons -->
                <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Save Portfolio
                    </button>
                    <a href="portfolio.jsp" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Sidebar toggle functionality
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
        });

        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function(event) {
            const sidebar = document.getElementById('sidebar');
            const toggleBtn = document.getElementById('toggleSidebar');
            
            if (window.innerWidth <= 768 && 
                !sidebar.contains(event.target) && 
                !sidebar.classList.contains('collapsed')) {
                sidebar.classList.add('collapsed');
            }
        });

        // Simple form validation
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.querySelector('form');
            
            form.addEventListener('submit', function(e) {
                const aboutMe = document.getElementById('aboutMe').value.trim();
                const currentPosition = document.getElementById('currentPosition').value.trim();
                
                if (!aboutMe) {
                    e.preventDefault();
                    alert('Please fill in the About Me section');
                    document.getElementById('aboutMe').focus();
                    return;
                }
                
                if (!currentPosition) {
                    e.preventDefault();
                    alert('Please enter your current position');
                    document.getElementById('currentPosition').focus();
                    return;
                }
            });
        });
    </script>
</body>
</html>