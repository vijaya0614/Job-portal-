<%@ page import="java.sql.*, java.util.*" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userType = (String) session.getAttribute("userType");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userName == null || !"recruiter".equals(userType)) {
%>
        <script>window.location.href = "login.jsp";</script>
<%
        return;
    }

    int jobCount = 0;
    int appCount = 0;
    int activeJobs = 0;

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String username = "root";
        String dbPassword = "navya@2006";
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, dbPassword);

        String jobCountSql = "SELECT COUNT(*) as job_count FROM jobs WHERE recruiter_id = ?";
        stmt = conn.prepareStatement(jobCountSql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (rs.next()) jobCount = rs.getInt("job_count");

        String appCountSql = "SELECT COUNT(*) as app_count FROM job_applications ja JOIN jobs j ON ja.job_id = j.id WHERE j.recruiter_id = ?";
        stmt = conn.prepareStatement(appCountSql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (rs.next()) appCount = rs.getInt("app_count");

        String activeJobsSql = "SELECT COUNT(*) as active_jobs FROM jobs WHERE recruiter_id = ? AND status = 'active'";
        stmt = conn.prepareStatement(activeJobsSql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        if (rs.next()) activeJobs = rs.getInt("active_jobs");
    } catch (Exception e) {
        // keep default 0
    } finally {
        try { if (rs != null) rs.close(); if (stmt != null) stmt.close(); if (conn != null) conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Recruiter Dashboard | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
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

        /* Quote Section */
        .quote-section {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-light) 100%);
            color: white;
            padding: 30px;
            border-radius: 16px;
            margin-bottom: 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .quote-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url("data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm63 31c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM34 90c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm56-76c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 63c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm57-13c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-9-21c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM60 91c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM35 41c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 60c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z' fill='%23ffffff' fill-opacity='0.1' fill-rule='evenodd'/%3E%3C/svg%3E");
            opacity: 0.3;
        }

        .quote-icon {
            font-size: 36px;
            margin-bottom: 15px;
            opacity: 0.9;
        }

        .quote-text {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 10px;
            line-height: 1.4;
        }

        .quote-author {
            font-size: 14px;
            opacity: 0.9;
            font-style: italic;
        }

        /* Stats Section - New Design */
        .stats-section {
            margin-bottom: 40px;
        }

        .section-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 25px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
        }

        .stat-card {
            background: var(--white);
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s, box-shadow 0.3s;
            border: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }

        .stat-icon {
            width: 70px;
            height: 70px;
            background: var(--primary-very-light);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 28px;
        }

        .stat-content {
            flex: 1;
        }

        .stat-content h3 {
            color: var(--text-light);
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .count {
            font-size: 36px;
            font-weight: 800;
            color: var(--primary-color);
            line-height: 1;
            margin-bottom: 5px;
        }

        .stat-trend {
            font-size: 14px;
            color: var(--text-light);
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .stat-trend.positive {
            color: #10b981;
        }

        .stat-trend.negative {
            color: #ef4444;
        }

        /* Actions Section */
        .actions-section {
            margin-bottom: 40px;
        }

        .actions-grid {
            display: grid;
            grid-template-columns: repeat(4,1fr);
            gap: 25px;
        }

        .action-card {
            background: var(--white);
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            text-decoration: none;
            color: inherit;
            transition: transform 0.3s, box-shadow 0.3s;
            border: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
             min-height: 200px;
        }

        .action-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            border-color: var(--primary-light);
        }

        .action-icon {
            width: 50px;
            height: 60px;
            background: var(--primary-very-light);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            color: var(--primary-color);
            font-size: 24px;
        }

        .action-card h3 {
            color: var(--text-color);
            margin-bottom: 12px;
            font-size: 18px;
            font-weight: 600;
        }

        .action-card p {
            color: var(--text-light);
            font-size: 14px;
            line-height: 1.5;
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
            
            .stats-grid,
            .actions-grid {
                grid-template-columns: 1fr;
            }
            
            .stat-card {
                flex-direction: column;
                text-align: center;
                gap: 15px;
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
                    <span class="logo-text">JobPortal</span>
                </div>
                <button class="toggle-btn" id="toggleSidebar">
                    <i class="fas fa-chevron-left"></i>
                </button>
            </div>
            
            <div class="menu">
                <a href="recruiter_dashboard.jsp" class="menu-item active">
                    <i class="fas fa-home"></i>
                    <span class="menu-text">Dashboard</span>
                </a>
                <a href="post_job.jsp" class="menu-item">
                    <i class="fas fa-plus-circle"></i>
                    <span class="menu-text">Post Job</span>
                </a>
                <a href="my_jobs.jsp" class="menu-item">
                    <i class="fas fa-briefcase"></i>
                    <span class="menu-text">My Jobs</span>
                </a>
                <a href="view_applications.jsp" class="menu-item">
                    <i class="fas fa-file-alt"></i>
                    <span class="menu-text">Applications</span>
                </a>
                <a href="company_profile.jsp" class="menu-item">
                    <i class="fas fa-building"></i>
                    <span class="menu-text">Company Profile</span>
                </a>
                
            </div>
        </div>
        
        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar">
                    <%= userName != null ? userName.substring(0, 1).toUpperCase() : "R" %>
                </div>
                <div class="user-details">
                    <div class="user-name"><%= userName %></div>
                    <div class="user-role">Recruiter</div>
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
                <h1>Welcome back, <%= userName %></h1>
                <p>Here's an overview of your recruitment activities</p>
            </div>
        </div>

        <!-- Quote Section -->
        <div class="quote-section">
            <div class="quote-icon">
                <i class="fas fa-quote-left"></i>
            </div>
            <div class="quote-text">
                "One great hire can change the trajectory of your entire organization."
            </div>
            <div class="quote-author"></div>
        </div>

        <!-- Stats Section -->
        <div class="stats-section">
            <h2 class="section-title">Recruitment Overview</h2>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-briefcase"></i>
                    </div>
                    <div class="stat-content">
                        <h3>Total Jobs Posted</h3>
                        <div class="count"><%= jobCount %></div>
                        <div class="stat-trend positive">
                            <i class="fas fa-arrow-up"></i>
                            <span>Active recruitment</span>
                        </div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-play-circle"></i>
                    </div>
                    <div class="stat-content">
                        <h3>Active Jobs</h3>
                        <div class="count"><%= activeJobs %></div>
                        <div class="stat-trend">
                            <span>Currently hiring</span>
                        </div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-content">
                        <h3>Applications Received</h3>
                        <div class="count"><%= appCount %></div>
                        <div class="stat-trend positive">
                            <i class="fas fa-arrow-up"></i>
                            <span>Growing interest</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Actions Section -->
        <div class="actions-section">
            <h2 class="section-title">Quick Actions</h2>
            <div class="actions-grid">
                <a href="post_job.jsp" class="action-card">
                    <div class="action-icon">
                        <i class="fas fa-plus"></i>
                    </div>
                    <h3>Post New Job</h3>
                    <p>Create a new job posting to attract qualified candidates</p>
                </a>
                <a href="my_jobs.jsp" class="action-card">
                    <div class="action-icon">
                        <i class="fas fa-briefcase"></i>
                    </div>
                    <h3>Manage Jobs</h3>
                    <p>View, edit, and manage your existing job postings</p>
                </a>
                <a href="view_applications.jsp" class="action-card">
                    <div class="action-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3>View Applications</h3>
                    <p>Review candidate applications and profiles</p>
                </a>
                <a href="company_profile.jsp" class="action-card">
                    <div class="action-icon">
                        <i class="fas fa-building"></i>
                    </div>
                    <h3>Company Profile</h3>
                    <p>Update your company information and settings</p>
                </a>
            </div>
        </div>
    </div>

    <script>
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
    </script>

</body>
</html>