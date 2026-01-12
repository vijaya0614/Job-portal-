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

    // Load existing projects
    List<Map<String, String>> projects = new ArrayList<>();
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String dbUsername = "root";
        String dbPassword = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        String sql = "SELECT * FROM portfolio_projects WHERE user_id = ? ORDER BY display_order, created_at DESC";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> project = new HashMap<>();
            project.put("id", rs.getString("id"));
            project.put("name", rs.getString("project_name"));
            project.put("description", rs.getString("project_description"));
            project.put("technologies", rs.getString("technologies_used"));
            project.put("projectUrl", rs.getString("project_url"));
            project.put("githubUrl", rs.getString("github_url"));
            project.put("image", rs.getString("project_image"));
            projects.add(project);
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Projects | JobPortal</title>
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
            --danger: #dc3545;
            --card-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
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

        /* Form Sections */
        .form-section {
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
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
        }

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
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

        .project-card {
            background: var(--white);
            border: 2px solid var(--primary-light);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: var(--transition);
        }

        .project-card:hover {
            border-color: var(--primary-color);
            transform: translateY(-2px);
        }

        .project-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }

        .project-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 0.5rem;
        }

        .project-description {
            color: var(--text-light);
            margin-bottom: 1rem;
            line-height: 1.6;
        }

        .project-tech {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }

        .tech-tag {
            background: var(--bg-color);
            color: var(--text-light);
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
        }

        .project-links {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .project-link {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .project-actions {
            display: flex;
            gap: 0.5rem;
            justify-content: flex-end;
        }

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
            
            .project-header {
                flex-direction: column;
                gap: 1rem;
            }
            
            .project-actions {
                width: 100%;
                justify-content: flex-start;
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
                <a href="portfolio_projects.jsp" class="menu-item active">
                    <i class="fas fa-project-diagram"></i>
                    <span class="menu-text">Manage Projects</span>
                </a>
                <a href="portfolio_skills.jsp" class="menu-item">
                    <i class="fas fa-code"></i>
                    <span class="menu-text">Manage Skills</span>
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
                <h1>Manage Projects</h1>
                <p>Add and manage your portfolio projects</p>
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

        <!-- Add Project Form -->
        <div class="form-section">
            <h2 class="section-title">
                <i class="fas fa-plus"></i> Add New Project
            </h2>
            
            <form action="portfolio_projects_save.jsp" method="post">
                <div class="form-group">
                    <label for="projectName">Project Name *</label>
                    <input type="text" id="projectName" name="projectName" class="form-control" 
                           placeholder="e.g., E-Commerce Platform, Task Management App" required>
                </div>

                <div class="form-group">
                    <label for="projectDescription">Project Description *</label>
                    <textarea id="projectDescription" name="projectDescription" class="form-control" 
                              placeholder="Describe your project, its features, and what problem it solves..." required></textarea>
                </div>

                <div class="form-group">
                    <label for="technologiesUsed">Technologies Used *</label>
                    <input type="text" id="technologiesUsed" name="technologiesUsed" class="form-control" 
                           placeholder="e.g., React, Node.js, MongoDB, AWS (comma separated)" required>
                    <small style="color: var(--text-light);">Separate technologies with commas</small>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="projectUrl">Live Demo URL</label>
                        <input type="url" id="projectUrl" name="projectUrl" class="form-control" 
                               placeholder="https://your-project-demo.com">
                    </div>
                    
                    <div class="form-group">
                        <label for="githubUrl">GitHub Repository URL</label>
                        <input type="url" id="githubUrl" name="githubUrl" class="form-control" 
                               placeholder="https://github.com/yourusername/project-name">
                    </div>
                </div>

                <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Add Project
                    </button>
                    <a href="portfolio.jsp" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>
            </form>
        </div>

        <!-- Existing Projects -->
        <div class="form-section">
            <h2 class="section-title">
                <i class="fas fa-list"></i> Your Projects (<%= projects.size() %>)
            </h2>
            
            <% if (projects.isEmpty()) { %>
                <div style="text-align: center; padding: 2rem; color: var(--text-light);">
                    <i class="fas fa-project-diagram" style="font-size: 3rem; margin-bottom: 1rem; opacity: 0.5;"></i>
                    <p>No projects added yet. Start by adding your first project above!</p>
                </div>
            <% } else { %>
                <div class="projects-list">
                    <% for (Map<String, String> project : projects) { %>
                    <div class="project-card">
                        <div class="project-header">
                            <div style="flex: 1;">
                                <h3 class="project-title"><%= project.get("name") %></h3>
                                <p class="project-description">
                                    <%= project.get("description") != null ? 
                                        (project.get("description").length() > 150 ? 
                                         project.get("description").substring(0, 150) + "..." : 
                                         project.get("description")) 
                                        : "No description provided." %>
                                </p>
                                
                                <% if (project.get("technologies") != null && !project.get("technologies").isEmpty()) { %>
                                <div class="project-tech">
                                    <% 
                                    String[] techs = project.get("technologies").split(",");
                                    for (String tech : techs) {
                                        if (tech.trim().length() > 0) {
                                    %>
                                    <span class="tech-tag"><%= tech.trim() %></span>
                                    <% } } %>
                                </div>
                                <% } %>
                                
                                <div class="project-links">
                                    <% if (project.get("githubUrl") != null && !project.get("githubUrl").isEmpty()) { %>
                                    <a href="<%= project.get("githubUrl") %>" target="_blank" class="project-link">
                                        <i class="fab fa-github"></i> View Code
                                    </a>
                                    <% } %>
                                    <% if (project.get("projectUrl") != null && !project.get("projectUrl").isEmpty()) { %>
                                    <a href="<%= project.get("projectUrl") %>" target="_blank" class="project-link">
                                        <i class="fas fa-external-link-alt"></i> Live Demo
                                    </a>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="project-actions">
                                <a href="portfolio_projects_delete.jsp?project_id=<%= project.get("id") %>" 
                                   class="btn btn-danger"
                                   onclick="return confirm('Are you sure you want to delete this project?')">
                                    <i class="fas fa-trash"></i> Delete
                                </a>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } %>
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

        // Auto-hide messages after 5 seconds
        document.addEventListener('DOMContentLoaded', function() {
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
    </script>
</body>
</html>