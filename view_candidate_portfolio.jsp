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
    
    String jobSeekerIdParam = request.getParameter("job_seeker_id");
    String applicationIdParam = request.getParameter("application_id");
    
    if (jobSeekerIdParam == null) {
        response.sendRedirect("my_jobs.jsp");
        return;
    }
    int jobSeekerId = Integer.parseInt(jobSeekerIdParam);
    int applicationId = applicationIdParam != null ? Integer.parseInt(applicationIdParam) : 0;
    
    // Initialize candidate data
    String candidateName = "";
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
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String dbUsername = "root";
        String dbPassword = "navya@2006";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        // Get candidate basic info
        String candidateSql = "SELECT full_name, email FROM job_seekers WHERE id = ?";
        stmt = conn.prepareStatement(candidateSql);
        stmt.setInt(1, jobSeekerId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            candidateName = rs.getString("full_name");
            contactEmail = rs.getString("email");
        }
        rs.close();
        stmt.close();
        
        // Load portfolio data
        String portfolioSql = "SELECT * FROM job_seeker_portfolios WHERE user_id = ?";
        stmt = conn.prepareStatement(portfolioSql);
        stmt.setInt(1, jobSeekerId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            aboutMe = rs.getString("about_me");
            currentPosition = rs.getString("current_position");
            education = rs.getString("education");
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
        stmt.setInt(1, jobSeekerId);
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> project = new HashMap<>();
            project.put("name", rs.getString("project_name"));
            project.put("description", rs.getString("project_description"));
            project.put("technologies", rs.getString("technologies_used"));
            project.put("projectUrl", rs.getString("project_url"));
            project.put("githubUrl", rs.getString("github_url"));
            projects.add(project);
        }
        rs.close();
        stmt.close();
        
        // Load skills
        String skillsSql = "SELECT * FROM portfolio_skills WHERE user_id = ? ORDER BY skill_category, skill_name";
        stmt = conn.prepareStatement(skillsSql);
        stmt.setInt(1, jobSeekerId);
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> skill = new HashMap<>();
            skill.put("name", rs.getString("skill_name"));
            skill.put("level", rs.getString("skill_level"));
            skill.put("category", rs.getString("skill_category"));
            skills.add(skill);
        }
        rs.close();
        stmt.close();
        
        // Load experience
        String experienceSql = "SELECT * FROM portfolio_experience WHERE user_id = ? ORDER BY start_date DESC";
        stmt = conn.prepareStatement(experienceSql);
        stmt.setInt(1, jobSeekerId);
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> experience = new HashMap<>();
            experience.put("jobTitle", rs.getString("job_title"));
            experience.put("companyName", rs.getString("company_name"));
            experience.put("startDate", rs.getString("start_date"));
            experience.put("endDate", rs.getString("end_date"));
            experience.put("currentJob", rs.getString("current_job"));
            experience.put("description", rs.getString("description"));
            experiences.add(experience);
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
    <title><%= candidateName %>'s Portfolio | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Copy all the CSS styles from your portfolio.jsp file here */
        /* This ensures consistent styling with the job seeker's portfolio view */
        :root {
            --primary-color: #FA976A;
            --primary-light: #fce0d5;
            --primary-very-light: #fef5f1;
            --text-color: #2C3E50;
            --text-light: #6c7a89;
            --bg-color: #f8f9fa;
            --white: #ffffff;
            --border-color: #eaeaea;
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
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: var(--white);
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, var(--primary-color) 0%, #e0865c 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }

        .header .position {
            font-size: 1.2rem;
            opacity: 0.9;
        }

        .back-btn {
            position: absolute;
            top: 20px;
            left: 20px;
            background: rgba(255,255,255,0.2);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
        }

        .back-btn:hover {
            background: rgba(255,255,255,0.3);
        }

        .content {
            padding: 30px;
        }

        /* Copy all other portfolio styles from portfolio.jsp */
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

        /* ... include all other portfolio styles ... */
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            
            <h1><%= candidateName %>'s Portfolio</h1>
            <div class="position">
                <%= (currentPosition != null && !currentPosition.isEmpty()) ? currentPosition : "Candidate" %>
            </div>
        </div>

        <div class="content">
            <!-- Profile Header -->
            <section class="profile-header">
                <div class="profile-avatar">
                    <%= candidateName != null ? candidateName.substring(0, 1).toUpperCase() : "C" %>
                </div>
                <div class="profile-info">
                    <h1><%= candidateName %></h1>
                    <div class="position" style="color: var(--primary-color); font-weight: 600; margin-bottom: 10px;">
                        <%= (currentPosition != null && !currentPosition.isEmpty()) ? currentPosition : "Looking for opportunities" %>
                    </div>
                    <p>
                        <%= (aboutMe != null && !aboutMe.isEmpty()) ? aboutMe : "No bio provided." %>
                    </p>
                </div>
            </section>

            <!-- About Me Section -->
            <section class="portfolio-section">
                <h2 class="section-title">About Me</h2>
                <div class="cards-grid">
                    <div class="info-card">
                        <div class="card-header">
                            <div class="card-icon">
                                <i class="fas fa-graduation-cap"></i>
                            </div>
                            <h3 class="card-title">Education</h3>
                        </div>
                        <div class="card-content">
                            <%= (education != null && !education.isEmpty()) ? education : "Education information not provided." %>
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
                            <%= (aboutMe != null && !aboutMe.isEmpty()) ? aboutMe : "Career objective not specified." %>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Skills Section -->
            <section class="portfolio-section">
                <h2 class="section-title">Technical Skills</h2>
                <% if (skills.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">
                            <i class="fas fa-code"></i>
                        </div>
                        <h3>No Skills Added</h3>
                        <p>Candidate hasn't added any skills yet.</p>
                    </div>
                <% } else { %>
                    <div class="cards-grid">
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
                <h2 class="section-title">Projects & Work</h2>
                <% if (projects.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">
                            <i class="fas fa-project-diagram"></i>
                        </div>
                        <h3>No Projects Added</h3>
                        <p>Candidate hasn't added any projects yet.</p>
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
                                    <%= project.get("description") != null ? project.get("description") : "No description provided." %>
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

            <!-- Contact Information -->
            <section class="portfolio-section">
                <h2 class="section-title">Contact Information</h2>
                <div class="cards-grid">
                    <div class="info-card">
                        <div class="card-header">
                            <div class="card-icon">
                                <i class="fas fa-address-book"></i>
                            </div>
                            <h3 class="card-title">Contact Details</h3>
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
                                    LinkedIn Profile
                                </a>
                            </div>
                            <% } %>
                            <% if (githubUrl != null && !githubUrl.isEmpty()) { %>
                            <div class="contact-item">
                                <i class="fab fa-github"></i>
                                <a href="<%= githubUrl %>" target="_blank" style="color: var(--text-light); text-decoration: none;">
                                    GitHub Profile
                                </a>
                            </div>
                            <% } %>
                            <% if (websiteUrl != null && !websiteUrl.isEmpty()) { %>
                            <div class="contact-item">
                                <i class="fas fa-globe"></i>
                                <a href="<%= websiteUrl %>" target="_blank" style="color: var(--text-light); text-decoration: none;">
                                    Personal Website
                                </a>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>
</body>
</html>