<%@ page import="java.sql.*, java.util.*" %>
<%
    // Check if recruiter is logged in
    String userName = (String) session.getAttribute("userName");
    String userType = (String) session.getAttribute("userType");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userName == null || !"recruiter".equals(userType)) {
%>
        <script>window.location.href = "login.jsp";</script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Post a Job | JobPortal</title>
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

        .page-header {
            margin-bottom: 40px;
        }

        .page-header h1 {
            font-size: 32px;
            color: var(--text-color);
            font-weight: 700;
            margin-bottom: 10px;
        }

        .page-header p {
            color: var(--text-light);
            font-size: 16px;
        }

        .form-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .form-section {
            background: var(--white);
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
        }

        .section-title {
            color: var(--text-color);
            margin-bottom: 25px;
            font-size: 20px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-title i {
            color: var(--primary-color);
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--text-color);
            font-size: 14px;
        }

        .required::after {
            content: " *";
            color: #e74c3c;
        }

        input, textarea, select {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid var(--border-color);
            border-radius: 8px;
            font-size: 15px;
            transition: all 0.3s ease;
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
            background: var(--primary-very-light);
            padding: 25px;
            margin-bottom: 20px;
            border-radius: 12px;
            border-left: 4px solid var(--primary-color);
            transition: transform 0.2s ease;
        }

        .custom-field:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        }

        .field-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
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
            font-size: 14px;
            font-weight: 600;
            margin-right: 12px;
        }

        .toggle-field {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .toggle-switch {
            position: relative;
            display: inline-block;
            width: 50px;
            height: 24px;
        }

        .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: .4s;
            border-radius: 24px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 16px;
            width: 16px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: var(--primary-color);
        }

        input:checked + .slider:before {
            transform: translateX(26px);
        }

        .field-content {
            margin-top: 15px;
        }

        .field-info {
            background: #e7f3ff;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #2196F3;
            font-size: 14px;
            color: var(--text-color);
        }

        .custom-field {
            display: none;
        }

        .custom-field.active {
            display: block;
        }

        .fields-counter {
            text-align: center;
            color: var(--text-light);
            font-size: 14px;
            margin-bottom: 15px;
            padding: 10px;
            background: var(--bg-color);
            border-radius: 8px;
        }

        .max-fields-message {
            text-align: center;
            color: #e74c3c;
            font-size: 14px;
            margin-top: 10px;
            display: none;
            padding: 10px;
            background: #ffeaea;
            border-radius: 8px;
        }

        .form-actions {
            text-align: center;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 2px solid var(--border-color);
        }

        .btn {
            padding: 16px 32px;
            background: var(--primary-color);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            margin: 0 10px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            font-size: 16px;
        }

        .btn:hover {
            background: #e0865c;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(250, 151, 106, 0.3);
        }

        .btn-secondary {
            background: var(--text-light);
        }

        .btn-secondary:hover {
            background: #5a6268;
        }

        .btn-add-field {
            background: transparent;
            color: var(--primary-color);
            border: 2px solid var(--primary-color);
            padding: 12px 24px;
        }

        .btn-add-field:hover {
            background: var(--primary-very-light);
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
                padding: 20px;
            }
            
            .form-section {
                padding: 20px;
            }
            
            .btn {
                padding: 14px 24px;
                font-size: 14px;
                margin: 5px;
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
                <a href="post_job.jsp" class="menu-item active">
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
                <a href="company_profile.jsp" class="menu-item">
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
        <div class="page-header">
            <h1>Post a New Job</h1>
            <p>Create a new job posting to attract qualified candidates</p>
        </div>

        <div class="form-container">
            <form action="post_job_process.jsp" method="post" id="jobForm">
                <input type="hidden" name="recruiter_id" value="<%= userId %>">
                
                <!-- Basic Job Information -->
                <div class="form-section">
                    <h2 class="section-title">
                        <i class="fas fa-info-circle"></i> Basic Job Information
                    </h2>
                    
                    <div class="form-group">
                        <label class="required">Job Title</label>
                        <input type="text" name="job_title" required placeholder="e.g., Senior Software Engineer">
                    </div>
                    
                    <div class="form-group">
                        <label class="required">Company Name</label>
                        <input type="text" name="company_name" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="required">Job Description</label>
                        <textarea name="job_description" required placeholder="Describe the role, responsibilities, and expectations for this position"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label class="required">Requirements</label>
                        <textarea name="requirements" required placeholder="List required skills, qualifications, and experience"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label class="required">Location</label>
                        <input type="text" name="location" required placeholder="e.g., New York, NY or Remote">
                    </div>
                    
                    <div class="form-group">
                        <label>Salary Range</label>
                        <input type="text" name="salary_range" placeholder="e.g., $80,000 - $100,000">
                    </div>
                    
                    <div class="form-group">
                        <label class="required">Job Type</label>
                        <select name="job_type" required>
                            <option value="">Select Job Type</option>
                            <option value="Full-time">Full-time</option>
                            <option value="Part-time">Part-time</option>
                            <option value="Contract">Contract</option>
                            <option value="Remote">Remote</option>
                            <option value="Internship">Internship</option>
                        </select>
                    </div>
                </div>
                
                <!-- Custom Application Form Fields -->
                <div class="form-section">
                    <h2 class="section-title">
                        <i class="fas fa-cog"></i> Custom Application Form
                    </h2>
                    
                    
                    
                    <!-- All 10 fields are in HTML but hidden initially -->
                    <% for(int i = 1; i <= 10; i++) { %>
                    <div class="custom-field" id="field-<%= i %>">
                        <div class="field-header">
                            <h4><span class="field-number"><%= i %></span> Custom Field</h4>
                            <div class="toggle-field">
                                <span>Enable this field</span>
                                <label class="toggle-switch">
                                    <input type="checkbox" name="custom_field<%= i %>_enabled" value="true">
                                    <span class="slider"></span>
                                </label>
                            </div>
                        </div>
                        
                        <div class="field-content">
                            <div class="form-group">
                                <label>Field Label</label>
                                <input type="text" name="custom_field<%= i %>_name" placeholder="e.g., Portfolio URL, Years of Experience">
                            </div>
                            
                            <div class="form-group">
                                <label>Field Type</label>
                                <select name="custom_field<%= i %>_type">
                                    <option value="">Select field type</option>
                                    <option value="text">Text Input</option>
                                    <option value="textarea">Text Area</option>
                                    <option value="select">Dropdown</option>
                                    <option value="email">Email</option>
                                    <option value="number">Number</option>
                                    <option value="url">URL</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    
                    <div style="text-align: center; margin-top: 20px;">
                        <button type="button" class="btn btn-add-field" onclick="addCustomField()" id="addFieldBtn">
                            <i class="fas fa-plus"></i> Add Custom Field
                        </button>
                    </div>
                    
                    <div class="max-fields-message" id="maxFieldsMessage">
                        Maximum of 10 custom fields reached
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn">
                        <i class="fas fa-paper-plane"></i> Post Job
                    </button>
                    <a href="recruiter_dashboard.jsp" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
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

        let activeFieldCount = 0;
        
        function addCustomField() {
            if (activeFieldCount >= 10) {
                document.getElementById('maxFieldsMessage').style.display = 'block';
                return;
            }
            
            activeFieldCount++;
            
            // Show the next field
            const nextField = document.getElementById('field-' + activeFieldCount);
            if (nextField) {
                nextField.classList.add('active');
                // Check the checkbox when field is shown
                const checkbox = nextField.querySelector('input[type="checkbox"]');
                if (checkbox) {
                    checkbox.checked = true;
                }
            }
            
            updateFieldsCounter();
            
            // Hide add button if reached max
            if (activeFieldCount >= 10) {
                document.getElementById('addFieldBtn').style.display = 'none';
                document.getElementById('maxFieldsMessage').style.display = 'block';
            }
        }
        
        function updateFieldsCounter() {
            document.getElementById('activeFieldsCount').textContent = activeFieldCount;
        }
        
        // Show first field by default when page loads
        document.addEventListener('DOMContentLoaded', function() {
            addCustomField(); // Show the first field automatically
        });
    </script>
</body>
</html>