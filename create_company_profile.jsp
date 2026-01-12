<%@ page import="java.sql.*" %>
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

    // Check if company already exists
    boolean hasCompany = false;
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        String url = "jdbc:mysql://localhost:3306/jobportal";
        String username = "root";
        String dbPassword = "navya@2006";
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, dbPassword);

        String checkSql = "SELECT id FROM companies WHERE user_id = ?";
        stmt = conn.prepareStatement(checkSql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        hasCompany = rs.next();
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); if (stmt != null) stmt.close(); if (conn != null) conn.close(); } catch (SQLException e) {}
    }

    if (hasCompany) {
        response.sendRedirect("company_profile.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Create Company Profile | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
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
            --success-color: #10b981;
            --error-color: #ef4444;
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
        }

        /* Include all your existing sidebar styles */
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

        .main-content {
            flex: 1;
            padding: 30px 40px;
            overflow-y: auto;
        }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .page-title h1 {
            font-size: 32px;
            color: var(--text-color);
            font-weight: 700;
            margin-bottom: 8px;
        }

        .page-title p {
            color: var(--text-light);
            font-size: 16px;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }

        .btn-primary {
            background: var(--primary-color);
            color: white;
        }

        .btn-primary:hover {
            background: #f58351;
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: var(--white);
            color: var(--text-color);
            border: 1px solid var(--border-color);
        }

        .btn-secondary:hover {
            background: var(--bg-color);
            transform: translateY(-2px);
        }

        /* Form Styles */
        .form-container {
            max-width: 800px;
            margin: 0 auto;
        }

        .form-section {
            background: var(--white);
            border-radius: 16px;
            padding: 30px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border: 1px solid var(--border-color);
        }

        .section-header {
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .section-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-color);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--text-color);
            font-size: 14px;
        }

        .form-label.required::after {
            content: " *";
            color: var(--error-color);
        }

        .form-control {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
            background: var(--white);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px var(--primary-very-light);
        }

        .form-control textarea {
            min-height: 120px;
            resize: vertical;
        }

        .form-select {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 14px;
            background: var(--white);
            cursor: pointer;
        }

        .form-select:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px var(--primary-very-light);
        }

        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: flex-end;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid var(--border-color);
        }

        .file-upload {
            position: relative;
            display: inline-block;
            width: 100%;
        }

        .file-upload-input {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 14px;
            background: var(--white);
        }

        .file-upload-label {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            border: 2px dashed var(--border-color);
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            background: var(--bg-color);
        }

        .file-upload-label:hover {
            border-color: var(--primary-color);
            background: var(--primary-very-light);
        }

        .file-upload-label i {
            color: var(--primary-color);
            font-size: 20px;
        }

        .file-upload-input {
            display: none;
        }

        .help-text {
            font-size: 12px;
            color: var(--text-light);
            margin-top: 5px;
        }

        .social-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .social-input-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .social-icon {
            width: 40px;
            height: 40px;
            background: var(--bg-color);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-light);
            font-size: 16px;
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
                padding: 20px;
            }
            
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .social-grid {
                grid-template-columns: 1fr;
            }
            
            .form-actions {
                flex-direction: column;
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
                <a href="company_analysis.jsp" class="menu-item">
                    <i class="fas fa-chart-bar"></i>
                    <span class="menu-text">Company Analysis</span>
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
            <div class="page-title">
                <h1>Create Company Profile</h1>
                <p>Set up your company profile to start posting jobs</p>
            </div>
            <div class="action-buttons">
                <a href="company_profile.jsp" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Profile
                </a>
            </div>
        </div>

        <div class="form-container">
            <form action="process_company_profile.jsp" method="POST" enctype="multipart/form-data">
                <!-- Basic Information -->
                <div class="form-section">
                    <div class="section-header">
                        <h3 class="section-title">
                            <i class="fas fa-info-circle"></i> Basic Information
                        </h3>
                    </div>
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label required">Company Name</label>
                            <input type="text" class="form-control" name="company_name" required 
                                   placeholder="Enter your company name">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Legal Name</label>
                            <input type="text" class="form-control" name="legal_name" 
                                   placeholder="Legal business name (if different)">
                        </div>
                        <div class="form-group">
                            <label class="form-label required">Company Email</label>
                            <input type="email" class="form-control" name="company_email" required 
                                   placeholder="company@example.com">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Phone Number</label>
                            <input type="tel" class="form-control" name="phone" 
                                   placeholder="+1 (555) 123-4567">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Website</label>
                            <input type="url" class="form-control" name="website" 
                                   placeholder="https://www.example.com">
                        </div>
                        <div class="form-group">
                            <label class="form-label required">Industry</label>
                            <select class="form-select" name="industry" required>
                                <option value="">Select Industry</option>
                                <option value="Technology">Technology</option>
                                <option value="Healthcare">Healthcare</option>
                                <option value="Finance">Finance</option>
                                <option value="Education">Education</option>
                                <option value="Manufacturing">Manufacturing</option>
                                <option value="Retail">Retail</option>
                                <option value="Hospitality">Hospitality</option>
                                <option value="Real Estate">Real Estate</option>
                                <option value="Marketing">Marketing</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label required">Company Size</label>
                            <select class="form-select" name="company_size" required>
                                <option value="">Select Company Size</option>
                                <option value="1-10">1-10 employees</option>
                                <option value="11-50">11-50 employees</option>
                                <option value="51-200">51-200 employees</option>
                                <option value="201-500">201-500 employees</option>
                                <option value="501-1000">501-1000 employees</option>
                                <option value="1000+">1000+ employees</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Founded Year</label>
                            <input type="number" class="form-control" name="founded_year" 
                                   min="1900" max="<%= java.time.Year.now().getValue() %>"
                                   placeholder="1990">
                        </div>
                    </div>
                </div>

                <!-- Company Description -->
                <div class="form-section">
                    <div class="section-header">
                        <h3 class="section-title">
                            <i class="fas fa-file-alt"></i> Company Description
                        </h3>
                    </div>
                    <div class="form-group">
                        <label class="form-label required">Company Description</label>
                        <textarea class="form-control" name="description" required 
                                  placeholder="Describe your company, what you do, your values, and what makes you unique..."></textarea>
                        <div class="help-text">This will be displayed on your company profile and job postings</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Mission Statement</label>
                        <textarea class="form-control" name="mission" 
                                  placeholder="What is your company's mission and purpose?"></textarea>
                    </div>
                </div>

                <!-- Company Logo -->
                <div class="form-section">
                    <div class="section-header">
                        <h3 class="section-title">
                            <i class="fas fa-image"></i> Company Logo
                        </h3>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Upload Company Logo</label>
                        <div class="file-upload">
                            <label class="file-upload-label">
                                <i class="fas fa-cloud-upload-alt"></i>
                                <span>Choose logo file (PNG, JPG, max 2MB)</span>
                                <input type="file" class="file-upload-input" name="logo" accept=".jpg,.jpeg,.png">
                            </label>
                        </div>
                        <div class="help-text">Recommended size: 400x400 pixels. Square images work best.</div>
                    </div>
                </div>

                <!-- Address Information -->
                <div class="form-section">
                    <div class="section-header">
                        <h3 class="section-title">
                            <i class="fas fa-map-marker-alt"></i> Address Information
                        </h3>
                    </div>
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label class="form-label">Address Line 1</label>
                            <input type="text" class="form-control" name="address_line_1" 
                                   placeholder="Street address, P.O. box">
                        </div>
                        <div class="form-group full-width">
                            <label class="form-label">Address Line 2</label>
                            <input type="text" class="form-control" name="address_line_2" 
                                   placeholder="Apartment, suite, unit, building, floor, etc.">
                        </div>
                        <div class="form-group">
                            <label class="form-label">City</label>
                            <input type="text" class="form-control" name="city" 
                                   placeholder="City">
                        </div>
                        <div class="form-group">
                            <label class="form-label">State/Province</label>
                            <input type="text" class="form-control" name="state" 
                                   placeholder="State or province">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Country</label>
                            <input type="text" class="form-control" name="country" 
                                   placeholder="Country">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Postal Code</label>
                            <input type="text" class="form-control" name="postal_code" 
                                   placeholder="ZIP or postal code">
                        </div>
                    </div>
                </div>

                <!-- Social Media -->
                <div class="form-section">
                    <div class="section-header">
                        <h3 class="section-title">
                            <i class="fas fa-share-alt"></i> Social Media Links
                        </h3>
                    </div>
                    <div class="social-grid">
                        <div class="form-group">
                            <div class="social-input-group">
                                <div class="social-icon">
                                    <i class="fab fa-linkedin-in"></i>
                                </div>
                                <input type="url" class="form-control" name="linkedin_url" 
                                       placeholder="LinkedIn Company URL">
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="social-input-group">
                                <div class="social-icon">
                                    <i class="fab fa-twitter"></i>
                                </div>
                                <input type="url" class="form-control" name="twitter_url" 
                                       placeholder="Twitter Profile URL">
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="social-input-group">
                                <div class="social-icon">
                                    <i class="fab fa-facebook-f"></i>
                                </div>
                                <input type="url" class="form-control" name="facebook_url" 
                                       placeholder="Facebook Page URL">
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="social-input-group">
                                <div class="social-icon">
                                    <i class="fab fa-instagram"></i>
                                </div>
                                <input type="url" class="form-control" name="instagram_url" 
                                       placeholder="Instagram Profile URL">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Form Actions -->
                <div class="form-section">
                    <div class="form-actions">
                        <a href="company_profile.jsp" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Create Company Profile
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script>
        document.getElementById('toggleSidebar').addEventListener('click', function() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
        });

        // File upload preview
        const fileInput = document.querySelector('input[type="file"]');
        fileInput.addEventListener('change', function(e) {
            const fileName = e.target.files[0]?.name;
            if (fileName) {
                const label = fileInput.parentElement;
                label.querySelector('span').textContent = fileName;
            }
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