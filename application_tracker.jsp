<%@ page import="java.sql.*, java.util.*" %>
<%
    // Check if job seeker is logged in
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userType") == null || 
        !sess.getAttribute("userType").equals("jobseeker")) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (Integer) sess.getAttribute("userId");
    String userName = (String) sess.getAttribute("userName");

    // Get filter parameter
    String statusFilter = request.getParameter("status");
    if (statusFilter == null || statusFilter.isEmpty()) {
        statusFilter = "all";
    }

    // Database connection details
    String url = "jdbc:mysql://localhost:3306/jobportal";
    String dbUser = "root";
    String dbPass = "navya@2006";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    // Statistics variables
    int totalApplications = 0;
    int pendingApplications = 0;
    int acceptedApplications = 0;
    int rejectedApplications = 0;

    // List to store applications
    List<Map<String, Object>> applicationsList = new ArrayList<>();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Tracker | JobPortal</title>
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
            --danger: #dc3545;
            --info: #17a2b8;
            --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
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

        /* Stats Overview */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: var(--white);
            border-radius: 16px;
            padding: 1.8rem;
            box-shadow: var(--card-shadow);
            display: flex;
            align-items: center;
            gap: 1.2rem;
            transition: var(--transition);
            border-left: 4px solid var(--primary-color);
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
        }

        .stat-icon {
            width: 70px;
            height: 70px;
            border-radius: 16px;
            background: var(--primary-very-light);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 1.8rem;
        }

        .stat-info h3 {
            font-size: 2.2rem;
            font-weight: 800;
            color: var(--text-color);
            line-height: 1;
            margin-bottom: 0.3rem;
        }

        .stat-info p {
            color: var(--text-light);
            font-size: 0.95rem;
            font-weight: 500;
        }

        /* Filter Section */
        .filter-section {
            background: var(--white);
            padding: 1.8rem;
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            margin-bottom: 2rem;
        }

        .filter-title {
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 1.2rem;
            color: var(--text-color);
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
            gap: 0.8rem;
        }

        .filter-btn {
            padding: 0.8rem 1.5rem;
            background: var(--bg-color);
            border: 2px solid transparent;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            color: var(--text-light);
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .filter-btn:hover {
            border-color: var(--primary-color);
            color: var(--primary-color);
            transform: translateY(-2px);
        }

        .filter-btn.active {
            background: var(--primary-color);
            border-color: var(--primary-color);
            color: white;
        }

        /* Applications Container */
        .applications-container {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .application-card {
            background: var(--white);
            border-radius: 16px;
            padding: 0;
            box-shadow: var(--card-shadow);
            transition: var(--transition);
            border-left: 4px solid var(--primary-color);
            overflow: hidden;
        }

        .application-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
        }

        .application-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            padding: 1.8rem;
            cursor: pointer;
            border-bottom: 1px solid #f0f0f0;
        }

        .application-info {
            flex: 1;
        }

        .job-title {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 0.8rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .job-title i {
            color: var(--primary-color);
            font-size: 1.2rem;
        }

        .company-name {
            color: var(--text-light);
            font-size: 1.1rem;
            margin-bottom: 0.8rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .company-name i {
            color: var(--primary-color);
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
            gap: 1.2rem;
        }

        .status-badge {
            padding: 0.6rem 1.2rem;
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

        .toggle-details {
            background: var(--primary-very-light);
            color: var(--primary-color);
            border: none;
            padding: 0.7rem 1.2rem;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
        }

        .toggle-details:hover {
            background: var(--primary-color);
            color: white;
            transform: translateY(-2px);
        }

        /* Application Details */
        .application-details {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.5s ease;
        }

        .application-details.expanded {
            max-height: 1000px;
        }

        .details-section {
            background: var(--bg-color);
            padding: 1.8rem;
            margin-bottom: 0;
            border-bottom: 1px solid #f0f0f0;
        }

        .details-section:last-child {
            border-bottom: none;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 1.2rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title i {
            color: var(--primary-color);
        }

        .custom-fields {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.2rem;
        }

        .custom-field-item {
            background: var(--white);
            padding: 1.2rem;
            border-radius: 12px;
            border: 1px solid #f0f0f0;
            transition: var(--transition);
        }

        .custom-field-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        }

        .field-label {
            font-weight: 600;
            color: var(--text-color);
            margin-bottom: 0.8rem;
            font-size: 0.95rem;
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
            padding: 0.8rem;
            background: var(--white);
            border-radius: 8px;
            border-left: 3px solid var(--primary-color);
        }

        .status-timeline {
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 2px solid #f0f0f0;
        }

        .timeline-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 1.2rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .timeline-title i {
            color: var(--primary-color);
        }

        .timeline {
            position: relative;
            padding-left: 30px;
        }

        .timeline::before {
            content: '';
            position: absolute;
            left: 10px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: var(--primary-color);
        }

        .timeline-item {
            position: relative;
            margin-bottom: 1.5rem;
        }

        .timeline-item:last-child {
            margin-bottom: 0;
        }

        .timeline-item::before {
            content: '';
            position: absolute;
            left: -20px;
            top: 5px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: var(--primary-color);
        }

        .timeline-date {
            font-size: 0.85rem;
            color: var(--text-light);
            margin-bottom: 5px;
        }

        .timeline-content {
            font-size: 0.95rem;
            color: var(--text-color);
            font-weight: 500;
        }

        .no-applications {
            text-align: center;
            padding: 4rem 2rem;
            background: var(--white);
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            margin-top: 1rem;
        }

        .no-applications i {
            font-size: 4rem;
            margin-bottom: 1.5rem;
            color: var(--primary-very-light);
        }

        .no-applications h3 {
            font-size: 1.5rem;
            margin-bottom: 0.8rem;
            color: var(--text-color);
        }

        .no-applications p {
            font-size: 1rem;
            margin-bottom: 2rem;
            color: var(--text-light);
        }

        .btn {
            padding: 0.9rem 1.8rem;
            border-radius: 12px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            font-size: 0.95rem;
        }

        .btn-primary {
            background: var(--primary-color);
            color: var(--white);
            box-shadow: var(--card-shadow);
        }

        .btn-primary:hover {
            background: var(--primary-light);
            transform: translateY(-2px);
        }

        /* Responsive Design */
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
            
            .application-header {
                flex-direction: column;
                gap: 1.2rem;
            }
            
            .application-status {
                width: 100%;
                justify-content: space-between;
            }
            
            .custom-fields {
                grid-template-columns: 1fr;
            }
            
            .stats-container {
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
                <a href="application_tracker.jsp" class="menu-item active">
                    <i class="fas fa-chart-line"></i>
                    <span class="menu-text">Application Tracker</span>
                </a>
                <a href="portfolio.jsp" class="menu-item">
                    <i class="fas fa-folder-open"></i>
                    <span class="menu-text">Portfolio</span>
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
                    <%= userName != null ? userName.substring(0, 1).toUpperCase() : "J" %>
                </div>
                <div class="user-details">
                    <div class="user-name"><%= userName != null ? userName : "Job Seeker" %></div>
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
                <h1>Application Tracker</h1>
                <p>Monitor the status of all your job applications in one place</p>
            </div>
        </div>

        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, dbUser, dbPass);

                // Get statistics - updated to match your ENUM
                String statsSql = "SELECT " +
                    "COUNT(*) as total, " +
                    "SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as pending, " +
                    "SUM(CASE WHEN status = 'Accepted' THEN 1 ELSE 0 END) as accepted, " +
                    "SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END) as rejected " +
                    "FROM job_applications WHERE job_seeker_id = ?";
                
                stmt = conn.prepareStatement(statsSql);
                stmt.setInt(1, userId);
                rs = stmt.executeQuery();
                
                if (rs.next()) {
                    totalApplications = rs.getInt("total");
                    pendingApplications = rs.getInt("pending");
                    acceptedApplications = rs.getInt("accepted");
                    rejectedApplications = rs.getInt("rejected");
                }
                rs.close();
                stmt.close();

                // Get applications with filtering
                String appSql = "SELECT a.*, j.company_name " +
                               "FROM job_applications a " +
                               "JOIN jobs j ON a.job_id = j.id " +
                               "WHERE a.job_seeker_id = ? ";
                
                if (!"all".equals(statusFilter)) {
                    appSql += "AND a.status = ? ";
                }
                
                appSql += "ORDER BY a.application_date DESC";
                
                stmt = conn.prepareStatement(appSql);
                stmt.setInt(1, userId);
                if (!"all".equals(statusFilter)) {
                    stmt.setString(2, statusFilter);
                }
                
                rs = stmt.executeQuery();
                
                while (rs.next()) {
                    Map<String, Object> appData = new HashMap<>();
                    appData.put("id", rs.getInt("id"));
                    appData.put("job_title", rs.getString("job_title"));
                    appData.put("company_name", rs.getString("company_name"));
                    appData.put("application_date", rs.getDate("application_date"));
                    appData.put("status", rs.getString("status"));
                    appData.put("location", rs.getString("location"));
                    appData.put("job_type", rs.getString("job_type"));
                    
                    // Get custom fields
                    Map<String, String> customFields = new HashMap<>();
                    for (int i = 1; i <= 10; i++) {
                        String fieldName = rs.getString("custom_field" + i + "_name");
                        String fieldValue = rs.getString("custom_field" + i + "_value");
                        if (fieldName != null && fieldValue != null && !fieldValue.trim().isEmpty()) {
                            customFields.put(fieldName, fieldValue);
                        }
                    }
                    appData.put("custom_fields", customFields);
                    
                    applicationsList.add(appData);
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

        <!-- Stats Overview -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <div class="stat-info">
                    <h3><%= totalApplications %></h3>
                    <p>Total Applications</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-info">
                    <h3><%= pendingApplications %></h3>
                    <p>Pending Review</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-info">
                    <h3><%= acceptedApplications %></h3>
                    <p>Accepted</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-times-circle"></i>
                </div>
                <div class="stat-info">
                    <h3><%= rejectedApplications %></h3>
                    <p>Rejected</p>
                </div>
            </div>
        </div>

        <!-- Filter Section -->
        <div class="filter-section">
            <h3 class="filter-title">
                <i class="fas fa-filter"></i>
                Filter Applications
            </h3>
            <div class="filter-options">
                <a href="?status=all" class="filter-btn <%= "all".equals(statusFilter) ? "active" : "" %>">All Applications</a>
                <a href="?status=Pending" class="filter-btn <%= "Pending".equals(statusFilter) ? "active" : "" %>">Pending</a>
                <a href="?status=Accepted" class="filter-btn <%= "Accepted".equals(statusFilter) ? "active" : "" %>">Accepted</a>
                <a href="?status=Rejected" class="filter-btn <%= "Rejected".equals(statusFilter) ? "active" : "" %>">Rejected</a>
            </div>
        </div>

        <!-- Applications List -->
        <div class="applications-container">
            <% if (applicationsList.isEmpty()) { %>
                <div class="no-applications">
                    <i class="fas fa-file-alt"></i>
                    <h3>No Applications Found</h3>
                    <p>You haven't submitted any job applications yet, or no applications match your current filter criteria.</p>
                    <a href="job_recommendations.jsp" class="btn btn-primary">
                        <i class="fas fa-briefcase"></i> Browse Jobs
                    </a>
                </div>
            <% } else { 
                int applicationIndex = 0;
                for (Map<String, Object> app : applicationsList) {
                    applicationIndex++;
                    String status = (String) app.get("status");
                    Map<String, String> customFields = (Map<String, String>) app.get("custom_fields");
            %>
                    <div class="application-card" id="application-<%= applicationIndex %>">
                        <div class="application-header" onclick="toggleDetails(<%= applicationIndex %>)">
                            <div class="application-info">
                                <div class="job-title">
                                    <i class="fas fa-briefcase"></i>
                                    <%= app.get("job_title") %>
                                </div>
                                <div class="company-name">
                                    <i class="fas fa-building"></i>
                                    <%= app.get("company_name") %>
                                </div>
                                <div class="application-date">
                                    <i class="fas fa-calendar"></i>
                                    Applied on: <%= app.get("application_date") %>
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
                                    Application Details
                                </h3>
                                <div class="custom-fields">
                                    <div class="custom-field-item">
                                        <div class="field-label">
                                            <i class="fas fa-circle"></i>
                                            Job Title
                                        </div>
                                        <div class="field-value"><%= app.get("job_title") %></div>
                                    </div>
                                    <div class="custom-field-item">
                                        <div class="field-label">
                                            <i class="fas fa-circle"></i>
                                            Company
                                        </div>
                                        <div class="field-value"><%= app.get("company_name") %></div>
                                    </div>
                                    <div class="custom-field-item">
                                        <div class="field-label">
                                            <i class="fas fa-circle"></i>
                                            Location
                                        </div>
                                        <div class="field-value"><%= app.get("location") != null ? app.get("location") : "Not specified" %></div>
                                    </div>
                                    <div class="custom-field-item">
                                        <div class="field-label">
                                            <i class="fas fa-circle"></i>
                                            Job Type
                                        </div>
                                        <div class="field-value"><%= app.get("job_type") != null ? app.get("job_type") : "Not specified" %></div>
                                    </div>
                                    <div class="custom-field-item">
                                        <div class="field-label">
                                            <i class="fas fa-circle"></i>
                                            Application Date
                                        </div>
                                        <div class="field-value"><%= app.get("application_date") %></div>
                                    </div>
                                    <div class="custom-field-item">
                                        <div class="field-label">
                                            <i class="fas fa-circle"></i>
                                            Status
                                        </div>
                                        <div class="field-value"><%= status %></div>
                                    </div>
                                </div>
                            </div>
                            
                            <% if (!customFields.isEmpty()) { %>
                            <div class="details-section">
                                <h3 class="section-title">
                                    <i class="fas fa-list-alt"></i>
                                    Application Form Responses
                                </h3>
                                <div class="custom-fields">
                                    <% for (Map.Entry<String, String> field : customFields.entrySet()) { %>
                                        <div class="custom-field-item">
                                            <div class="field-label">
                                                <i class="fas fa-circle"></i>
                                                <%= field.getKey() %>
                                            </div>
                                            <div class="field-value"><%= field.getValue() %></div>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                            <% } %>
                            
                            <div class="details-section">
                                <div class="status-timeline">
                                    <h3 class="timeline-title">
                                        <i class="fas fa-history"></i>
                                        Application Timeline
                                    </h3>
                                    <div class="timeline">
                                        <div class="timeline-item">
                                            <div class="timeline-date"><%= app.get("application_date") %></div>
                                            <div class="timeline-content">Application submitted</div>
                                        </div>
                                        <div class="timeline-item">
                                            <div class="timeline-date">
                                                <% 
                                                    // Calculate review date (3 days after application)
                                                    java.sql.Date appDate = (java.sql.Date) app.get("application_date");
                                                    java.util.Calendar cal = java.util.Calendar.getInstance();
                                                    cal.setTime(appDate);
                                                    cal.add(java.util.Calendar.DATE, 3);
                                                    java.sql.Date reviewDate = new java.sql.Date(cal.getTimeInMillis());
                                                %>
                                                <%= reviewDate %>
                                            </div>
                                            <div class="timeline-content">Application under review</div>
                                        </div>
                                        <% if ("Accepted".equals(status)) { %>
                                        <div class="timeline-item">
                                            <div class="timeline-date">
                                                <% 
                                                    cal.add(java.util.Calendar.DATE, 2);
                                                    java.sql.Date acceptedDate = new java.sql.Date(cal.getTimeInMillis());
                                                %>
                                                <%= acceptedDate %>
                                            </div>
                                            <div class="timeline-content">Application accepted</div>
                                        </div>
                                        <% } %>
                                        <% if ("Rejected".equals(status)) { %>
                                        <div class="timeline-item">
                                            <div class="timeline-date">
                                                <% 
                                                    cal.add(java.util.Calendar.DATE, 5);
                                                    java.sql.Date rejectedDate = new java.sql.Date(cal.getTimeInMillis());
                                                %>
                                                <%= rejectedDate %>
                                            </div>
                                            <div class="timeline-content">Application rejected</div>
                                        </div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
            <% 
                } 
            } 
            %>
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
    </script>
</body>
</html>