<%@ page import="java.sql.*" %>
<%
    // Check if recruiter is logged in
    String userName = (String) session.getAttribute("userName");
    String userType = (String) session.getAttribute("userType");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userName == null || !"recruiter".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Jobs | JobPortal</title>
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
            --info-color: #17a2b8;
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
        }

        /* Stats Overview */
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
            max-width: 1000px;
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

        /* Jobs List - Single Column */
        .jobs-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .job-card {
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

        .job-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
            border-color: var(--primary-light);
        }

        .job-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 16px;
        }

        .job-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 6px;
        }

        .company-name {
            color: var(--text-light);
            font-weight: 500;
            font-size: 1rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .company-name i {
            font-size: 0.9rem;
            color: var(--primary-color);
        }

        .applications-count {
            background: var(--primary-light);
            color: var(--primary-color);
            padding: 6px 14px;
            border-radius: 16px;
            font-size: 0.85rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .job-meta {
            display: flex;
            gap: 20px;
            margin: 16px 0;
            flex-wrap: wrap;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-light);
            font-size: 0.9rem;
            background: var(--bg-color);
            padding: 6px 14px;
            border-radius: 10px;
        }

        .meta-item i {
            color: var(--primary-color);
            font-size: 0.9rem;
        }

        .job-description {
            color: var(--text-light);
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 20px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .job-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 20px;
            padding-top: 18px;
            border-top: 1px solid var(--border-color);
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
            gap: 6px;
            transition: all 0.3s ease;
            font-size: 0.9rem;
        }

        .btn-primary {
            background: var(--primary-color);
            color: white;
            box-shadow: 0 2px 8px rgba(255, 107, 53, 0.2);
        }

        .btn-primary:hover {
            background: #E55A2B;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
        }

        .btn-secondary {
            background: var(--text-light);
            color: white;
        }

        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
        }

        .no-jobs {
            text-align: center;
            padding: 60px 20px;
            color: var(--text-light);
            background: var(--white);
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            margin-top: 30px;
        }

        .no-jobs i {
            font-size: 3rem;
            margin-bottom: 20px;
            color: var(--primary-light);
        }

        .no-jobs h3 {
            font-size: 1.4rem;
            margin-bottom: 10px;
            color: var(--text-color);
        }

        .no-jobs p {
            font-size: 0.95rem;
            margin-bottom: 30px;
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
            
            .job-header {
                flex-direction: column;
                gap: 12px;
            }
            
            .job-actions {
                justify-content: center;
            }
            
            .btn {
                padding: 8px 16px;
                font-size: 0.85rem;
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
                <a href="my_jobs.jsp" class="menu-item active">
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
        <div class="page-header">
            <h1>My Posted Jobs</h1>
            <p>Manage your job postings and view applications</p>
        </div>

        <%
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            ResultSet countRs = null;
            
            int totalJobs = 0;
            int totalApplications = 0;
            
            try {
                String url = "jdbc:mysql://localhost:3306/jobportal";
                String dbUsername = "root";
                String dbPassword = "navya@2006";
                
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, dbUsername, dbPassword);
                
                // Get total stats
                String totalJobsSql = "SELECT COUNT(*) as total FROM jobs WHERE recruiter_id = ?";
                stmt = conn.prepareStatement(totalJobsSql);
                stmt.setInt(1, userId);
                rs = stmt.executeQuery();
                if (rs.next()) totalJobs = rs.getInt("total");
                
                String totalAppsSql = "SELECT COUNT(*) as total FROM job_applications WHERE recruiter_id = ?";
                stmt = conn.prepareStatement(totalAppsSql);
                stmt.setInt(1, userId);
                rs = stmt.executeQuery();
                if (rs.next()) totalApplications = rs.getInt("total");
                
                // Get jobs posted by this recruiter
                String sql = "SELECT * FROM jobs WHERE recruiter_id = ? ORDER BY created_at DESC";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, userId);
                rs = stmt.executeQuery();
        %>

        <!-- Stats Overview -->
        <div class="stats-overview">
            <div class="stat-item">
                <div class="stat-icon">
                    <i class="fas fa-briefcase"></i>
                </div>
                <div class="stat-number"><%= totalJobs %></div>
                <div class="stat-label">Total Jobs</div>
            </div>
            <div class="stat-item">
                <div class="stat-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <div class="stat-number"><%= totalApplications %></div>
                <div class="stat-label">Total Applications</div>
            </div>
        </div>

        <div class="jobs-container">
            <%
                boolean hasJobs = false;
                
                while (rs.next()) {
                    hasJobs = true;
                    int jobId = rs.getInt("id");
                    String jobTitle = rs.getString("job_title");
                    String companyName = rs.getString("company_name");
                    String jobDescription = rs.getString("job_description");
                    String location = rs.getString("location");
                    String jobType = rs.getString("job_type");
                    String salaryRange = rs.getString("salary_range");
                    
                    // Get application count for this job
                    String countSql = "SELECT COUNT(*) as app_count FROM job_applications WHERE job_id = ?";
                    PreparedStatement countStmt = conn.prepareStatement(countSql);
                    countStmt.setInt(1, jobId);
                    countRs = countStmt.executeQuery();
                    int appCount = 0;
                    if (countRs.next()) {
                        appCount = countRs.getInt("app_count");
                    }
                    countRs.close();
                    countStmt.close();
            %>
                    <div class="job-card">
                        <div class="job-header">
                            <div>
                                <div class="job-title"><%= jobTitle %></div>
                                <div class="company-name">
                                    <i class="fas fa-building"></i>
                                    <%= companyName %>
                                </div>
                            </div>
                            <div class="applications-count">
                                <i class="fas fa-users"></i>
                                <%= appCount %> Application<%= appCount != 1 ? "s" : "" %>
                            </div>
                        </div>
                        
                        <div class="job-meta">
                            <div class="meta-item">
                                <i class="fas fa-map-marker-alt"></i>
                                <span><%= location %></span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-clock"></i>
                                <span><%= jobType %></span>
                            </div>
                            <% if (salaryRange != null && !salaryRange.isEmpty()) { %>
                            <div class="meta-item">
                                <i class="fas fa-money-bill-wave"></i>
                                <span><%= salaryRange %></span>
                            </div>
                            <% } %>
                        </div>
                        
                        <div class="job-description">
                            <%= jobDescription.length() > 150 ? jobDescription.substring(0, 150) + "..." : jobDescription %>
                        </div>
                        
                        <div class="job-actions">
                            <a href="view_applications.jsp?job_id=<%= jobId %>" class="btn btn-primary">
                                <i class="fas fa-eye"></i> View Applications
                            </a>
                        </div>
                    </div>
            <%
                }
                
                if (!hasJobs) {
            %>
                    <div class="no-jobs">
                        <i class="fas fa-briefcase"></i>
                        <h3>No Jobs Posted Yet</h3>
                        <p>Start your recruitment journey by posting your first job opening</p>
                        <a href="post_job.jsp" class="btn btn-primary" style="margin-top: 20px;">
                            <i class="fas fa-plus"></i> Post Your First Job
                        </a>
                    </div>
            <%
                }
                
            } catch (Exception e) {
                e.printStackTrace();
            %>
                <div class="no-jobs">
                    <i class="fas fa-exclamation-triangle"></i>
                    <h3>Error Loading Jobs</h3>
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