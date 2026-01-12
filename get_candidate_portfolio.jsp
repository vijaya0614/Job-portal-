<%@ page import="java.sql.*, java.util.*, org.json.*" %>
<%
    // Set content type to JSON
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    // Get job seeker ID from request
    String jobSeekerIdParam = request.getParameter("job_seeker_id");
    if (jobSeekerIdParam == null) {
        response.sendError(400, "Missing job_seeker_id parameter");
        return;
    }
    int jobSeekerId = Integer.parseInt(jobSeekerIdParam);

    JSONObject responseData = new JSONObject();
    
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
        stmt.setInt(1, jobSeekerId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            responseData.put("aboutMe", rs.getString("about_me"));
            responseData.put("currentPosition", rs.getString("current_position"));
            responseData.put("education", rs.getString("education"));
            responseData.put("contactEmail", rs.getString("contact_email"));
            responseData.put("phone", rs.getString("phone"));
            responseData.put("location", rs.getString("location"));
            responseData.put("linkedinUrl", rs.getString("linkedin_url"));
            responseData.put("githubUrl", rs.getString("github_url"));
            responseData.put("websiteUrl", rs.getString("website_url"));
        }
        rs.close();
        stmt.close();
        
        // Load projects
        String projectsSql = "SELECT * FROM portfolio_projects WHERE user_id = ? ORDER BY display_order, created_at DESC";
        stmt = conn.prepareStatement(projectsSql);
        stmt.setInt(1, jobSeekerId);
        rs = stmt.executeQuery();
        
        JSONArray projects = new JSONArray();
        while (rs.next()) {
            JSONObject project = new JSONObject();
            project.put("name", rs.getString("project_name"));
            project.put("description", rs.getString("project_description"));
            project.put("technologies", rs.getString("technologies_used"));
            project.put("projectUrl", rs.getString("project_url"));
            project.put("githubUrl", rs.getString("github_url"));
            projects.put(project);
        }
        responseData.put("projects", projects);
        responseData.put("projectsCount", projects.length());
        rs.close();
        stmt.close();
        
        // Load skills
        String skillsSql = "SELECT * FROM portfolio_skills WHERE user_id = ? ORDER BY skill_category, skill_name";
        stmt = conn.prepareStatement(skillsSql);
        stmt.setInt(1, jobSeekerId);
        rs = stmt.executeQuery();
        
        JSONArray skills = new JSONArray();
        while (rs.next()) {
            JSONObject skill = new JSONObject();
            skill.put("name", rs.getString("skill_name"));
            skill.put("level", rs.getString("skill_level"));
            skill.put("category", rs.getString("skill_category"));
            skills.put(skill);
        }
        responseData.put("skills", skills);
        responseData.put("skillsCount", skills.length());
        rs.close();
        stmt.close();
        
        // Load experience count
        String experienceSql = "SELECT COUNT(*) as exp_count FROM portfolio_experience WHERE user_id = ?";
        stmt = conn.prepareStatement(experienceSql);
        stmt.setInt(1, jobSeekerId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            responseData.put("experienceCount", rs.getInt("exp_count"));
        }
        
        out.print(responseData.toString());
        
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(500);
        JSONObject error = new JSONObject();
        error.put("error", "Failed to load portfolio data");
        out.print(error.toString());
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