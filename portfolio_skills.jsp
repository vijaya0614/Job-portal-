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

    // Load existing skills
    List<Map<String, String>> skills = new ArrayList<>();
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String dbUsername = "root";
        String dbPassword = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        String sql = "SELECT * FROM portfolio_skills WHERE user_id = ? ORDER BY skill_category, skill_name";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> skill = new HashMap<>();
            skill.put("id", rs.getString("id"));
            skill.put("name", rs.getString("skill_name"));
            skill.put("level", rs.getString("skill_level"));
            skill.put("category", rs.getString("skill_category"));
            skills.add(skill);
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
    <title>Manage Skills | JobPortal</title>
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

        .skill-tag {
            background: var(--primary-light);
            color: var(--primary-color);
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin: 0.3rem;
        }

        .skills-container {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-top: 1rem;
        }

        .skill-item {
            background: var(--white);
            border: 2px solid var(--primary-light);
            border-radius: 12px;
            padding: 1rem;
            margin-bottom: 1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .skill-info {
            flex: 1;
        }

        .skill-name {
            font-weight: 600;
            color: var(--text-color);
        }

        .skill-meta {
            color: var(--text-light);
            font-size: 0.9rem;
        }

        .skill-actions {
            display: flex;
            gap: 0.5rem;
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
            
            .skill-item {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }
            
            .skill-actions {
                width: 100%;
                justify-content: flex-end;
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
                <a href="portfolio_skills.jsp" class="menu-item active">
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
                <h1>Manage Skills</h1>
                <p>Add and manage your technical skills</p>
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

        <!-- Add Skill Form -->
        <div class="form-section">
            <h2 class="section-title">
                <i class="fas fa-plus"></i> Add New Skill
            </h2>
            
            <form action="portfolio_skills_save.jsp" method="post">
                <div class="form-row">
                    <div class="form-group">
                        <label for="skillName">Skill Name *</label>
                        <input type="text" id="skillName" name="skillName" class="form-control" 
                               placeholder="e.g., JavaScript, React, Python" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="skillCategory">Category *</label>
                        <select id="skillCategory" name="skillCategory" class="form-control" required>
                            <option value="">Select Category</option>
                            <option value="Frontend Development">Frontend Development</option>
                            <option value="Backend Development">Backend Development</option>
                            <option value="Mobile Development">Mobile Development</option>
                            <option value="Database">Database</option>
                            <option value="DevOps & Cloud">DevOps & Cloud</option>
                            <option value="Tools & Technologies">Tools & Technologies</option>
                            <option value="Soft Skills">Soft Skills</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="skillLevel">Proficiency Level *</label>
                    <select id="skillLevel" name="skillLevel" class="form-control" required>
                        <option value="">Select Level</option>
                        <option value="Beginner">Beginner</option>
                        <option value="Intermediate">Intermediate</option>
                        <option value="Advanced">Advanced</option>
                        <option value="Expert">Expert</option>
                    </select>
                </div>

                <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Add Skill
                    </button>
                    <a href="portfolio.jsp" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>
            </form>
        </div>

        <!-- Existing Skills -->
        <div class="form-section">
            <h2 class="section-title">
                <i class="fas fa-list"></i> Your Skills (<%= skills.size() %>)
            </h2>
            
            <% if (skills.isEmpty()) { %>
                <div style="text-align: center; padding: 2rem; color: var(--text-light);">
                    <i class="fas fa-code" style="font-size: 3rem; margin-bottom: 1rem; opacity: 0.5;"></i>
                    <p>No skills added yet. Start by adding your first skill above!</p>
                </div>
            <% } else { %>
                <div class="skills-list">
                    <% 
                    // Group skills by category
                    Map<String, List<Map<String, String>>> skillsByCategory = new HashMap<>();
                    for (Map<String, String> skill : skills) {
                        String category = skill.get("category");
                        if (category == null) category = "Other";
                        skillsByCategory.computeIfAbsent(category, k -> new ArrayList<>()).add(skill);
                    }
                    
                    for (Map.Entry<String, List<Map<String, String>>> entry : skillsByCategory.entrySet()) { 
                    %>
                    <div style="margin-bottom: 2rem;">
                        <h3 style="color: var(--primary-color); margin-bottom: 1rem; font-size: 1.2rem;">
                            <i class="fas fa-folder"></i> <%= entry.getKey() %>
                        </h3>
                        <div class="skills-container">
                            <% for (Map<String, String> skill : entry.getValue()) { %>
                            <div class="skill-tag">
                                <%= skill.get("name") %>
                                <span style="font-size: 0.8rem; opacity: 0.8;">(<%= skill.get("level") %>)</span>
                                <a href="portfolio_skills_delete.jsp?skill_id=<%= skill.get("id") %>" 
                                   class="remove-skill" 
                                   onclick="return confirm('Are you sure you want to delete this skill?')"
                                   style="color: var(--danger); text-decoration: none; margin-left: 5px;">
                                    <i class="fas fa-times"></i>
                                </a>
                            </div>
                            <% } %>
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