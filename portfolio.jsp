<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%
    // Ensure logged-in user is a Job Seeker
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userType") == null || 
        !sess.getAttribute("userType").equals("jobseeker")) {
        response.sendRedirect("login.jsp");
        return;
    }

    String jobSeekerName = (String) sess.getAttribute("userName");
    Integer userId = (Integer) sess.getAttribute("userId");
    if (jobSeekerName == null) jobSeekerName = "Job Seeker";
    if (userId == null) userId = 0;
    
    // Initialize portfolio data
    String aboutMe = "";
    String currentPosition = "";
    String education = "";
    String contactEmail = "";
    String phone = "";
    String location = "";
    String linkedinUrl = "";
    String githubUrl = "";
    String websiteUrl = "";
    
    // Initialize lists for dynamic data
    List<Map<String, String>> projects = new ArrayList<>();
    List<Map<String, String>> skills = new ArrayList<>();
    List<Map<String, String>> experiences = new ArrayList<>();
    
    // Counters
    int projectsCount = 0;
    int skillsCount = 0;
    int experienceCount = 0;

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
        String portfolioSql = "SELECT * FROM job_seeker_portfolios WHERE user_id = ?";
        stmt = conn.prepareStatement(portfolioSql);
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
        rs.close();
        stmt.close();
        
        // Load projects
        String projectsSql = "SELECT * FROM portfolio_projects WHERE user_id = ? ORDER BY display_order, created_at DESC";
        stmt = conn.prepareStatement(projectsSql);
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
            projectsCount++;
        }
        rs.close();
        stmt.close();
        
        // Load skills
        String skillsSql = "SELECT * FROM portfolio_skills WHERE user_id = ? ORDER BY skill_category, skill_name";
        stmt = conn.prepareStatement(skillsSql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> skill = new HashMap<>();
            skill.put("id", rs.getString("id"));
            skill.put("name", rs.getString("skill_name"));
            skill.put("level", rs.getString("skill_level"));
            skill.put("category", rs.getString("skill_category"));
            skills.add(skill);
            skillsCount++;
        }
        rs.close();
        stmt.close();
        
        // Load experience
        String experienceSql = "SELECT * FROM portfolio_experience WHERE user_id = ? ORDER BY start_date DESC";
        stmt = conn.prepareStatement(experienceSql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> experience = new HashMap<>();
            experience.put("id", rs.getString("id"));
            experience.put("jobTitle", rs.getString("job_title"));
            experience.put("companyName", rs.getString("company_name"));
            experience.put("startDate", rs.getString("start_date"));
            experience.put("endDate", rs.getString("end_date"));
            experience.put("currentJob", rs.getString("current_job"));
            experience.put("description", rs.getString("description"));
            experiences.add(experience);
            experienceCount++;
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
    
    // Check for success/error messages
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
    <title>Portfolio | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
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

        /* Messages */
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: 500;
            font-size: 14px;
        }

        .alert-success {
            background: #D1FAE5;
            color: #065F46;
            border: 1px solid #A7F3D0;
        }

        .alert-error {
            background: #FEE2E2;
            color: #991B1B;
            border: 1px solid #FECACA;
        }

        /* Profile Header - Clean and Compact */
        .profile-header {
            background: var(--white);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .profile-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: var(--primary-color);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.8rem;
            font-weight: 700;
            border: 3px solid var(--primary-light);
        }

        .profile-info {
            flex: 1;
        }

        .profile-info h1 {
            font-size: 1.6rem;
            font-weight: 700;
            margin-bottom: 5px;
            color: var(--text-color);
        }

        .profile-info .position {
            font-size: 1rem;
            color: var(--primary-color);
            font-weight: 600;
            margin-bottom: 10px;
        }

        .profile-info p {
            color: var(--text-light);
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 15px;
        }

        .profile-stats {
            display: flex;
            gap: 25px;
        }

        .stat {
            text-align: center;
        }

        .stat-value {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--text-color);
        }

        .stat-label {
            font-size: 0.8rem;
            color: var(--text-light);
        }

        /* Portfolio Sections */
        .portfolio-section {
            margin-bottom: 25px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--text-color);
        }

        .edit-btn {
            background: var(--primary-color);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
            font-size: 14px;
        }

        .edit-btn:hover {
            background: #e0865c;
        }

        /* Cards Grid */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }

        .info-card {
            background: var(--white);
            border-radius: 10px;
            padding: 20px;
            box-shadow: var(--card-shadow);
            transition: var(--transition);
            border: 1px solid var(--border-color);
        }

        .info-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
        }

        .card-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            background: var(--primary-light);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 1.1rem;
        }

        .card-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-color);
        }

        .card-content {
            color: var(--text-light);
            line-height: 1.6;
            font-size: 14px;
        }

        /* Skills Section */
        .skills-container {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }

        .skill-tag {
            background: var(--primary-light);
            color: var(--primary-color);
            padding: 6px 12px;
            border-radius: 16px;
            font-size: 0.8rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .skill-level {
            font-size: 0.7rem;
            opacity: 0.8;
        }

        /* Projects Grid */
        .projects-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
        }

        .project-card {
            background: var(--white);
            border-radius: 10px;
            overflow: hidden;
            box-shadow: var(--card-shadow);
            transition: var(--transition);
            border: 1px solid var(--border-color);
        }

        .project-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }

        .project-image {
            height: 140px;
            background: linear-gradient(135deg, var(--primary-color) 0%, #e0865c 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2.2rem;
        }

        .project-content {
            padding: 18px;
        }

        .project-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 8px;
            color: var(--text-color);
        }

        .project-description {
            color: var(--text-light);
            margin-bottom: 12px;
            font-size: 13px;
            line-height: 1.5;
        }

        .project-tech {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-bottom: 15px;
        }

        .tech-tag {
            background: var(--bg-color);
            color: var(--text-light);
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.75rem;
        }

        .project-links {
            display: flex;
            gap: 12px;
        }

        .project-link {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.85rem;
            display: flex;
            align-items: center;
            gap: 4px;
            transition: var(--transition);
        }

        .project-link:hover {
            color: #e0865c;
        }

        /* Contact Info */
        .contact-info {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .contact-item {
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--text-light);
            font-size: 14px;
        }

        .contact-item i {
            color: var(--primary-color);
            width: 16px;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 30px 20px;
            background: var(--white);
            border-radius: 10px;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--border-color);
        }

        .empty-state-icon {
            font-size: 3rem;
            color: var(--primary-light);
            margin-bottom: 15px;
        }

        .empty-state h3 {
            color: var(--text-color);
            margin-bottom: 8px;
            font-size: 1.1rem;
        }

        .empty-state p {
            color: var(--text-light);
            margin-bottom: 20px;
            font-size: 14px;
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
                padding: 15px;
            }
            
            .cards-grid, .projects-grid {
                grid-template-columns: 1fr;
            }
            
            .profile-header {
                flex-direction: column;
                text-align: center;
                gap: 15px;
            }
            
            .profile-stats {
                justify-content: center;
            }
            
            .section-header {
                flex-direction: column;
                gap: 12px;
                align-items: flex-start;
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
            <a href="portfolio.jsp" class="menu-item active">
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
                <h1>My Portfolio</h1>
                <p>Showcase your skills, projects, and experience to potential employers</p>
            </div>
        </div>

        <!-- Success/Error Messages -->
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

        <!-- Profile Header -->
        <section class="profile-header">
            <div class="profile-avatar">
                <%= jobSeekerName != null ? jobSeekerName.substring(0, 1).toUpperCase() : "J" %>
            </div>
            <div class="profile-info">
                <h1><%= jobSeekerName != null ? jobSeekerName : "Job Seeker" %></h1>
                <div class="position">
                    <%= (currentPosition != null && !currentPosition.isEmpty()) ? currentPosition : "Student" %>
                </div>
                <p>
                    <%= (aboutMe != null && !aboutMe.isEmpty()) ? aboutMe : "I am a software developer who is interested in coding" %>
                </p>
                <div class="profile-stats">
                    <div class="stat">
                        <div class="stat-value"><%= projectsCount %></div>
                        <div class="stat-label">Projects</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value"><%= skillsCount %></div>
                        <div class="stat-label">Skills</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value"><%= experienceCount %></div>
                        <div class="stat-label">Experience</div>
                    </div>
                </div>
            </div>
        </section>

        <!-- About Me Section -->
        <section class="portfolio-section">
            <div class="section-header">
                <h2 class="section-title">About Me</h2>
                <a href="portfolio_edit.jsp" class="edit-btn">
                    <i class="fas fa-edit"></i> Edit Profile
                </a>
            </div>
            <div class="cards-grid">
                <div class="info-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-graduation-cap"></i>
                        </div>
                        <h3 class="card-title">Education</h3>
                    </div>
                    <div class="card-content">
                        <%= (education != null && !education.isEmpty()) ? education : "Add your educational background to showcase your qualifications." %>
                    </div>
                </div>
                
                <div class="info-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-bullseye"></i>
                        </div>
                        <h3 class="card-title">Career Objective</h3>
                    </div>
                    <div class="card-content">
                        <%= (aboutMe != null && !aboutMe.isEmpty()) ? 
                            (aboutMe.length() > 120 ? aboutMe.substring(0, 120) + "..." : aboutMe) 
                            : "Share your career goals and what you're passionate about in your portfolio." %>
                    </div>
                </div>
            </div>
        </section>

        <!-- Skills Section -->
        <section class="portfolio-section">
            <div class="section-header">
                <h2 class="section-title">Technical Skills</h2>
                <a href="portfolio_skills.jsp" class="edit-btn">
                    <i class="fas fa-edit"></i> Manage Skills
                </a>
            </div>
            
            <% if (skills.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i class="fas fa-code"></i>
                    </div>
                    <h3>No Skills Added Yet</h3>
                    <p>Showcase your technical skills to impress recruiters.</p>
                    <a href="portfolio_skills.jsp" class="edit-btn">
                        <i class="fas fa-plus"></i> Add Your First Skill
                    </a>
                </div>
            <% } else { %>
                <div class="cards-grid">
                    <!-- Group skills by category -->
                    <% 
                    Map<String, List<Map<String, String>>> skillsByCategory = new HashMap<>();
                    for (Map<String, String> skill : skills) {
                        String category = skill.get("category");
                        if (category == null) category = "Other";
                        skillsByCategory.computeIfAbsent(category, k -> new ArrayList<>()).add(skill);
                    }
                    
                    for (Map.Entry<String, List<Map<String, String>>> entry : skillsByCategory.entrySet()) { 
                    %>
                    <div class="info-card">
                        <div class="card-header">
                            <div class="card-icon">
                                <i class="fas fa-tools"></i>
                            </div>
                            <h3 class="card-title"><%= entry.getKey() %></h3>
                        </div>
                        <div class="skills-container">
                            <% for (Map<String, String> skill : entry.getValue()) { %>
                            <span class="skill-tag">
                                <%= skill.get("name") %>
                                <span class="skill-level"><%= skill.get("level") %></span>
                            </span>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } %>
        </section>

        <!-- Projects Section -->
        <section class="portfolio-section">
            <div class="section-header">
                <h2 class="section-title">Projects & Work</h2>
                <a href="portfolio_projects.jsp" class="edit-btn">
                    <i class="fas fa-plus"></i> Add Project
                </a>
            </div>
            
            <% if (projects.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i class="fas fa-project-diagram"></i>
                    </div>
                    <h3>No Projects Added Yet</h3>
                    <p>Showcase your work with detailed project descriptions and links.</p>
                    <a href="portfolio_projects.jsp" class="edit-btn">
                        <i class="fas fa-plus"></i> Add Your First Project
                    </a>
                </div>
            <% } else { %>
                <div class="projects-grid">
                    <% for (Map<String, String> project : projects) { %>
                    <div class="project-card">
                        <div class="project-image">
                            <i class="fas fa-code"></i>
                        </div>
                        <div class="project-content">
                            <h3 class="project-title"><%= project.get("name") %></h3>
                            <p class="project-description">
                                <%= project.get("description") != null ? 
                                    (project.get("description").length() > 100 ? 
                                     project.get("description").substring(0, 100) + "..." : 
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
                                    <i class="fab fa-github"></i> Code
                                </a>
                                <% } %>
                                <% if (project.get("projectUrl") != null && !project.get("projectUrl").isEmpty()) { %>
                                <a href="<%= project.get("projectUrl") %>" target="_blank" class="project-link">
                                    <i class="fas fa-external-link-alt"></i> Live Demo
                                </a>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } %>
        </section>

        <!-- Contact & Social -->
        <section class="portfolio-section">
            <div class="section-header">
                <h2 class="section-title">Contact & Social</h2>
            </div>
            <div class="cards-grid">
                <div class="info-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-address-book"></i>
                        </div>
                        <h3 class="card-title">Contact Information</h3>
                    </div>
                    <div class="contact-info">
                        <% if (contactEmail != null && !contactEmail.isEmpty()) { %>
                        <div class="contact-item">
                            <i class="fas fa-envelope"></i>
                            <span><%= contactEmail %></span>
                        </div>
                        <% } %>
                        <% if (phone != null && !phone.isEmpty()) { %>
                        <div class="contact-item">
                            <i class="fas fa-phone"></i>
                            <span><%= phone %></span>
                        </div>
                        <% } %>
                        <% if (location != null && !location.isEmpty()) { %>
                        <div class="contact-item">
                            <i class="fas fa-map-marker-alt"></i>
                            <span><%= location %></span>
                        </div>
                        <% } %>
                        <% if (contactEmail == null && phone == null && location == null) { %>
                        <div class="contact-item">
                            <i class="fas fa-info-circle"></i>
                            <span>Add your contact information in portfolio settings</span>
                        </div>
                        <% } %>
                    </div>
                </div>
                
                <div class="info-card">
                    <div class="card-header">
                        <div class="card-icon">
                            <i class="fas fa-share-alt"></i>
                        </div>
                        <h3 class="card-title">Social Links</h3>
                    </div>
                    <div class="contact-info">
                        <% if (linkedinUrl != null && !linkedinUrl.isEmpty()) { %>
                        <div class="contact-item">
                            <i class="fab fa-linkedin"></i>
                            <a href="<%= linkedinUrl %>" target="_blank" style="color: var(--text-light); text-decoration: none;">
                                <%= linkedinUrl.length() > 25 ? linkedinUrl.substring(0, 25) + "..." : linkedinUrl %>
                            </a>
                        </div>
                        <% } %>
                        <% if (githubUrl != null && !githubUrl.isEmpty()) { %>
                        <div class="contact-item">
                            <i class="fab fa-github"></i>
                            <a href="<%= githubUrl %>" target="_blank" style="color: var(--text-light); text-decoration: none;">
                                <%= githubUrl.length() > 25 ? githubUrl.substring(0, 25) + "..." : githubUrl %>
                            </a>
                        </div>
                        <% } %>
                        <% if (websiteUrl != null && !websiteUrl.isEmpty()) { %>
                        <div class="contact-item">
                            <i class="fas fa-globe"></i>
                            <a href="<%= websiteUrl %>" target="_blank" style="color: var(--text-light); text-decoration: none;">
                                <%= websiteUrl.length() > 25 ? websiteUrl.substring(0, 25) + "..." : websiteUrl %>
                            </a>
                        </div>
                        <% } %>
                        <% if (linkedinUrl == null && githubUrl == null && websiteUrl == null) { %>
                        <div class="contact-item">
                            <i class="fas fa-info-circle"></i>
                            <span>Add your social links in portfolio settings</span>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </section>
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

        // Interactive functionality for the portfolio
        document.addEventListener('DOMContentLoaded', function() {
            // Project links
            const projectLinks = document.querySelectorAll('.project-link');
            projectLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    // Links will open in new tab due to target="_blank"
                    console.log('Opening project link...');
                });
            });

            // Skill tags hover effect
            const skillTags = document.querySelectorAll('.skill-tag');
            skillTags.forEach(tag => {
                tag.addEventListener('mouseenter', function() {
                    this.style.transform = 'scale(1.05)';
                });
                tag.addEventListener('mouseleave', function() {
                    this.style.transform = 'scale(1)';
                });
            });

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
    </script>
</body>
</html>