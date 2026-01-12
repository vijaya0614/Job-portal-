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
    String userType = (String) sess.getAttribute("userType");
    if (jobSeekerName == null) jobSeekerName = "Job Seeker";
    if (userId == null) userId = 0;

    // Load user settings and preferences
    String email = "";
    String phone = "";
    String currentPassword = "";
    String notificationPreferences = "all";
    String privacySettings = "public";
    String themePreference = (String) sess.getAttribute("theme") != null ? (String) sess.getAttribute("theme") : "light";
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String dbUsername = "root";
        String dbPassword = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        // Load user data
        String sql = "SELECT email, phone FROM job_seekers WHERE id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            email = rs.getString("email");
            phone = rs.getString("phone");
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
    
    // Check for messages
    String successMessage = (String) sess.getAttribute("successMessage");
    String errorMessage = (String) sess.getAttribute("errorMessage");
    sess.removeAttribute("successMessage");
    sess.removeAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en" data-theme="<%= themePreference %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #FA976A;
            --primary-light: #fce0d5;
            --primary-very-light: #fef5f1;
            --text-color: #2C3E50;
            --text-light: #6c7a89;
            --bg-color: #f8f9fa;
            --white: #ffffff;
            --border-color: #eaeaea;
            --sidebar-width: 280px;
            --sidebar-collapsed: 90px;
            --success: #10B981;
            --warning: #F59E0B;
            --danger: #dc3545;
            --card-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            --transition: all 0.3s ease;
            
            /* Dark mode variables */
            --dark-bg: #1a1d23;
            --dark-card: #252a33;
            --dark-text: #e4e6eb;
            --dark-text-light: #b0b3b8;
            --dark-border: #3a3f48;
        }

        [data-theme="dark"] {
            --bg-color: var(--dark-bg);
            --white: var(--dark-card);
            --text-color: var(--dark-text);
            --text-light: var(--dark-text-light);
            --border-color: var(--dark-border);
            --card-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
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
            color: var(--text-color);
            transition: var(--transition);
        }

        /* Sidebar */
        .sidebar {
            width: var(--sidebar-collapsed);
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

        .sidebar.expanded {
            width: var(--sidebar-width);
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
            opacity: 0;
            width: 0;
            overflow: hidden;
        }

        .sidebar.expanded .logo-text {
            opacity: 1;
            width: auto;
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

        .sidebar.expanded .toggle-btn {
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
            opacity: 0;
            width: 0;
            overflow: hidden;
        }

        .sidebar.expanded .menu-text {
            opacity: 1;
            width: auto;
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
            opacity: 0;
            width: 0;
            overflow: hidden;
        }

        .sidebar.expanded .user-details {
            opacity: 1;
            width: auto;
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
            opacity: 0;
            width: 0;
            overflow: hidden;
        }

        .sidebar.expanded .logout-text {
            opacity: 1;
            width: auto;
        }

        /* Main Content */
        .main-content {
            flex: 1;
            padding: 25px 30px;
            overflow-y: auto;
            transition: margin-left 0.3s ease;
        }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .welcome-text h1 {
            font-size: 26px;
            color: var(--text-color);
            font-weight: 700;
            margin-bottom: 5px;
        }

        .welcome-text p {
            color: var(--text-light);
            font-size: 15px;
        }

        /* Settings Sections */
        .settings-section {
            background: var(--white);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--border-color);
        }

        .section-title {
            font-size: 1.2rem;
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
            border: 2px solid var(--border-color);
            border-radius: 8px;
            font-size: 1rem;
            transition: var(--transition);
            background: var(--white);
            color: var(--text-color);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
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
            background: #e0865c;
        }

        .btn-secondary {
            background: var(--text-light);
            color: white;
        }

        .btn-danger {
            background: var(--danger);
            color: white;
        }

        .btn-danger:hover {
            background: #c82333;
        }

        .btn-warning {
            background: var(--warning);
            color: var(--text-color);
        }

        /* Toggle Switch */
        .toggle-switch {
            position: relative;
            display: inline-block;
            width: 60px;
            height: 30px;
        }

        .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .toggle-slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: .4s;
            border-radius: 34px;
        }

        .toggle-slider:before {
            position: absolute;
            content: "";
            height: 22px;
            width: 22px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }

        input:checked + .toggle-slider {
            background-color: var(--primary-color);
        }

        input:checked + .toggle-slider:before {
            transform: translateX(30px);
        }

        /* Settings Grid */
        .settings-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
        }

        .setting-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 0;
            border-bottom: 1px solid var(--border-color);
        }

        .setting-info h4 {
            font-weight: 600;
            margin-bottom: 0.25rem;
            color: var(--text-color);
        }

        .setting-info p {
            color: var(--text-light);
            font-size: 0.9rem;
        }

        /* Alert Styles */
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            font-weight: 500;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        [data-theme="dark"] .alert-success {
            background: #1e4620;
            color: #a3d9a5;
            border-color: #2d5a2f;
        }

        [data-theme="dark"] .alert-error {
            background: #4a1c1c;
            color: #e8a5a5;
            border-color: #5c2424;
        }

        /* Danger Zone */
        .danger-zone {
            border: 2px solid var(--danger);
            border-radius: 12px;
            padding: 2rem;
            background: rgba(220, 53, 69, 0.05);
        }

        [data-theme="dark"] .danger-zone {
            background: rgba(220, 53, 69, 0.1);
        }

        /* Theme Toggle in Header */
        .theme-toggle {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            padding: 0.5rem;
            border-radius: 8px;
            cursor: pointer;
            transition: var(--transition);
            margin-left: 1rem;
        }

        .theme-toggle:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        @media (max-width: 768px) {
            .sidebar {
                width: var(--sidebar-collapsed);
            }
            
            .sidebar:not(.expanded) {
                width: var(--sidebar-collapsed);
            }
            
            .main-content {
                padding: 15px;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .settings-grid {
                grid-template-columns: 1fr;
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
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>
            
            <div class="menu">
                <a href="jobseek_dashboard.jsp" class="menu-item">
                    <i class="fas fa-home"></i>
                    <span class="menu-text">Overview</span>
                </a>
                <a href="portfolio.jsp" class="menu-item">
                    <i class="fas fa-eye"></i>
                    <span class="menu-text">View Portfolio</span>
                </a>
                <a href="portfolio_edit.jsp" class="menu-item">
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
                <a href="profile_settings.jsp" class="menu-item active">
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
                <h1>Settings</h1>
                <p>Manage your account settings and preferences</p>
            </div>
            <div class="user-info" style="display: flex; align-items: center; gap: 1rem;">
                <span>Welcome, <%= jobSeekerName %>!</span>
                <button class="theme-toggle" id="themeToggle" title="Toggle dark mode">
                    <i class="fas fa-moon"></i>
                </button>
            </div>
        </div>

        <!-- Messages -->
        <% if (successMessage != null) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= successMessage %>
            </div>
        <% } %>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
            </div>
        <% } %>

        <!-- Profile Settings -->
        <div class="settings-section">
            <h2 class="section-title">
                <i class="fas fa-user-cog"></i> Profile Settings
            </h2>
            
            <form action="profile_update.jsp" method="post">
                <div class="form-row">
                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" class="form-control" 
                               value="<%= jobSeekerName %>" readonly>
                        <small style="color: var(--text-light);">Name cannot be changed here</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="userType">Account Type</label>
                        <input type="text" id="userType" name="userType" class="form-control" 
                               value="<%= userType.equals("jobseeker") ? "Job Seeker" : "Recruiter" %>" readonly>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email Address *</label>
                        <input type="email" id="email" name="email" class="form-control" 
                               value="<%= email != null ? email : "" %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" class="form-control" 
                               value="<%= phone != null ? phone : "" %>" placeholder="+1 (555) 123-4567">
                    </div>
                </div>

                <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Update Profile
                    </button>
                </div>
            </form>
        </div>

        <!-- Password Settings -->
        <div class="settings-section">
            <h2 class="section-title">
                <i class="fas fa-lock"></i> Password & Security
            </h2>
            
            <form action="password_update.jsp" method="post">
                <div class="form-group">
                    <label for="currentPassword">Current Password *</label>
                    <input type="password" id="currentPassword" name="currentPassword" class="form-control" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="newPassword">New Password *</label>
                        <input type="password" id="newPassword" name="newPassword" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="confirmPassword">Confirm New Password *</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" required>
                    </div>
                </div>

                <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-key"></i> Change Password
                    </button>
                </div>
            </form>
        </div>

        <!-- Preferences -->
        <div class="settings-section">
            <h2 class="section-title">
                <i class="fas fa-sliders-h"></i> Preferences
            </h2>
            
            <div class="settings-grid">
                <!-- Theme Preference -->
                <div class="setting-item">
                    <div class="setting-info">
                        <h4>Dark Mode</h4>
                        <p>Switch between light and dark themes</p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" id="darkModeToggle" <%= themePreference.equals("dark") ? "checked" : "" %>>
                        <span class="toggle-slider"></span>
                    </label>
                </div>

                <!-- Email Notifications -->
                <div class="setting-item">
                    <div class="setting-info">
                        <h4>Email Notifications</h4>
                        <p>Receive job alerts and updates</p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" checked>
                        <span class="toggle-slider"></span>
                    </label>
                </div>

                <!-- Job Recommendations -->
                <div class="setting-item">
                    <div class="setting-info">
                        <h4>Job Recommendations</h4>
                        <p>Get personalized job suggestions</p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" checked>
                        <span class="toggle-slider"></span>
                    </label>
                </div>

                <!-- Application Updates -->
                <div class="setting-item">
                    <div class="setting-info">
                        <h4>Application Updates</h4>
                        <p>Notifications about your job applications</p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" checked>
                        <span class="toggle-slider"></span>
                    </label>
                </div>

                <!-- Profile Visibility -->
                <div class="setting-item">
                    <div class="setting-info">
                        <h4>Profile Visibility</h4>
                        <p>Make your profile visible to recruiters</p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox" checked>
                        <span class="toggle-slider"></span>
                    </label>
                </div>

                <!-- Weekly Digest -->
                <div class="setting-item">
                    <div class="setting-info">
                        <h4>Weekly Digest</h4>
                        <p>Receive weekly summary emails</p>
                    </div>
                    <label class="toggle-switch">
                        <input type="checkbox">
                        <span class="toggle-slider"></span>
                    </label>
                </div>
            </div>

            <div style="margin-top: 2rem;">
                <button class="btn btn-primary" onclick="savePreferences()">
                    <i class="fas fa-save"></i> Save Preferences
                </button>
            </div>
        </div>

        <!-- Privacy & Data -->
        <div class="settings-section">
            <h2 class="section-title">
                <i class="fas fa-shield-alt"></i> Privacy & Data
            </h2>
            
            <div class="settings-grid">
                <div class="setting-item">
                    <div class="setting-info">
                        <h4>Download My Data</h4>
                        <p>Get a copy of all your personal data</p>
                    </div>
                    <button class="btn btn-secondary">
                        <i class="fas fa-download"></i> Download
                    </button>
                </div>

                <div class="setting-item">
                    <div class="setting-info">
                        <h4>Clear Search History</h4>
                        <p>Remove all your job search history</p>
                    </div>
                    <button class="btn btn-secondary">
                        <i class="fas fa-trash"></i> Clear
                    </button>
                </div>
            </div>
        </div>

        <!-- Danger Zone -->
        <div class="settings-section danger-zone">
            <h2 class="section-title" style="color: var(--danger);">
                <i class="fas fa-exclamation-triangle"></i> Danger Zone
            </h2>
            
            <div class="setting-item">
                <div class="setting-info">
                    <h4>Deactivate Account</h4>
                    <p>Temporarily disable your account. You can reactivate anytime.</p>
                </div>
                <button class="btn btn-warning" onclick="confirmDeactivate()">
                    <i class="fas fa-pause"></i> Deactivate
                </button>
            </div>

            <div class="setting-item">
                <div class="setting-info">
                    <h4>Delete Account</h4>
                    <p>Permanently delete your account and all data. This action cannot be undone.</p>
                </div>
                <button class="btn btn-danger" onclick="confirmDelete()">
                    <i class="fas fa-trash"></i> Delete Account
                </button>
            </div>
        </div>
    </div>

    <script>
        // Sidebar toggle functionality
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('expanded');
            
            // Update the chevron icon
            const icon = this.querySelector('i');
            if (sidebar.classList.contains('expanded')) {
                icon.className = 'fas fa-chevron-left';
            } else {
                icon.className = 'fas fa-chevron-right';
            }
        });

        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function(event) {
            const sidebar = document.getElementById('sidebar');
            const toggleBtn = document.getElementById('toggleSidebar');
            
            if (window.innerWidth <= 768 && 
                !sidebar.contains(event.target) && 
                sidebar.classList.contains('expanded')) {
                sidebar.classList.remove('expanded');
                const icon = toggleBtn.querySelector('i');
                icon.className = 'fas fa-chevron-right';
            }
        });

        // Theme Toggle Functionality
        document.addEventListener('DOMContentLoaded', function() {
            const themeToggle = document.getElementById('themeToggle');
            const darkModeToggle = document.getElementById('darkModeToggle');
            const html = document.documentElement;

            // Initialize theme from session/local storage
            const currentTheme = localStorage.getItem('theme') || '<%= themePreference %>';
            html.setAttribute('data-theme', currentTheme);
            updateThemeIcon(currentTheme);

            // Header theme toggle
            themeToggle.addEventListener('click', function() {
                const currentTheme = html.getAttribute('data-theme');
                const newTheme = currentTheme === 'light' ? 'dark' : 'light';
                
                html.setAttribute('data-theme', newTheme);
                localStorage.setItem('theme', newTheme);
                updateThemeSettings(newTheme);
                updateThemeIcon(newTheme);
            });

            // Dark mode toggle in preferences
            darkModeToggle.addEventListener('change', function() {
                const newTheme = this.checked ? 'dark' : 'light';
                html.setAttribute('data-theme', newTheme);
                localStorage.setItem('theme', newTheme);
                updateThemeSettings(newTheme);
                updateThemeIcon(newTheme);
            });

            function updateThemeIcon(theme) {
                const icon = themeToggle.querySelector('i');
                icon.className = theme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
                darkModeToggle.checked = theme === 'dark';
            }

            function updateThemeSettings(theme) {
                // Send AJAX request to save theme preference
                const formData = new URLSearchParams();
                formData.append('theme', theme);
                
                fetch('theme_update.jsp', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: formData
                });
            }

            // Auto-hide messages after 5 seconds
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                setTimeout(() => {
                    alert.style.opacity = '0';
                    alert.style.transition = 'opacity 0.5s ease';
                    setTimeout(() => {
                        alert.remove();
                    }, 500);
                }, 5000);
            });
        });

        // Preference saving
        function savePreferences() {
            // Collect all preference values
            const checkboxes = document.querySelectorAll('.settings-grid input[type="checkbox"]');
            const preferences = {
                darkMode: checkboxes[0].checked,
                emailNotifications: checkboxes[1].checked,
                jobRecommendations: checkboxes[2].checked,
                applicationUpdates: checkboxes[3].checked,
                profileVisibility: checkboxes[4].checked,
                weeklyDigest: checkboxes[5].checked
            };

            // Send preferences to server
            fetch('preferences_update.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'preferences=' + JSON.stringify(preferences)
            })
            .then(response => response.text())
            .then(data => {
                showNotification('Preferences saved successfully!', 'success');
            })
            .catch(error => {
                console.error('Error:', error);
                showNotification('Error saving preferences.', 'error');
            });
        }

        function showNotification(message, type) {
            // Create notification element
            const notification = document.createElement('div');
            notification.className = 'alert ' + (type === 'success' ? 'alert-success' : 'alert-error');
            
            // Set icon based on type
            const iconClass = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
            notification.innerHTML = '<i class="fas ' + iconClass + '"></i> ' + message;
            
            // Insert at the top of main content
            const mainContent = document.querySelector('.main-content');
            mainContent.insertBefore(notification, mainContent.firstChild);
            
            // Auto remove after 5 seconds
            setTimeout(() => {
                notification.style.opacity = '0';
                notification.style.transition = 'opacity 0.5s ease';
                setTimeout(() => {
                    if (notification.parentNode) {
                        notification.parentNode.removeChild(notification);
                    }
                }, 500);
            }, 5000);
        }

        // Danger zone confirmations
        function confirmDeactivate() {
            if (confirm('Are you sure you want to deactivate your account? You can reactivate it anytime by logging in.')) {
                // In a real application, this would redirect to deactivation handler
                showNotification('Account deactivation feature would be implemented here.', 'error');
            }
        }

        function confirmDelete() {
            if (confirm('⚠️ WARNING: This will permanently delete your account and all associated data. This action cannot be undone. Are you absolutely sure?')) {
                const confirmText = prompt('Please type "DELETE" to confirm:');
                if (confirmText === 'DELETE') {
                    // In a real application, this would redirect to deletion handler
                    showNotification('Account deletion feature would be implemented here.', 'error');
                } else {
                    showNotification('Account deletion cancelled.', 'error');
                }
            }
        }
    </script>
</body>
</html>