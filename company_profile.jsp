<%@ page import="java.sql.*, java.util.*" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userType = (String) session.getAttribute("userType");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userName == null || !"recruiter".equals(userType)) {
%>
        <script>window.location.href = "login.jsp";</script>
<%
        return;
    }

    // Database connection
    String url = "jdbc:mysql://localhost:3306/jobportal";
    String dbUsername = "root";
    String dbPassword = "navya@2006";
    
    // Initialize variables
    Map<String, String> companyData = new HashMap<>();
    Map<String, String> addressData = new HashMap<>();
    boolean companyExists = false;
    String message = "";
    String messageType = "";

    // Load existing company data
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        // Get company data
        String companySql = "SELECT c.*, ca.* FROM companies c " +
                           "LEFT JOIN company_addresses ca ON c.id = ca.company_id AND ca.is_primary = 1 " +
                           "WHERE c.user_id = ?";
        stmt = conn.prepareStatement(companySql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            companyExists = true;
            // Company basic info
            companyData.put("company_id", rs.getString("id"));
            companyData.put("company_name", rs.getString("company_name") != null ? rs.getString("company_name") : "");
            companyData.put("legal_name", rs.getString("legal_name") != null ? rs.getString("legal_name") : "");
            companyData.put("company_email", rs.getString("company_email") != null ? rs.getString("company_email") : "");
            companyData.put("phone", rs.getString("phone") != null ? rs.getString("phone") : "");
            companyData.put("website", rs.getString("website") != null ? rs.getString("website") : "");
            companyData.put("industry", rs.getString("industry") != null ? rs.getString("industry") : "");
            companyData.put("company_size", rs.getString("company_size") != null ? rs.getString("company_size") : "");
            companyData.put("founded_year", rs.getString("founded_year") != null ? rs.getString("founded_year") : "");
            companyData.put("description", rs.getString("description") != null ? rs.getString("description") : "");
            companyData.put("mission", rs.getString("mission") != null ? rs.getString("mission") : "");
            companyData.put("linkedin_url", rs.getString("linkedin_url") != null ? rs.getString("linkedin_url") : "");
            companyData.put("twitter_url", rs.getString("twitter_url") != null ? rs.getString("twitter_url") : "");
            companyData.put("facebook_url", rs.getString("facebook_url") != null ? rs.getString("facebook_url") : "");
            companyData.put("instagram_url", rs.getString("instagram_url") != null ? rs.getString("instagram_url") : "");
            
            // Address info
            addressData.put("address_line_1", rs.getString("address_line_1") != null ? rs.getString("address_line_1") : "");
            addressData.put("address_line_2", rs.getString("address_line_2") != null ? rs.getString("address_line_2") : "");
            addressData.put("city", rs.getString("city") != null ? rs.getString("city") : "");
            addressData.put("state", rs.getString("state") != null ? rs.getString("state") : "");
            addressData.put("country", rs.getString("country") != null ? rs.getString("country") : "");
            addressData.put("postal_code", rs.getString("postal_code") != null ? rs.getString("postal_code") : "");
        }
    } catch (Exception e) {
        e.printStackTrace();
        message = "Error loading company profile: " + e.getMessage();
        messageType = "error";
    } finally {
        try { if (rs != null) rs.close(); if (stmt != null) stmt.close(); if (conn != null) conn.close(); } catch (SQLException e) {}
    }

    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Get all form parameters
        String companyName = request.getParameter("company_name");
        String legalName = request.getParameter("legal_name");
        String companyEmail = request.getParameter("company_email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String industry = request.getParameter("industry");
        String companySize = request.getParameter("company_size");
        String foundedYear = request.getParameter("founded_year");
        String description = request.getParameter("description");
        String mission = request.getParameter("mission");
        String linkedinUrl = request.getParameter("linkedin_url");
        String twitterUrl = request.getParameter("twitter_url");
        String facebookUrl = request.getParameter("facebook_url");
        String instagramUrl = request.getParameter("instagram_url");
        
        // Address fields
        String addressLine1 = request.getParameter("address_line_1");
        String addressLine2 = request.getParameter("address_line_2");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String country = request.getParameter("country");
        String postalCode = request.getParameter("postal_code");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, dbUsername, dbPassword);
            
            if (companyExists) {
                // Update existing company
                String updateCompanySql = "UPDATE companies SET company_name=?, legal_name=?, company_email=?, phone=?, website=?, industry=?, company_size=?, founded_year=?, description=?, mission=?, linkedin_url=?, twitter_url=?, facebook_url=?, instagram_url=?, updated_at=CURRENT_TIMESTAMP WHERE user_id=?";
                stmt = conn.prepareStatement(updateCompanySql);
                stmt.setString(1, companyName);
                stmt.setString(2, legalName);
                stmt.setString(3, companyEmail);
                stmt.setString(4, phone);
                stmt.setString(5, website);
                stmt.setString(6, industry);
                stmt.setString(7, companySize);
                stmt.setString(8, foundedYear.isEmpty() ? null : foundedYear);
                stmt.setString(9, description);
                stmt.setString(10, mission);
                stmt.setString(11, linkedinUrl);
                stmt.setString(12, twitterUrl);
                stmt.setString(13, facebookUrl);
                stmt.setString(14, instagramUrl);
                stmt.setInt(15, userId);
                
                int companyUpdated = stmt.executeUpdate();
                
                // Update address
                String updateAddressSql = "UPDATE company_addresses SET address_line_1=?, address_line_2=?, city=?, state=?, country=?, postal_code=? WHERE company_id=? AND is_primary=1";
                stmt = conn.prepareStatement(updateAddressSql);
                stmt.setString(1, addressLine1);
                stmt.setString(2, addressLine2);
                stmt.setString(3, city);
                stmt.setString(4, state);
                stmt.setString(5, country);
                stmt.setString(6, postalCode);
                stmt.setInt(7, Integer.parseInt(companyData.get("company_id")));
                
                int addressUpdated = stmt.executeUpdate();
                
                if (companyUpdated > 0) {
                    message = "Company profile updated successfully!";
                    messageType = "success";
                    response.sendRedirect("company_profile.jsp");
                    return;
                }
            } else {
                // Insert new company
                String insertCompanySql = "INSERT INTO companies (user_id, company_name, legal_name, company_email, phone, website, industry, company_size, founded_year, description, mission, linkedin_url, twitter_url, facebook_url, instagram_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                stmt = conn.prepareStatement(insertCompanySql, Statement.RETURN_GENERATED_KEYS);
                stmt.setInt(1, userId);
                stmt.setString(2, companyName);
                stmt.setString(3, legalName);
                stmt.setString(4, companyEmail);
                stmt.setString(5, phone);
                stmt.setString(6, website);
                stmt.setString(7, industry);
                stmt.setString(8, companySize);
                stmt.setString(9, foundedYear.isEmpty() ? null : foundedYear);
                stmt.setString(10, description);
                stmt.setString(11, mission);
                stmt.setString(12, linkedinUrl);
                stmt.setString(13, twitterUrl);
                stmt.setString(14, facebookUrl);
                stmt.setString(15, instagramUrl);
                
                int companyInserted = stmt.executeUpdate();
                
                if (companyInserted > 0) {
                    // Get the generated company ID
                    ResultSet generatedKeys = stmt.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        int companyId = generatedKeys.getInt(1);
                        
                        // Insert address
                        String insertAddressSql = "INSERT INTO company_addresses (company_id, address_line_1, address_line_2, city, state, country, postal_code, is_primary) VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
                        stmt = conn.prepareStatement(insertAddressSql);
                        stmt.setInt(1, companyId);
                        stmt.setString(2, addressLine1);
                        stmt.setString(3, addressLine2);
                        stmt.setString(4, city);
                        stmt.setString(5, state);
                        stmt.setString(6, country);
                        stmt.setString(7, postalCode);
                        stmt.executeUpdate();
                    }
                    
                    message = "Company profile created successfully!";
                    messageType = "success";
                    response.sendRedirect("company_profile.jsp");
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error saving company profile: " + e.getMessage();
            messageType = "error";
        } finally {
            try { if (stmt != null) stmt.close(); if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Company Profile | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A==" crossorigin="anonymous" referrerpolicy="no-referrer" />

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
            --success-color: #10b981;
            --error-color: #ef4444;
            --warning-color: #f59e0b;
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

        /* Sidebar Styles (same as your dashboard) */
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

        /* Alert Messages */
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.3s ease;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .alert.success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .alert.error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .alert i {
            font-size: 18px;
        }

        /* Profile Form */
        .profile-container {
            background: var(--white);
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border: 1px solid var(--border-color);
            overflow: hidden;
        }

        .profile-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-light) 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .profile-header h2 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .profile-header p {
            opacity: 0.9;
            font-size: 16px;
        }

        .profile-form {
            padding: 40px;
        }

        .form-section {
            margin-bottom: 40px;
        }

        .section-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--primary-very-light);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-title i {
            color: var(--primary-color);
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-label {
            font-weight: 600;
            color: var(--text-color);
            margin-bottom: 8px;
            font-size: 14px;
        }

        .form-input, .form-textarea, .form-select {
            padding: 14px 16px;
            border: 2px solid var(--border-color);
            border-radius: 12px;
            font-size: 15px;
            transition: all 0.3s ease;
            background: var(--white);
        }

        .form-input:focus, .form-textarea:focus, .form-select:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px var(--primary-very-light);
        }

        .form-textarea {
            resize: vertical;
            min-height: 120px;
            font-family: "Inter", sans-serif;
        }

        .form-hint {
            font-size: 12px;
            color: var(--text-light);
            margin-top: 6px;
        }

        .social-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .social-input {
            display: flex;
            align-items: center;
            gap: 12px;
            position: relative;
        }

        .social-icon {
            width: 40px;
            height: 40px;
            background: var(--primary-very-light);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 18px;
            flex-shrink: 0;
        }

        .social-input input {
            flex: 1;
            padding-right: 45px; /* Make space for the link icon */
        }

        .social-link {
            position: absolute;
            right: 12px;
            color: var(--primary-color);
            text-decoration: none;
            font-size: 16px;
            padding: 8px;
            border-radius: 6px;
            transition: all 0.3s ease;
            background: var(--white);
        }

        .social-link:hover {
            background: var(--primary-very-light);
            transform: scale(1.1);
        }

        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: flex-end;
            margin-top: 30px;
            padding-top: 25px;
            border-top: 2px solid var(--primary-very-light);
        }

        .btn {
            padding: 14px 30px;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
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
            background: #f98653;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(250, 151, 106, 0.3);
        }

        .btn-secondary {
            background: var(--bg-color);
            color: var(--text-color);
            border: 2px solid var(--border-color);
        }

        .btn-secondary:hover {
            background: var(--border-color);
            transform: translateY(-2px);
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .social-grid {
                grid-template-columns: 1fr;
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
                padding: 20px;
            }
            
            .profile-form {
                padding: 25px;
            }
            
            .form-actions {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
            }
        }

        /* Scrollbar */
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
                <a href="view_applications.jsp" class="menu-item">
                    <i class="fas fa-file-alt"></i>
                    <span class="menu-text">Applications</span>
                </a>
                <a href="company_profile.jsp" class="menu-item active">
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
        <div class="top-bar">
            <div class="welcome-text">
                <h1>Company Profile</h1>
                <p>Manage your company information and branding</p>
            </div>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="alert <%= messageType %>">
                <i class="fas <%= messageType.equals("success") ? "fa-check-circle" : "fa-exclamation-circle" %>"></i>
                <%= message %>
            </div>
        <% } %>

        <div class="profile-container">
            <div class="profile-header">
                <h2><%= companyExists ? "Update Your Company Profile" : "Create Your Company Profile" %></h2>
                <p><%= companyExists ? "Keep your company information up to date" : "Set up your company profile to start attracting talent" %></p>
            </div>

            <form method="POST" class="profile-form">
                <!-- Basic Information Section -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-info-circle"></i>
                        Basic Information
                    </h3>
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Company Name *</label>
                            <input type="text" name="company_name" class="form-input" 
                                   value="<%= companyData.getOrDefault("company_name", "") %>" 
                                   placeholder="Enter company name" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Legal Name</label>
                            <input type="text" name="legal_name" class="form-input" 
                                   value="<%= companyData.getOrDefault("legal_name", "") %>" 
                                   placeholder="Enter legal business name">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Company Email *</label>
                            <input type="email" name="company_email" class="form-input" 
                                   value="<%= companyData.getOrDefault("company_email", "") %>" 
                                   placeholder="company@example.com" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Phone Number</label>
                            <input type="tel" name="phone" class="form-input" 
                                   value="<%= companyData.getOrDefault("phone", "") %>" 
                                   placeholder="+1 (555) 123-4567">
                        </div>
                        
                        <div class="form-group">
    <label class="form-label">Website</label>
    <div class="social-input">
        <div class="social-icon">
            <i class="fas fa-globe"></i>
        </div>
        <input type="url" name="website" class="form-input" 
               value="<%= companyData.getOrDefault("website", "") %>" 
               placeholder="https://example.com"
               onchange="makeLinkClickable(this)">
        <% if (!companyData.getOrDefault("website", "").isEmpty()) { %>
            <a href="<%= companyData.get("website") %>" target="_blank" class="social-link" title="Open Website">
                <i class="fas fa-external-link-alt"></i>
            </a>
        <% } %>
    </div>
</div>
                        
                        <div class="form-group">
                            <label class="form-label">Industry</label>
                            <input type="text" name="industry" class="form-input" 
                                   value="<%= companyData.getOrDefault("industry", "") %>" 
                                   placeholder="e.g., Technology, Healthcare, Finance">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Company Size</label>
                            <select name="company_size" class="form-select">
                                <option value="">Select company size</option>
                                <option value="1-10" <%= "1-10".equals(companyData.getOrDefault("company_size", "")) ? "selected" : "" %>>1-10 employees</option>
                                <option value="11-50" <%= "11-50".equals(companyData.getOrDefault("company_size", "")) ? "selected" : "" %>>11-50 employees</option>
                                <option value="51-200" <%= "51-200".equals(companyData.getOrDefault("company_size", "")) ? "selected" : "" %>>51-200 employees</option>
                                <option value="201-500" <%= "201-500".equals(companyData.getOrDefault("company_size", "")) ? "selected" : "" %>>201-500 employees</option>
                                <option value="501-1000" <%= "501-1000".equals(companyData.getOrDefault("company_size", "")) ? "selected" : "" %>>501-1000 employees</option>
                                <option value="1000+" <%= "1000+".equals(companyData.getOrDefault("company_size", "")) ? "selected" : "" %>>1000+ employees</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Founded Year</label>
                            <input type="number" name="founded_year" class="form-input" 
                                   value="<%= companyData.getOrDefault("founded_year", "") %>" 
                                   placeholder="1990" min="1800" max="<%= java.util.Calendar.getInstance().get(java.util.Calendar.YEAR) %>">
                        </div>
                    </div>
                </div>

                <!-- Address Information -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-map-marker-alt"></i>
                        Address Information
                    </h3>
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label class="form-label">Address Line 1</label>
                            <input type="text" name="address_line_1" class="form-input" 
                                   value="<%= addressData.getOrDefault("address_line_1", "") %>" 
                                   placeholder="Street address, P.O. box">
                        </div>
                        
                        <div class="form-group full-width">
                            <label class="form-label">Address Line 2</label>
                            <input type="text" name="address_line_2" class="form-input" 
                                   value="<%= addressData.getOrDefault("address_line_2", "") %>" 
                                   placeholder="Apartment, suite, unit, building, floor, etc.">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">City</label>
                            <input type="text" name="city" class="form-input" 
                                   value="<%= addressData.getOrDefault("city", "") %>" 
                                   placeholder="City">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">State</label>
                            <input type="text" name="state" class="form-input" 
                                   value="<%= addressData.getOrDefault("state", "") %>" 
                                   placeholder="State / Province">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Country</label>
                            <input type="text" name="country" class="form-input" 
                                   value="<%= addressData.getOrDefault("country", "") %>" 
                                   placeholder="Country">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Postal Code</label>
                            <input type="text" name="postal_code" class="form-input" 
                                   value="<%= addressData.getOrDefault("postal_code", "") %>" 
                                   placeholder="ZIP / Postal code">
                        </div>
                    </div>
                </div>

                <!-- About Company -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-building"></i>
                        About Your Company
                    </h3>
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label class="form-label">Company Description</label>
                            <textarea name="description" class="form-textarea" 
                                      placeholder="Describe your company, what you do, your values, and what makes you unique"><%= companyData.getOrDefault("description", "") %></textarea>
                            <div class="form-hint">This will be visible to job seekers</div>
                        </div>
                        
                        <div class="form-group full-width">
                            <label class="form-label">Company Mission</label>
                            <textarea name="mission" class="form-textarea" 
                                      placeholder="What is your company's mission and vision?"><%= companyData.getOrDefault("mission", "") %></textarea>
                        </div>
                    </div>
                </div>

                <!-- Social Media -->
                <div class="form-section">
                    <h3 class="section-title">
                        <i class="fas fa-share-alt"></i>
                        Social Media
                    </h3>
                    <div class="social-grid">
                        <div class="social-input">
                            <div class="social-icon">
                                <i class="fab fa-linkedin"></i>
                            </div>
                            <input type="url" name="linkedin_url" class="form-input" 
                                   value="<%= companyData.getOrDefault("linkedin_url", "") %>" 
                                   placeholder="LinkedIn Company URL"
                                   onchange="makeLinkClickable(this)">
                            <% if (!companyData.getOrDefault("linkedin_url", "").isEmpty()) { %>
                                <a href="<%= companyData.get("linkedin_url") %>" target="_blank" class="social-link" title="Open LinkedIn">
                                    <i class="fas fa-external-link-alt"></i>
                                </a>
                            <% } %>
                        </div>
                        
                        <div class="social-input">
                            <div class="social-icon">
                                <i class="fab fa-twitter"></i>
                            </div>
                            <input type="url" name="twitter_url" class="form-input" 
                                   value="<%= companyData.getOrDefault("twitter_url", "") %>" 
                                   placeholder="Twitter Profile URL"
                                   onchange="makeLinkClickable(this)">
                            <% if (!companyData.getOrDefault("twitter_url", "").isEmpty()) { %>
                                <a href="<%= companyData.get("twitter_url") %>" target="_blank" class="social-link" title="Open Twitter">
                                    <i class="fas fa-external-link-alt"></i>
                                </a>
                            <% } %>
                        </div>
                        
                        <div class="social-input">
                            <div class="social-icon">
                                <i class="fab fa-facebook"></i>
                            </div>
                            <input type="url" name="facebook_url" class="form-input" 
                                   value="<%= companyData.getOrDefault("facebook_url", "") %>" 
                                   placeholder="Facebook Page URL"
                                   onchange="makeLinkClickable(this)">
                            <% if (!companyData.getOrDefault("facebook_url", "").isEmpty()) { %>
                                <a href="<%= companyData.get("facebook_url") %>" target="_blank" class="social-link" title="Open Facebook">
                                    <i class="fas fa-external-link-alt"></i>
                                </a>
                            <% } %>
                        </div>
                        
                        <div class="social-input">
                            <div class="social-icon">
                                <i class="fab fa-instagram"></i>
                            </div>
                            <input type="url" name="instagram_url" class="form-input" 
                                   value="<%= companyData.getOrDefault("instagram_url", "") %>" 
                                   placeholder="Instagram Profile URL"
                                   onchange="makeLinkClickable(this)">
                            <% if (!companyData.getOrDefault("instagram_url", "").isEmpty()) { %>
                                <a href="<%= companyData.get("instagram_url") %>" target="_blank" class="social-link" title="Open Instagram">
                                    <i class="fas fa-external-link-alt"></i>
                                </a>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Form Actions -->
                <div class="form-actions">
                    <a href="recruiter_dashboard.jsp" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i>
                        Back to Dashboard
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i>
                        <%= companyExists ? "Update Company Profile" : "Create Company Profile" %>
                    </button>
                </div>
            </form>
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

        // Auto-hide success message after 5 seconds
        setTimeout(function() {
            const alert = document.querySelector('.alert');
            if (alert) {
                alert.style.opacity = '0';
                alert.style.transform = 'translateY(-10px)';
                setTimeout(() => alert.remove(), 300);
            }
        }, 5000);

        // Function to make social links clickable
        function makeLinkClickable(input) {
            const socialInput = input.closest('.social-input');
            let existingLink = socialInput.querySelector('.social-link');
            
            // Remove existing link if any
            if (existingLink) {
                existingLink.remove();
            }
            
            // Add new link if URL is not empty
            if (input.value.trim() !== '') {
                const link = document.createElement('a');
                link.href = input.value;
                link.target = '_blank';
                link.className = 'social-link';
                
                // Determine platform name for title
                const platform = input.name.replace('_url', '');
                const platformName = platform.charAt(0).toUpperCase() + platform.slice(1);
                link.title = 'Open ' + platformName;
                
                link.innerHTML = '<i class="fas fa-external-link-alt"></i>';
                socialInput.appendChild(link);
            }
        }
    </script>

</body>
</html>