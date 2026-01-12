<%@ page import="java.sql.*, java.util.*" %>
<%
    // Check if user is logged in as job seeker
    String userName = (String) session.getAttribute("userName");
    String userType = (String) session.getAttribute("userType");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userName == null || !"jobseeker".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get job_id from URL parameter
    String jobIdParam = request.getParameter("job_id");
    if (jobIdParam == null) {
        response.sendRedirect("jobseek_dashboard.jsp");
        return;
    }
    
    int jobId = Integer.parseInt(jobIdParam);
    
    // Variables to store job and custom field data
    String jobTitle = "";
    String companyName = "";
    String jobDescription = "";
    String location = "";
    String jobType = "";
    int recruiterId = 0;
    
    // List to store enabled custom fields
    List<Map<String, String>> customFields = new ArrayList<>();
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        // Database connection
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String username = "root";
        String password = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);
        
        // Get job details
        String jobSql = "SELECT * FROM jobs WHERE id = ?";
        stmt = conn.prepareStatement(jobSql);
        stmt.setInt(1, jobId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            jobTitle = rs.getString("job_title");
            companyName = rs.getString("company_name");
            jobDescription = rs.getString("job_description");
            location = rs.getString("location");
            jobType = rs.getString("job_type");
            recruiterId = rs.getInt("recruiter_id");
            
            // Check each custom field (1-10) and add enabled ones to the list
            for(int i = 1; i <= 10; i++) {
                boolean isEnabled = rs.getBoolean("custom_field" + i + "_enabled");
                String fieldName = rs.getString("custom_field" + i + "_name");
                String fieldType = rs.getString("custom_field" + i + "_type");
                
                if (isEnabled && fieldName != null && !fieldName.trim().isEmpty()) {
                    Map<String, String> field = new HashMap<>();
                    field.put("number", String.valueOf(i));
                    field.put("name", "custom_field" + i);
                    field.put("label", fieldName);
                    field.put("type", fieldType);
                    customFields.add(field);
                }
            }
            
        } else {
            response.sendRedirect("jobseek_dashboard.jsp");
            return;
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("jobseek_dashboard.jsp");
        return;
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
<html>
<head>
    <title>Apply for <%= jobTitle %> | JobPortal</title>
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

        .container {
            background: var(--white);
            padding: 2.5rem;
            border-radius: 16px;
            box-shadow: var(--card-shadow);
        }

        .header {
            text-align: center;
            margin-bottom: 2.5rem;
            padding-bottom: 2rem;
            border-bottom: 2px solid #f0f0f0;
        }

        h1 {
            color: var(--text-color);
            margin-bottom: 1rem;
            font-size: 2rem;
            font-weight: 700;
        }

        .job-title {
            color: var(--primary-color);
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .company-name {
            color: var(--text-light);
            font-size: 1.1rem;
            margin-bottom: 1.5rem;
        }

        .job-details {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin-top: 1rem;
            flex-wrap: wrap;
        }

        .detail-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-light);
            font-size: 0.9rem;
            background: var(--bg-color);
            padding: 0.5rem 1rem;
            border-radius: 20px;
        }

        .form-section {
            margin-bottom: 2.5rem;
        }

        .section-title {
            color: var(--text-color);
            margin-bottom: 1.5rem;
            font-size: 1.3rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-title i {
            color: var(--primary-color);
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: var(--text-color);
            font-size: 0.9rem;
        }

        .required::after {
            content: " *";
            color: #e74c3c;
        }

        input, textarea, select {
            width: 100%;
            padding: 1rem 1.2rem;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: var(--transition);
            background: #fafafa;
        }

        input:focus, textarea:focus, select:focus {
            outline: none;
            border-color: var(--primary-color);
            background: white;
            box-shadow: 0 0 0 3px rgba(250, 151, 106, 0.1);
        }

        textarea {
            resize: vertical;
            min-height: 120px;
        }

        .custom-field {
            background: #fcf5f1;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            border-radius: 12px;
            border-left: 4px solid var(--primary-color);
            transition: var(--transition);
        }

        .custom-field:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        }

        .field-number {
            background: var(--primary-color);
            color: white;
            border-radius: 50%;
            width: 28px;
            height: 28px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            font-weight: 600;
            margin-right: 12px;
        }

        .form-actions {
            text-align: center;
            margin-top: 2.5rem;
            padding-top: 2rem;
            border-top: 2px solid #f0f0f0;
        }

        .btn {
            padding: 1rem 2rem;
            background: var(--primary-color);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            margin: 0 0.8rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
            font-size: 1rem;
        }

        .btn:hover {
            background: var(--primary-light);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(250, 151, 106, 0.3);
        }

        .btn-secondary {
            background: var(--text-light);
        }

        .btn-secondary:hover {
            background: #5a6268;
        }

        .no-custom-fields {
            text-align: center;
            padding: 3rem 2rem;
            color: var(--text-light);
            background: var(--bg-color);
            border-radius: 12px;
            border: 2px dashed #e0e0e0;
        }

        .no-custom-fields i {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: #bdc3c7;
        }

        /* Responsive Design */
        @media (max-width: 1100px) {
            .main-content {
                padding: 20px;
            }
            
            .container {
                padding: 1.5rem;
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
                padding: 15px;
            }
            
            .container {
                padding: 1rem;
            }
            
            .job-details {
                gap: 1rem;
            }
            
            .btn {
                padding: 0.8rem 1.5rem;
                font-size: 0.9rem;
                margin: 0.3rem;
            }
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
                    <i class="fas fa-file-alt"></i>
                    <span class="menu-text">Applications</span>
                </a>
                <a href="application_tracker.jsp" class="menu-item">
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
        <div class="container">
            <div class="header">
                <h1>Apply for Position</h1>
                <div class="job-title"><%= jobTitle %></div>
                <div class="company-name"><%= companyName %></div>
                <div class="job-details">
                    <div class="detail-item">
                        <i class="fas fa-map-marker-alt"></i>
                        <span><%= location != null ? location : "Remote" %></span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-clock"></i>
                        <span><%= jobType != null ? jobType : "Full-time" %></span>
                    </div>
                </div>
            </div>
            
            <form action="submit_application.jsp" method="post" id="applicationForm">
                <input type="hidden" name="job_id" value="<%= jobId %>">
                <input type="hidden" name="job_seeker_id" value="<%= userId %>">
                
                <!-- Custom Application Form Fields -->
                <% if (!customFields.isEmpty()) { %>
                <div class="form-section">
                    <h2 class="section-title">
                        <i class="fas fa-list-alt"></i> Application Form
                    </h2>
                    <p style="color: var(--text-light); margin-bottom: 1.5rem; text-align: center; font-size: 0.95rem;">
                        Please fill out the following information as requested by the employer:
                    </p>
                    
                    <% for (Map<String, String> field : customFields) { 
                        String fieldNumber = field.get("number");
                        String fieldName = field.get("name");
                        String fieldLabel = field.get("label");
                        String fieldType = field.get("type");
                    %>
                        <div class="custom-field">
                            <div class="form-group">
                                <label class="required">
                                    <span class="field-number"><%= fieldNumber %></span>
                                    <%= fieldLabel %>
                                </label>
                                
                                <% if ("text".equals(fieldType)) { %>
                                    <input type="text" name="<%= fieldName %>" required placeholder="Enter <%= fieldLabel %>">
                                
                                <% } else if ("textarea".equals(fieldType)) { %>
                                    <textarea name="<%= fieldName %>" required placeholder="Enter <%= fieldLabel %>"></textarea>
                                
                                <% } else if ("select".equals(fieldType)) { %>
                                    <select name="<%= fieldName %>" required>
                                        <option value="">Select <%= fieldLabel %></option>
                                        <option value="Option 1">Option 1</option>
                                        <option value="Option 2">Option 2</option>
                                        <option value="Option 3">Option 3</option>
                                        <option value="Option 4">Option 4</option>
                                        <option value="Option 5">Option 5</option>
                                    </select>
                                
                                <% } else if ("email".equals(fieldType)) { %>
                                    <input type="email" name="<%= fieldName %>" required placeholder="your@email.com">
                                
                                <% } else if ("number".equals(fieldType)) { %>
                                    <input type="number" name="<%= fieldName %>" required placeholder="Enter number">
                                
                                <% } else if ("url".equals(fieldType)) { %>
                                    <input type="url" name="<%= fieldName %>" required placeholder="https://example.com">
                                
                                <% } else { %>
                                    <input type="text" name="<%= fieldName %>" required placeholder="Enter <%= fieldLabel %>">
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
                <% } else { %>
                <div class="form-section">
                    <h2 class="section-title">
                        <i class="fas fa-list-alt"></i> Application Form
                    </h2>
                    <div class="no-custom-fields">
                        <i class="fas fa-info-circle"></i>
                        <h3 style="margin-bottom: 0.5rem; color: var(--text-dark);">No Additional Information Required</h3>
                        <p>The employer has not requested any additional information for this application.</p>
                    </div>
                </div>
                <% } %>
                
                <div class="form-actions">
                    <button type="submit" class="btn">
                        <i class="fas fa-paper-plane"></i> Submit Application
                    </button>
                    <a href="jobseek_dashboard.jsp" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
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

        // Form validation
        document.getElementById('applicationForm').addEventListener('submit', function(e) {
            // Basic validation
            const requiredFields = this.querySelectorAll('[required]');
            let valid = true;
            
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    valid = false;
                    field.style.borderColor = '#e74c3c';
                } else {
                    field.style.borderColor = '';
                }
            });
            
            if (!valid) {
                e.preventDefault();
                alert('Please fill in all required fields marked with *.');
            } else {
                // Show loading state
                const submitBtn = this.querySelector('button[type="submit"]');
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Submitting...';
                submitBtn.disabled = true;
            }
        });
    </script>
</body>
</html>