<%@ page import="java.sql.*, java.util.*" %>
<%
    // Check if recruiter is logged in
    String userName = (String) session.getAttribute("userName");
    String userType = (String) session.getAttribute("userType");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userName == null || !"recruiter".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String jobIdParam = request.getParameter("job_id");
    if (jobIdParam == null) {
        response.sendRedirect("my_jobs.jsp");
        return;
    }
    int jobId = Integer.parseInt(jobIdParam);
    
    // Get filter parameter
    String statusFilter = request.getParameter("status");
    if (statusFilter == null || statusFilter.isEmpty()) {
        statusFilter = "all";
    }
    
    // Get job details
    String jobTitle = "";
    String companyName = "";
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String dbUsername = "root";
        String dbPassword = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        String jobSql = "SELECT job_title, company_name FROM jobs WHERE id = ? AND recruiter_id = ?";
        stmt = conn.prepareStatement(jobSql);
        stmt.setInt(1, jobId);
        stmt.setInt(2, userId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            jobTitle = rs.getString("job_title");
            companyName = rs.getString("company_name");
        } else {
            response.sendRedirect("my_jobs.jsp");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Applications for <%= jobTitle %> | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #FA976A;
            --primary-light: #FFE8E0;
            --primary-very-light: #FFF5F2;
            --text-color: #2C3E50;
            --text-light: #6c7a89;
            --bg-color: #f8f9fa;
            --white: #ffffff;
            --border-color: #e1e5eb;
            --sidebar-width: 280px;
            --sidebar-collapsed: 90px;
            --success-color: #28a745;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --info-color: #17a2b8;
            --review-color: #8b5cf6;
            --card-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
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
            min-height: 100vh;
            overflow-x: hidden;
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
            position: fixed;
            height: 100vh;
            z-index: 1000;
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
            background: var(--primary-light);
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
            background: var(--primary-light);
            color: var(--primary-color);
        }

        .menu-item:hover i {
            color: var(--primary-color);
        }

        .menu-item.active {
            background: var(--primary-light);
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
            background: var(--primary-light);
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
            background: var(--primary-light);
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
            margin-left: var(--sidebar-width);
            transition: margin-left 0.3s ease;
            min-height: 100vh;
        }

        .sidebar.collapsed ~ .main-content {
            margin-left: var(--sidebar-collapsed);
        }

        .page-header {
            margin-bottom: 40px;
            text-align: center;
        }

        .page-header h1 {
            font-size: 2.2rem;
            color: var(--text-color);
            font-weight: 700;
            margin-bottom: 8px;
        }

        .page-header p {
            color: var(--text-light);
            font-size: 1rem;
            margin-bottom: 20px;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            background: var(--text-light);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
            margin-top: 10px;
        }

        .back-btn:hover {
            background: #5a6268;
            transform: translateY(-2px);
        }

        /* Stats Overview */
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
            max-width: 1200px;
            margin-left: auto;
            margin-right: auto;
        }

        .stat-item {
            background: var(--white);
            padding: 25px;
            border-radius: 12px;
            text-align: center;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--border-color);
            transition: transform 0.3s ease;
        }

        .stat-item:hover {
            transform: translateY(-5px);
        }

        .stat-icon {
            font-size: 2rem;
            color: var(--primary-color);
            margin-bottom: 15px;
        }

        .stat-number {
            font-size: 2.2rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 5px;
        }

        .stat-label {
            color: var(--text-light);
            font-size: 0.9rem;
            font-weight: 500;
        }

        /* Filter Section */
        .filter-section {
            background: var(--white);
            padding: 25px;
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            margin-bottom: 30px;
            max-width: 1400px;
            margin-left: auto;
            margin-right: auto;
        }

        .filter-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .filter-title i {
            color: var(--primary-color);
        }

        .filter-options {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .filter-btn {
            padding: 10px 20px;
            background: var(--bg-color);
            border: 2px solid var(--border-color);
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            color: var(--text-light);
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .filter-btn:hover {
            border-color: var(--primary-color);
            color: var(--primary-color);
        }

        .filter-btn.active {
            background: var(--primary-color);
            border-color: var(--primary-color);
            color: white;
        }

        /* Applications List */
        .applications-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .application-card {
            background: var(--white);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--border-color);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .application-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
            border-color: var(--primary-light);
        }

        .application-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
            cursor: pointer;
        }

        .applicant-info {
            flex: 1;
        }

        .applicant-name {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .applicant-name i {
            color: var(--primary-color);
            font-size: 1.1rem;
        }

        .application-date {
            color: var(--text-light);
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .application-date i {
            color: var(--primary-color);
        }

        .application-status {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-pending {
            background: #fef3c7;
            color: #d97706;
            border: 1px solid #fcd34d;
        }

        .status-accepted {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #34d399;
        }

        .status-rejected {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #f87171;
        }

        .status-marked-for-review {
            background: #f3e8ff;
            color: #7c3aed;
            border: 1px solid #a78bfa;
        }

        .toggle-details {
            background: var(--primary-light);
            color: var(--primary-color);
            border: none;
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .toggle-details:hover {
            background: var(--primary-color);
            color: white;
        }

        /* Application Details - Hidden by default */
        .application-details {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.5s ease;
            margin-top: 0;
        }

        .application-details.expanded {
            max-height: 1000px;
            margin-top: 25px;
        }

        .details-section {
            background: var(--primary-very-light);
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 20px;
        }

        .section-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title i {
            color: var(--primary-color);
        }

        .custom-fields {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 15px;
        }

        .custom-field-item {
            background: var(--white);
            padding: 20px;
            border-radius: 10px;
            border: 1px solid var(--border-color);
            transition: all 0.3s ease;
        }

        .custom-field-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .field-label {
            font-weight: 600;
            color: var(--text-color);
            margin-bottom: 8px;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .field-label i {
            color: var(--primary-color);
            font-size: 0.8rem;
        }

        .field-value {
            color: var(--text-light);
            font-size: 0.95rem;
            line-height: 1.5;
            padding: 10px;
            background: var(--bg-color);
            border-radius: 8px;
            border-left: 3px solid var(--primary-color);
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: flex-end;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 2px solid var(--border-color);
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            font-size: 0.9rem;
        }

        .btn-accept {
            background: var(--success-color);
            color: white;
        }

        .btn-accept:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(40, 167, 69, 0.4);
        }

        .btn-reject {
            background: var(--danger-color);
            color: white;
        }

        .btn-reject:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(220, 53, 69, 0.4);
        }

        .btn-review {
            background: var(--review-color);
            color: white;
        }

        .btn-review:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4);
        }

        .no-applications {
            text-align: center;
            padding: 60px 20px;
            color: var(--text-light);
            background: var(--white);
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            margin-top: 30px;
        }

        .no-applications i {
            font-size: 3rem;
            margin-bottom: 20px;
            color: var(--primary-light);
        }

        .no-applications h3 {
            font-size: 1.4rem;
            margin-bottom: 10px;
            color: var(--text-color);
        }

        .no-applications p {
            font-size: 0.95rem;
            margin-bottom: 30px;
        }
        .btn-portfolio {
    background: var(--info-color);
    color: white;
}

.btn-portfolio:hover {
    background: #138496;
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(23, 162, 184, 0.4);
}

        /* Responsive */
        @media (max-width: 768px) {
            .sidebar {
                width: var(--sidebar-collapsed);
            }
            
            .sidebar:not(.collapsed) {
                width: var(--sidebar-width);
            }
            
            .main-content {
                padding: 20px;
                margin-left: var(--sidebar-collapsed);
            }
            
            .sidebar:not(.collapsed) ~ .main-content {
                margin-left: var(--sidebar-width);
            }
            
            .application-header {
                flex-direction: column;
                gap: 15px;
            }
            
            .application-status {
                width: 100%;
                justify-content: space-between;
            }
            
            .action-buttons {
                justify-content: center;
                flex-wrap: wrap;
            }
            
            .btn {
                padding: 8px 16px;
                font-size: 0.85rem;
            }
            
            .custom-fields {
                grid-template-columns: 1fr;
            }
            
            .filter-options {
                justify-content: center;
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
                <a href="recruiter_dashboard.jsp" class="menu-item">
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
                <a href="view_applications.jsp" class="menu-item active">
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
        <div class="page-header">
            <h1>Applications for <span style="color: var(--primary-color);"><%= jobTitle %></span></h1>
            <p><i class="fas fa-building"></i> <%= companyName %> - Manage applications for this position</p>
            
        </div>

        <%
            try {
                // Reset connection and statement
                if (stmt != null) stmt.close();
                if (rs != null) rs.close();
                
                // Get total applications count
                String totalAppsSql = "SELECT COUNT(*) as total FROM job_applications WHERE job_id = ?";
                stmt = conn.prepareStatement(totalAppsSql);
                stmt.setInt(1, jobId);
                rs = stmt.executeQuery();
                int totalApplications = 0;
                if (rs.next()) totalApplications = rs.getInt("total");
                
                // Get pending applications count
                String pendingAppsSql = "SELECT COUNT(*) as pending FROM job_applications WHERE job_id = ? AND status = 'Pending'";
                stmt = conn.prepareStatement(pendingAppsSql);
                stmt.setInt(1, jobId);
                rs = stmt.executeQuery();
                int pendingApplications = 0;
                if (rs.next()) pendingApplications = rs.getInt("pending");
                
                // Get marked for review applications count
                String reviewAppsSql = "SELECT COUNT(*) as review FROM job_applications WHERE job_id = ? AND status = 'Marked for Review'";
                stmt = conn.prepareStatement(reviewAppsSql);
                stmt.setInt(1, jobId);
                rs = stmt.executeQuery();
                int reviewApplications = 0;
                if (rs.next()) reviewApplications = rs.getInt("review");
        %>

        <!-- Stats Overview -->
        <div class="stats-overview">
            <div class="stat-item">
                <div class="stat-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <div class="stat-number"><%= totalApplications %></div>
                <div class="stat-label">Total Applications</div>
            </div>
            <div class="stat-item">
                <div class="stat-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-number"><%= pendingApplications %></div>
                <div class="stat-label">Pending Review</div>
            </div>
            <div class="stat-item">
                <div class="stat-icon">
                    <i class="fas fa-flag"></i>
                </div>
                <div class="stat-number"><%= reviewApplications %></div>
                <div class="stat-label">Marked for Review</div>
            </div>
        </div>

        <!-- Filter Section -->
        <div class="filter-section">
            <h3 class="filter-title">
                <i class="fas fa-filter"></i>
                Filter Applications
            </h3>
            <div class="filter-options">
                <a href="?job_id=<%= jobId %>&status=all" class="filter-btn <%= "all".equals(statusFilter) ? "active" : "" %>">
                    All
                </a>
                <a href="?job_id=<%= jobId %>&status=Pending" class="filter-btn <%= "Pending".equals(statusFilter) ? "active" : "" %>">
                  </i> Pending
                </a>
                <a href="?job_id=<%= jobId %>&status=Accepted" class="filter-btn <%= "Accepted".equals(statusFilter) ? "active" : "" %>">
                   Accepted
                </a>
                <a href="?job_id=<%= jobId %>&status=Rejected" class="filter-btn <%= "Rejected".equals(statusFilter) ? "active" : "" %>">
                    Rejected
                </a>
                <a href="?job_id=<%= jobId %>&status=Marked for Review" class="filter-btn <%= "Marked for Review".equals(statusFilter) ? "active" : "" %>">
                     Marked for Review
                </a>
            </div>
        </div>

        <div class="applications-container">
            <%
                // Get applications for this job with filter
                String appSql = "SELECT a.*, js.full_name as seeker_name " +
                               "FROM job_applications a " +
                               "JOIN job_seekers js ON a.job_seeker_id = js.id " +
                               "WHERE a.job_id = ? ";
                
                if (!"all".equals(statusFilter)) {
                    appSql += "AND a.status = ? ";
                }
                
                appSql += "ORDER BY a.application_date DESC";
                
                stmt = conn.prepareStatement(appSql);
                stmt.setInt(1, jobId);
                if (!"all".equals(statusFilter)) {
                    stmt.setString(2, statusFilter);
                }
                
                rs = stmt.executeQuery();
                
                boolean hasApplications = false;
                int applicationIndex = 0;
                
                while (rs.next()) {
                    hasApplications = true;
                    applicationIndex++;
                    int applicationId = rs.getInt("id");
                    String seekerName = rs.getString("seeker_name");
                    java.sql.Date appDate = rs.getDate("application_date");
                    String status = rs.getString("status");
            %>
                    <div class="application-card" id="application-<%= applicationIndex %>">
                        <div class="application-header" onclick="toggleDetails(<%= applicationIndex %>)">
                            <div class="applicant-info">
                                <div class="applicant-name">
                                    <i class="fas fa-user"></i>
                                    <%= seekerName %>
                                </div>
                                <div class="application-date">
                                    <i class="fas fa-calendar"></i>
                                    Applied on: <%= appDate %>
                                </div>
                            </div>
                            <div class="application-status">
                                <div class="status-badge status-<%= status.toLowerCase().replace(" ", "-") %>">
                                    <%= status %>
                                </div>
                                <button class="toggle-details" onclick="event.stopPropagation(); toggleDetails(<%= applicationIndex %>)">
                                    <i class="fas fa-chevron-down"></i>
                                    <span>Show Details</span>
                                </button>
                            </div>
                        </div>
                        
                        <!-- Application Details - Hidden by default -->
                        <div class="application-details" id="details-<%= applicationIndex %>">
                            <div class="details-section">
                                <h3 class="section-title">
                                    <i class="fas fa-list-alt"></i>
                                    Application Form Responses
                                </h3>
                                <div class="custom-fields">
                                    <%
                                        // Display custom fields that have values
                                        for(int i = 1; i <= 10; i++) {
                                            String fieldName = rs.getString("custom_field" + i + "_name");
                                            String fieldValue = rs.getString("custom_field" + i + "_value");
                                            
                                            if (fieldName != null && fieldValue != null && !fieldValue.trim().isEmpty()) {
                                    %>
                                                <div class="custom-field-item">
                                                    <div class="field-label">
                                                        <i class="fas fa-circle"></i>
                                                        <%= fieldName %>
                                                    </div>
                                                    <div class="field-value"><%= fieldValue %></div>
                                                </div>
                                    <%
                                            }
                                        }
                                    %>
                                </div>
                            </div>
                            
                            <!-- Action Buttons -->
                            <!-- Action Buttons -->
<% if ("Pending".equals(status) || "Marked for Review".equals(status)) { %>
<div class="action-buttons">
    <!-- Add this new button for viewing portfolio -->
    <a href="view_candidate_portfolio.jsp?job_seeker_id=<%= rs.getInt("job_seeker_id") %>&application_id=<%= applicationId %>&job_id=<%= jobId %>"
   class="btn btn-portfolio"
   onclick="openPortfolioModal(event, this.href)">

        <i class="fas fa-eye"></i> View Portfolio
    </a>
    
    <form action="update_application_status.jsp" method="post" style="display: inline;">
        <input type="hidden" name="application_id" value="<%= applicationId %>">
        <input type="hidden" name="status" value="Accepted">
        <input type="hidden" name="job_id" value="<%= jobId %>">
        <button type="submit" class="btn btn-accept">
            <i class="fas fa-check"></i> Accept Application
        </button>
    </form>
    <form action="update_application_status.jsp" method="post" style="display: inline;">
        <input type="hidden" name="application_id" value="<%= applicationId %>">
        <input type="hidden" name="status" value="Marked for Review">
        <input type="hidden" name="job_id" value="<%= jobId %>">
        <button type="submit" class="btn btn-review">
            <i class="fas fa-flag"></i> Mark for Review
        </button>
    </form>
    <form action="update_application_status.jsp" method="post" style="display: inline;">
        <input type="hidden" name="application_id" value="<%= applicationId %>">
        <input type="hidden" name="status" value="Rejected">
        <input type="hidden" name="job_id" value="<%= jobId %>">
        <button type="submit" class="btn btn-reject">
            <i class="fas fa-times"></i> Reject Application
        </button>
    </form>
</div>
<% } else { %>
<!-- Show portfolio button even for non-pending applications -->
<div class="action-buttons">
    <a href="view_candidate_portfolio.jsp?job_seeker_id=<%= rs.getInt("job_seeker_id") %>&application_id=<%= applicationId %>&job_id=<%= jobId %>"
   class="btn btn-portfolio"
   onclick="openPortfolioModal(event, this.href)">
    <i class="fas fa-eye"></i> View Portfolio
</a>

</div>
<% } %>
                        </div>
                    </div>
            <%
                }
                
                if (!hasApplications) {
            %>
                    <div class="no-applications">
                        <i class="fas fa-file-alt"></i>
                        <h3>No Applications Found</h3>
                        <p>No applications match your current filter criteria.</p>
                    </div>
            <%
                }
                
            } catch (Exception e) {
                e.printStackTrace();
            %>
                <div class="no-applications">
                    <i class="fas fa-exclamation-triangle"></i>
                    <h3>Error Loading Applications</h3>
                    <p>Please try again later</p>
                </div>
            <%
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
        </div>
    </div>

    <script>
        // Sidebar toggle
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
        });

        // Toggle application details
        function toggleDetails(index) {
            const details = document.getElementById('details-' + index);
            const toggleBtn = document.querySelector('#application-' + index + ' .toggle-details');
            const icon = toggleBtn.querySelector('i');
            const text = toggleBtn.querySelector('span');
            
            details.classList.toggle('expanded');
            
            if (details.classList.contains('expanded')) {
                icon.className = 'fas fa-chevron-up';
                text.textContent = 'Hide Details';
            } else {
                icon.className = 'fas fa-chevron-down';
                text.textContent = 'Show Details';
            }
        }

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
         function openPortfolioModal(event, url) {
        event.preventDefault();
        document.getElementById("portfolioFrame").src = url;
        document.getElementById("portfolioModal").style.display = "flex";
    }

    function closePortfolioModal() {
        document.getElementById("portfolioModal").style.display = "none";
        document.getElementById("portfolioFrame").src = "";
    }
    </script>
    <!-- Portfolio Modal -->
    <!-- Portfolio Modal -->
<div id="portfolioModal" class="modal-overlay">
    <div class="modal-box">
        <div class="modal-header">
            <h2 class="modal-title"><i class="fas fa-id-card"></i> Candidate Portfolio</h2>
            <span class="close-btn" onclick="closePortfolioModal()">&times;</span>
        </div>

        <iframe id="portfolioFrame" class="modal-iframe"></iframe>
    </div>
</div>


<style>
/* Modal Background Overlay */
.modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.6);
    backdrop-filter: blur(3px);
    z-index: 9999;
    justify-content: center;
    align-items: center;
    padding: 20px;
}

/* Main Modal Box */
.modal-box {
    width: 95%;
    max-width: 1150px;
    background: #ffffff;
    border-radius: 14px;
    overflow: hidden;
    box-shadow: 0 12px 40px rgba(250, 151, 106, 0.4);
    animation: modalFade 0.3s ease-out;
    border: 2px solid #FA976A22;
}

/* Modal Header */
.modal-header {
    background: linear-gradient(135deg, #FA976A, #e28758);
    padding: 15px 20px;
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-title {
    margin: 0;
    font-size: 1.4rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 10px;
}

.modal-title i {
    font-size: 1.3rem;
}

/* Close Button */
.close-btn {
    cursor: pointer;
    font-size: 32px;
    padding: 0 10px;
    line-height: 1;
    transition: 0.3s ease;
}

.close-btn:hover {
    color: #ffe4d3;
    transform: scale(1.15);
}

/* Iframe Styling */
.modal-iframe {
    width: 100%;
    height: 85vh;
    border: none;
    background: #fff;
}

/* Animation */
@keyframes modalFade {
    from { transform: translateY(-25px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}



</style>

</body>
</html>
