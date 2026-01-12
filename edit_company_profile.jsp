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

    // Company data variables
    Map<String, Object> company = new HashMap<>();
    Map<String, Object> address = new HashMap<>();
    String logoPath = null;
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

        // Get company data
        String companySql = "SELECT * FROM companies WHERE user_id = ?";
        stmt = conn.prepareStatement(companySql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            hasCompany = true;
            company.put("id", rs.getInt("id"));
            company.put("company_name", rs.getString("company_name"));
            company.put("legal_name", rs.getString("legal_name"));
            company.put("company_email", rs.getString("company_email"));
            company.put("phone", rs.getString("phone"));
            company.put("website", rs.getString("website"));
            company.put("industry", rs.getString("industry"));
            company.put("company_size", rs.getString("company_size"));
            company.put("founded_year", rs.getInt("founded_year"));
            company.put("description", rs.getString("description"));
            company.put("mission", rs.getString("mission"));
            company.put("linkedin_url", rs.getString("linkedin_url"));
            company.put("twitter_url", rs.getString("twitter_url"));
            company.put("facebook_url", rs.getString("facebook_url"));
            company.put("instagram_url", rs.getString("instagram_url"));
        }
        
        // Get company address
        if (hasCompany) {
            String addressSql = "SELECT * FROM company_addresses WHERE company_id = ? AND is_primary = TRUE";
            stmt = conn.prepareStatement(addressSql);
            stmt.setInt(1, (Integer) company.get("id"));
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                address.put("address_line_1", rs.getString("address_line_1"));
                address.put("address_line_2", rs.getString("address_line_2"));
                address.put("city", rs.getString("city"));
                address.put("state", rs.getString("state"));
                address.put("country", rs.getString("country"));
                address.put("postal_code", rs.getString("postal_code"));
            }
            
            // Get company logo
            String logoSql = "SELECT file_path FROM company_media WHERE company_id = ? AND file_type = 'logo' AND is_active = TRUE LIMIT 1";
            stmt = conn.prepareStatement(logoSql);
            stmt.setInt(1, (Integer) company.get("id"));
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                logoPath = rs.getString("file_path");
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); if (stmt != null) stmt.close(); if (conn != null) conn.close(); } catch (SQLException e) {}
    }

    if (!hasCompany) {
        response.sendRedirect("create_company_profile.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Company Profile | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Include all the same CSS styles from create_company_profile.jsp */
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

        /* Include all your existing sidebar styles exactly as in create_company_profile.jsp */
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

        /* ... (Include all the same CSS as create_company_profile.jsp) ... */

        .current-logo {
            text-align: center;
            margin-bottom: 20px;
        }

        .current-logo img {
            width: 120px;
            height: 120px;
            border-radius: 12px;
            object-fit: cover;
            border: 2px solid var(--border-color);
        }

        .current-logo p {
            margin-top: 10px;
            color: var(--text-light);
            font-size: 14px;
        }

        .remove-logo {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            color: var(--error-color);
            text-decoration: none;
            font-size: 14px;
            margin-top: 5px;
        }

        .remove-logo:hover {
            text-decoration: underline;
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
                <h1>Edit Company Profile</h1>
                <p>Update your company information and branding</p>
            </div>
            <div class="action-buttons">
                <a href="company_profile.jsp" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Profile
                </a>
            </div>
        </div>

        <div class="form-container">
            <form action="process_company_profile.jsp?action=update" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="company_id" value="<%= company.get("id") %>">
                
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
                                   value="<%= company.get("company_name") != null ? company.get("company_name") : "" %>"
                                   placeholder="Enter your company name">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Legal Name</label>
                            <input type="text" class="form-control" name="legal_name" 
                                   value="<%= company.get("legal_name") != null ? company.get("legal_name") : "" %>"
                                   placeholder="Legal business name (if different)">
                        </div>
                        <div class="form-group">
                            <label class="form-label required">Company Email</label>
                            <input type="email" class="form-control" name="company_email" required 
                                   value="<%= company.get("company_email") != null ? company.get("company_email") : "" %>"
                                   placeholder="company@example.com">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Phone Number</label>
                            <input type="tel" class="form-control" name="phone" 
                                   value="<%= company.get("phone") != null ? company.get("phone") : "" %>"
                                   placeholder="+1 (555) 123-4567">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Website</label>
                            <input type="url" class="form-control" name="website" 
                                   value="<%= company.get("website") != null ? company.get("website") : "" %>"
                                   placeholder="https://www.example.com">
                        </div>
                        <div class="form-group">
                            <label class="form-label required">Industry</label>
                            <select class="form-select" name="industry" required>
                                <option value="">Select Industry</option>
                                <option value="Technology" <%= "Technology".equals(company.get("industry")) ? "selected" : "" %>>Technology</option>
                                <option value="Healthcare" <%= "Healthcare".equals(company.get("industry")) ? "selected" : "" %>>Healthcare</option>
                                <option value="Finance" <%= "Finance".equals(company.get("industry")) ? "selected" : "" %>>Finance</option>
                                <option value="Education" <%= "Education".equals(company.get("industry")) ? "selected" : "" %>>Education</option>
                                <option value="Manufacturing" <%= "Manufacturing".equals(company.get("industry")) ? "selected" : "" %>>Manufacturing</option>
                                <option value="Retail" <%= "Retail".equals(company.get("industry")) ? "selected" : "" %>>Retail</option>
                                <option value="Hospitality" <%= "Hospitality".equals(company.get("industry")) ? "selected" : "" %>>Hospitality</option>
                                <option value="Real Estate" <%= "Real Estate".equals(company.get("industry")) ? "selected" : "" %>>Real Estate</option>
                                <option value="Marketing" <%= "Marketing".equals(company.get("industry")) ? "selected" : "" %>>Marketing</option>
                                <option value="Other" <%= "Other".equals(company.get("industry")) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label required">Company Size</label>
                            <select class="form-select" name="company_size" required>
                                <option value="">Select Company Size</option>
                                <option value="1-10" <%= "1-10".equals(company.get("company_size")) ? "selected" : "" %>>1-10 employees</option>
                                <option value="11-50" <%= "11-50".equals(company.get("company_size")) ? "selected" : "" %>>11-50 employees</option>
                                <option value="51-200" <%= "51-200".equals(company.get("company_size")) ? "selected" : "" %>>51-200 employees</option>
                                <option value="201-500" <%= "201-500".equals(company.get("company_size")) ? "selected" : "" %>>201-500 employees</option>
                                <option value="501-1000" <%= "501-1000".equals(company.get("company_size")) ? "selected" : "" %>>501-1000 employees</option>
                                <option value="1000+" <%= "1000+".equals(company.get("company_size")) ? "selected" : "" %>>1000+ employees</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Founded Year</label>
                            <input type="number" class="form-control" name="founded_year" 
                                   value="<%= company.get("founded_year") != null ? company.get("founded_year") : "" %>"
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
                                  placeholder="Describe your company, what you do, your values, and what makes you unique..."><%= company.get("description") != null ? company.get("description") : "" %></textarea>
                        <div class="help-text">This will be displayed on your company profile and job postings</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Mission Statement</label>
                        <textarea class="form-control" name="mission" 
                                  placeholder="What is your company's mission and purpose?"><%= company.get("mission") != null ? company.get("mission") : "" %></textarea>
                    </div>
                </div>

                <!-- Company Logo -->
                <div class="form-section">
                    <div class="section-header">
                        <h3 class="section-title">
                            <i class="fas fa-image"></i> Company Logo
                        </h3>
                    </div>
                    <% if (logoPath != null) { %>
                    <div class="current-logo">
                        <img src="<%= logoPath %>" alt="Current Company Logo">
                        <p>Current Logo</p>
                        <a href="process_company_profile.jsp?action=remove_logo&company_id=<%= company.get("id") %>" class="remove-logo">
                            <i class="fas fa-trash"></i> Remove Logo
                        </a>
                    </div>
                    <% } %>
                    <div class="form-group">
                        <label class="form-label"><%= logoPath != null ? "Update Company Logo" : "Upload Company Logo" %></label>
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
                                   value="<%= address.get("address_line_1") != null ? address.get("address_line_1") : "" %>"
                                   placeholder="Street address, P.O. box">
                        </div>
                        <div class="form-group full-width">
                            <label class="form-label">Address Line 2</label>
                            <input type="text" class="form-control" name="address_line_2" 
                                   value="<%= address.get("address_line_2") != null ? address.get("address_line_2") : "" %>"
                                   placeholder="Apartment, suite, unit, building, floor, etc.">
                        </div>
                        <div class="form-group">
                            <label class="form-label">City</label>
                            <input type="text" class="form-control" name="city" 
                                   value="<%= address.get("city") != null ? address.get("city") : "" %>"
                                   placeholder="City">
                        </div>
                        <div class="form-group">
                            <label class="form-label">State/Province</label>
                            <input type="text" class="form-control" name="state" 
                                   value="<%= address.get("state") != null ? address.get("state") : "" %>"
                                   placeholder="State or province">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Country</label>
                            <input type="text" class="form-control" name="country" 
                                   value="<%= address.get("country") != null ? address.get("country") : "" %>"
                                   placeholder="Country">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Postal Code</label>
                            <input type="text" class="form-control" name="postal_code" 
                                   value="<%= address.get("postal_code") != null ? address.get("postal_code") : "" %>"
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
                                       value="<%= company.get("linkedin_url") != null ? company.get("linkedin_url") : "" %>"
                                       placeholder="LinkedIn Company URL">
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="social-input-group">
                                <div class="social-icon">
                                    <i class="fab fa-twitter"></i>
                                </div>
                                <input type="url" class="form-control" name="twitter_url" 
                                       value="<%= company.get("twitter_url") != null ? company.get("twitter_url") : "" %>"
                                       placeholder="Twitter Profile URL">
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="social-input-group">
                                <div class="social-icon">
                                    <i class="fab fa-facebook-f"></i>
                                </div>
                                <input type="url" class="form-control" name="facebook_url" 
                                       value="<%= company.get("facebook_url") != null ? company.get("facebook_url") : "" %>"
                                       placeholder="Facebook Page URL">
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="social-input-group">
                                <div class="social-icon">
                                    <i class="fab fa-instagram"></i>
                                </div>
                                <input type="url" class="form-control" name="instagram_url" 
                                       value="<%= company.get("instagram_url") != null ? company.get("instagram_url") : "" %>"
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
                            <i class="fas fa-save"></i> Update Company Profile
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