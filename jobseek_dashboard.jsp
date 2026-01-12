<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
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
    
    // Initialize variables for job data
    int appliedJobsCount = 0;
    int profileViews = 0;
    int interviews = 0;
    int profileStrength = 87;

    // Database connection details
    String url = "jdbc:mysql://localhost:3306/jobportal";
    String dbUsername = "root";
    String dbPassword = "navya@2006";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        
        // Get actual application count from database
        String countSql = "SELECT COUNT(*) as app_count FROM job_applications WHERE job_seeker_id = ?";
        stmt = conn.prepareStatement(countSql);
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            appliedJobsCount = rs.getInt("app_count");
        }
        rs.close();
        stmt.close();

        // Debug output
        System.out.println("=== DASHBOARD STATS ===");
        System.out.println("User ID: " + userId);
        System.out.println("Applications found: " + appliedJobsCount);

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
    <title>Job Seeker Dashboard | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
            --success: #28a745;
            --warning: #ffc107;
            --card-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
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

        /* Quote Section */
        .quote-section {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-light) 100%);
            color: white;
            padding: 30px;
            border-radius: 16px;
            margin-bottom: 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .quote-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url("data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm63 31c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM34 90c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm56-76c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 63c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm57-13c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-9-21c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM60 91c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM35 41c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 60c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z' fill='%23ffffff' fill-opacity='0.1' fill-rule='evenodd'/%3E%3C/svg%3E");
            opacity: 0.3;
        }

        .quote-icon {
            font-size: 36px;
            margin-bottom: 15px;
            opacity: 0.9;
        }

        .quote-text {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 10px;
            line-height: 1.4;
        }

        .quote-author {
            font-size: 14px;
            opacity: 0.9;
            font-style: italic;
        }

        /* Stats Section */
        .stats-section {
            margin-bottom: 40px;
        }

        .section-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 25px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
        }

        .stat-card {
            background: var(--white);
            padding: 25px;
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            transition: transform 0.3s, box-shadow 0.3s;
            border: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            background: var(--primary-very-light);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 24px;
        }

        .stat-content {
            flex: 1;
        }

        .stat-content h3 {
            color: var(--text-light);
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .count {
            font-size: 32px;
            font-weight: 800;
            color: var(--primary-color);
            line-height: 1;
            margin-bottom: 5px;
        }

        .stat-trend {
            font-size: 12px;
            color: var(--text-light);
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .stat-trend.positive {
            color: #10b981;
        }

        .stat-trend.negative {
            color: #ef4444;
        }

        /* Jobs Section */
        .jobs-section {
            margin-bottom: 40px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .view-all {
            color: var(--primary-color);
            font-weight: 600;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 5px;
            transition: var(--transition);
        }

        .view-all:hover {
            gap: 8px;
        }

        /* Vertical Job List */
        .jobs-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .job-card {
            background: var(--white);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: var(--card-shadow);
            transition: var(--transition);
            border-left: 4px solid var(--primary-color);
            display: flex;
            flex-direction: column;
        }

        .job-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }

        .job-header {
            padding: 25px;
            border-bottom: 1px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .job-info {
            flex: 1;
        }

        .job-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            color: var(--text-color);
        }

        .job-company {
            color: var(--primary-color);
            font-weight: 600;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 1.1rem;
        }

        .job-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 1.5rem;
            margin-top: 1rem;
        }

        .job-meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
            color: var(--text-light);
        }

        .job-meta-item i {
            color: var(--primary-color);
        }

        .job-body {
            padding: 25px;
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 20px;
        }

        .job-content {
            flex: 1;
        }

        .job-description {
            color: var(--text-light);
            margin-bottom: 1.5rem;
            line-height: 1.6;
        }

        .job-skills {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }

        .skill-tag {
            background: var(--primary-very-light);
            color: var(--primary-color);
            padding: 0.4rem 1rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
        }

        .job-actions {
            display: flex;
            gap: 0.8rem;
            align-items: center;
            flex-shrink: 0;
        }

        .btn {
            padding: 0.7rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            border: none;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
            text-decoration: none;
        }

        .btn-primary {
            background: var(--primary-color);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-light);
        }

        .btn-secondary {
            background: transparent;
            color: var(--primary-color);
            border: 1px solid var(--primary-color);
        }

        .btn-secondary:hover {
            background: var(--primary-very-light);
        }

        /* Company Icon */
        .company-icon-container {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .company-icon {
            width: 40px;
            height: 40px;
            background: var(--primary-light);
            color: var(--primary-color);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: var(--transition);
            font-size: 1.1rem;
        }

        .company-icon:hover {
            background: var(--primary-color);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(250, 151, 106, 0.3);
        }

        /* Tooltip */
        .company-icon-container:hover::after {
            content: "View Company Profile";
            position: absolute;
            bottom: -35px;
            left: 50%;
            transform: translateX(-50%);
            background: var(--text-color);
            color: white;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 0.8rem;
            white-space: nowrap;
            z-index: 1000;
        }

        .company-icon-container:hover::before {
            content: "";
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            border: 5px solid transparent;
            border-bottom-color: var(--text-color);
            z-index: 1000;
        }

        /* Company Profile Modal */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 1000;
            backdrop-filter: blur(5px);
        }

        .modal-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: var(--white);
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.2);
            width: 90%;
            max-width: 800px;
            max-height: 90vh;
            overflow-y: auto;
            animation: modalSlideIn 0.3s ease;
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translate(-50%, -60%);
            }
            to {
                opacity: 1;
                transform: translate(-50%, -50%);
            }
        }

        .modal-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-light) 100%);
            color: white;
            padding: 2rem;
            border-radius: 20px 20px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h2 {
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0;
        }

        .close-modal {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: var(--transition);
            font-size: 1.2rem;
        }

        .close-modal:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: rotate(90deg);
        }

        .modal-body {
            padding: 2rem;
        }

        .company-header {
            display: flex;
            align-items: center;
            gap: 1.5rem;
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 2px solid var(--primary-light);
        }

        .company-logo {
            width: 80px;
            height: 80px;
            background: var(--primary-light);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 2rem;
            font-weight: 700;
        }

        .company-info h3 {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 0.5rem;
        }

        .company-website {
            margin-top: 8px;
        }

        .company-website a {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 6px;
            transition: all 0.3s ease;
            color: white;
            text-decoration: none;
        }

        .company-website a:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }

        .company-section {
            margin-bottom: 2rem;
        }

        .modal-section-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--text-color);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .modal-section-title i {
            color: var(--primary-color);
        }

        .company-description {
            color: var(--text-light);
            line-height: 1.7;
            background: var(--bg-color);
            padding: 1.5rem;
            border-radius: 12px;
            border-left: 4px solid var(--primary-color);
        }

        .company-mission {
            margin-top: 20px;
            padding: 15px;
            background: var(--primary-very-light);
            border-radius: 8px;
            border-left: 4px solid var(--primary-color);
        }

        .company-mission h5 {
            color: var(--primary-color);
            margin-bottom: 8px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .company-mission p {
            color: var(--text-color);
            line-height: 1.6;
            margin: 0;
        }

        .company-details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 1.5rem;
        }

        .detail-card {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 20px;
            background: var(--bg-color);
            border-radius: 12px;
            transition: var(--transition);
            border: 1px solid var(--border-color);
        }

        .detail-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
        }

        .detail-icon {
            width: 50px;
            height: 50px;
            background: var(--primary-light);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 1.2rem;
            flex-shrink: 0;
        }

        .detail-content h4 {
            font-size: 0.85rem;
            color: var(--text-light);
            margin-bottom: 0.3rem;
            font-weight: 600;
        }

        .detail-content p {
            font-weight: 700;
            color: var(--text-color);
            font-size: 1rem;
            margin: 0;
        }

        .address-card {
            display: flex;
            gap: 20px;
            padding: 25px;
            background: var(--bg-color);
            border-radius: 12px;
            border-left: 4px solid var(--primary-color);
        }

        .address-icon {
            width: 50px;
            height: 50px;
            background: var(--primary-light);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
            font-size: 1.2rem;
            flex-shrink: 0;
        }

        .address-content {
            flex: 1;
        }

        .address-content p {
            margin: 4px 0;
            color: var(--text-color);
            font-weight: 500;
        }

        .social-links-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 15px;
            width: 100%;
        }

        

        .social-link-card:hover {
            background: var(--primary-very-light);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(250, 151, 106, 0.2);
            border-color: var(--primary-color);
        }

        
        /* FIX: force icon to always show */
.social-link-card i {
    color: var(--primary-color) !important;
}



        /* Hide empty address lines */
        .address-content p:empty {
            display: none;
        }

        .no-jobs {
            text-align: center;
            padding: 3rem 2rem;
            background: var(--white);
            border-radius: 16px;
            box-shadow: var(--card-shadow);
        }
        
        .no-jobs-icon {
            font-size: 4rem;
            color: var(--primary-very-light);
            margin-bottom: 1rem;
        }
        
        .no-jobs h3 {
            color: var(--text-color);
            margin-bottom: 0.5rem;
        }
        
        .no-jobs p {
            color: var(--text-light);
            margin-bottom: 1.5rem;
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
        @media (max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
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
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .stat-card {
                flex-direction: column;
                text-align: center;
                gap: 15px;
            }
            
            .job-body {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .job-actions {
                width: 100%;
                justify-content: center;
            }
            
            .modal-content {
                width: 95%;
                margin: 1rem;
            }
            
            .company-header {
                flex-direction: column;
                text-align: center;
            }
            
            .company-details-grid {
                grid-template-columns: 1fr;
            }
            
            .address-card {
                flex-direction: column;
                text-align: center;
            }
            
            .social-links-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .social-link-card {
    text-decoration: none !important;
    color: inherit !important;
}

.social-link-card span {
    text-decoration: none !important;
}

        }
        /* Default background (light grey) */
.social-link-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 18px;
    border-radius: 14px;
    background: #f2f3f4;            /* LIGHT GREY */
    border: 1px solid #e0e0e0;
    text-decoration: none !important;
    color: var(--text-color) !important;
    transition: all 0.25s ease;
    min-height: 120px;
}

/* ICON styling */
.social-link-card i {
    font-size: 28px;
    margin-bottom: 8px;
    color: var(--primary-color) !important;
}

/* TEXT styling */
.social-link-card span {
    font-size: 15px;
    font-weight: 600;
    text-decoration: none !important;
    color: var(--text-color) !important;
}

/* Hover effect */
.social-link-card:hover {
    background: var(--primary-very-light);   /* Your peach light color */
    border-color: var(--primary-color);
    transform: translateY(-4px);
    box-shadow: 0 6px 16px rgba(250, 151, 106, 0.25);
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
                <a href="jobseek_dashboard.jsp" class="menu-item active">
                    <i class="fas fa-home"></i>
                    <span class="menu-text">Overview</span>
                </a>
                <a href="job_recommendations.jsp" class="menu-item">
                    <i class="fas fa-briefcase"></i>
                    <span class="menu-text">Job Recommendations</span>
                </a>
                
                <a href="application_tracker.jsp" class="menu-item">
                    <i class="fas fa-chart-line"></i>
                    <span class="menu-text">Application Tracker</span>
                </a>
                <a href="portfolio.jsp" class="menu-item">
                    <i class="fas fa-folder-open"></i>
                    <span class="menu-text">Portfolio</span>
                </a>
                <a href="profile_settings.jsp" class="menu-item">
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
                <h1>Welcome back, <%= jobSeekerName %></h1>
                <p>Here's an overview of your job search activities</p>
            </div>
        </div>

        <!-- Quote Section -->
        <div class="quote-section">
            <div class="quote-icon">
                <i class="fas fa-quote-left"></i>
            </div>
            <div class="quote-text">
                "The only way to do great work is to love what you do."
            </div>
            <div class="quote-author">- Steve Jobs</div>
        </div>

        <!-- Stats Section -->
        <div class="stats-section">
            <h2 class="section-title">Job Search Overview</h2>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-briefcase"></i>
                    </div>
                    <div class="stat-content">
                        <h3>Jobs Applied</h3>
                        <div class="count"><%= appliedJobsCount %></div>
                        <div class="stat-trend positive">
                            <i class="fas fa-arrow-up"></i>
                            <span>Active job search</span>
                        </div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-eye"></i>
                    </div>
                    <div class="stat-content">
                        <h3>Profile Views</h3>
                        <div class="count"><%= profileViews %></div>
                        <div class="stat-trend">
                            <span>Recruiter interest</span>
                        </div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-content">
                        <h3>Interviews</h3>
                        <div class="count"><%= interviews %></div>
                        <div class="stat-trend positive">
                            <i class="fas fa-arrow-up"></i>
                            <span>Progressing well</span>
                        </div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-star"></i>
                    </div>
                    <div class="stat-content">
                        <h3>Profile Strength</h3>
                        <div class="count"><%= profileStrength %>%</div>
                        <div class="stat-trend">
                            <span>Almost complete</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Jobs Section -->
        <div class="jobs-section">
            <div class="section-header">
                <h2 class="section-title">Recommended Jobs</h2>
                <a href="job_recommendations.jsp" class="view-all">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>

            <div class="jobs-list">
                <%
                Connection conn2 = null;
                PreparedStatement stmt2 = null;
                ResultSet rs2 = null;
                
                try {
                    // Database connection
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn2 = DriverManager.getConnection(url, dbUsername, dbPassword);
                    
                    // Get all jobs from database with company information
                    String sql = "SELECT j.*, c.company_name, c.description as company_description, c.industry, " +
                                "c.company_size, c.founded_year, c.website, c.linkedin_url, c.twitter_url, " +
                                "c.facebook_url, c.instagram_url, c.company_email, c.mission, " +
                                "ca.address_line_1, ca.address_line_2, ca.city, ca.state, ca.country, ca.postal_code " +
                                "FROM jobs j " +
                                "LEFT JOIN companies c ON j.recruiter_id = c.user_id " +
                                "LEFT JOIN company_addresses ca ON c.id = ca.company_id AND ca.is_primary = 1 " +
                                "ORDER BY j.created_at DESC LIMIT 10";
                    stmt2 = conn2.prepareStatement(sql);
                    rs2 = stmt2.executeQuery();
                    
                    boolean hasJobs = false;
                    
                    while (rs2.next()) {
                        hasJobs = true;
                        int jobId = rs2.getInt("id");
                        String jobTitle = rs2.getString("job_title");
                        String companyName = rs2.getString("company_name");
                        String companyDescription = rs2.getString("company_description");
                        String jobDescription = rs2.getString("job_description");
                        String jobRequirements = rs2.getString("requirements");
                        String location = rs2.getString("location");
                        String salaryRange = rs2.getString("salary_range");
                        String jobType = rs2.getString("job_type");
                        String industry = rs2.getString("industry");
                        String companySize = rs2.getString("company_size");
                        String foundedYear = rs2.getString("founded_year");
                        String website = rs2.getString("website");
                        String linkedinUrl = rs2.getString("linkedin_url");
                        String twitterUrl = rs2.getString("twitter_url");
                        String facebookUrl = rs2.getString("facebook_url");
                        String instagramUrl = rs2.getString("instagram_url");
                        String companyEmail = rs2.getString("company_email");
                        String mission = rs2.getString("mission");
                        String addressLine1 = rs2.getString("address_line_1");
                        String addressLine2 = rs2.getString("address_line_2");
                        String city = rs2.getString("city");
                        String state = rs2.getString("state");
                        String country = rs2.getString("country");
                        String postalCode = rs2.getString("postal_code");
                        java.sql.Date createdAt = rs2.getDate("created_at");
                        
                        // Extract skills from requirements for display
                        String skillsDisplay = "Not specified";
                        if (jobRequirements != null && jobRequirements.length() > 0) {
                            // Simple extraction of first few skills
                            String[] requirements = jobRequirements.split("[,\\.]");
                            if (requirements.length > 0) {
                                skillsDisplay = "";
                                int count = 0;
                                for (String req : requirements) {
                                    if (req.trim().length() > 3 && count < 3) {
                                        skillsDisplay += "<span class='skill-tag'>" + req.trim() + "</span>";
                                        count++;
                                    }
                                }
                            }
                        }
                %>
                <!-- Job Card -->
                <div class="job-card">
                    <div class="job-header">
                        <div class="job-info">
                            <h3 class="job-title"><%= jobTitle %></h3>
                            <div class="job-company">
                                <i class="fas fa-building"></i> <%= companyName %>
                            </div>
                            <div class="job-meta">
                                <div class="job-meta-item">
                                    <i class="fas fa-map-marker-alt"></i> <%= location != null ? location : "Remote" %>
                                </div>
                                <div class="job-meta-item">
                                    <i class="fas fa-dollar-sign"></i> <%= salaryRange != null ? salaryRange : "Competitive" %>
                                </div>
                                <div class="job-meta-item">
                                    <i class="fas fa-clock"></i> <%= jobType != null ? jobType : "Full-time" %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="job-body">
                        <div class="job-content">
                            <p class="job-description">
                                <%= jobDescription != null ? (jobDescription.length() > 200 ? jobDescription.substring(0, 200) + "..." : jobDescription) : "No description provided" %>
                            </p>
                            <div class="job-skills">
                                <%= skillsDisplay.equals("Not specified") ? "<span class='skill-tag'>Various Skills</span>" : skillsDisplay %>
                            </div>
                        </div>
                        <div class="job-actions">
                            <a href="apply_job.jsp?job_id=<%= jobId %>" class="btn btn-primary">
                                <i class="fas fa-paper-plane"></i> Apply Now
                            </a>
                            <div class="company-icon-container" title="View Company Profile">
                                <i class="fas fa-building view-company-profile company-icon"
                                   data-company-name="<%= companyName %>"
                                   data-company-description="<%= companyDescription != null ? companyDescription.replace("\"", "&quot;") : "No company description available." %>"
                                   data-industry="<%= industry != null ? industry : "Not specified" %>"
                                   data-company-size="<%= companySize != null ? companySize : "Not specified" %>"
                                   data-founded-year="<%= foundedYear != null ? foundedYear : "Not specified" %>"
                                   data-website="<%= website != null ? website : "" %>"
                                   data-linkedin="<%= linkedinUrl != null ? linkedinUrl : "" %>"
                                   data-twitter="<%= twitterUrl != null ? twitterUrl : "" %>"
                                   data-facebook="<%= facebookUrl != null ? facebookUrl : "" %>"
                                   data-instagram="<%= instagramUrl != null ? instagramUrl : "" %>"
                                   data-company-email="<%= companyEmail != null ? companyEmail : "" %>"
                                   data-company-mission="<%= mission != null ? mission.replace("\"", "&quot;") : "" %>"
                                   data-address-line1="<%= addressLine1 != null ? addressLine1 : "" %>"
                                   data-address-line2="<%= addressLine2 != null ? addressLine2 : "" %>"
                                   data-city="<%= city != null ? city : "" %>"
                                   data-state="<%= state != null ? state : "" %>"
                                   data-country="<%= country != null ? country : "" %>"
                                   data-postal-code="<%= postalCode != null ? postalCode : "" %>">
                                </i>
                            </div>
                            <button class="btn btn-secondary save-job" data-job-id="<%= jobId %>">
                                <i class="far fa-bookmark"></i> Save
                            </button>
                        </div>
                    </div>
                </div>
                <%
                    }
                    
                    if (!hasJobs) {
                %>
                <div class="no-jobs">
                    <div class="no-jobs-icon">
                        <i class="fas fa-briefcase"></i>
                    </div>
                    <h3>No Jobs Available</h3>
                    <p>There are currently no job postings available. Check back later for new opportunities.</p>
                    <a href="job_recommendations.jsp" class="btn btn-primary">Browse All Jobs</a>
                </div>
                <%
                    }
                    
                } catch (Exception e) {
                %>
                <div class="no-jobs">
                    <div class="no-jobs-icon">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <h3>Error Loading Jobs</h3>
                    <p>There was an error loading job recommendations. Please try again later.</p>
                    <p style="color: var(--text-light); font-size: 0.9rem; margin-top: 10px;">Error: <%= e.getMessage() %></p>
                    <a href="job_recommendations.jsp" class="btn btn-primary">Try Again</a>
                </div>
                <%
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs2 != null) rs2.close();
                        if (stmt2 != null) stmt2.close();
                        if (conn2 != null) conn2.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
                %>
            </div>
        </div>
    </div>

    <!-- Company Profile Modal -->
    <div class="modal-overlay" id="companyModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalCompanyName">Company Profile</h2>
                <button class="close-modal" id="closeModal">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <!-- Company Header -->
                <div class="company-header">
                    <div class="company-logo" id="companyLogo">
                        <i class="fas fa-building"></i>
                    </div>
                    <div class="company-info">
                        <h3 id="companyName">Company Name</h3>
                        <div class="company-website" id="companyWebsiteContainer">
                            <a id="companyWebsite" target="_blank" style="color: white; text-decoration: none;">
                                <i class="fas fa-globe"></i> Visit Website
                            </a>
                        </div>
                    </div>
                </div>

                <!-- About Company Section -->
                <div class="company-section">
                    <h4 class="modal-section-title">
                        <i class="fas fa-info-circle"></i>
                        About Company
                    </h4>
                    <div class="company-description" id="companyDescription">
                        Company description will appear here...
                    </div>
                    
                    <!-- Company Mission -->
                    <div class="company-mission">
                        <h5>
                            <i class="fas fa-bullseye"></i> Company Mission
                        </h5>
                        <p id="companyMission">
                            Mission statement will appear here...
                        </p>
                    </div>
                </div>

                <!-- Company Details Section -->
                <div class="company-section">
                    <h4 class="modal-section-title">
                        <i class="fas fa-list-alt"></i>
                        Company Details
                    </h4>
                    <div class="company-details-grid">
                        <div class="detail-card">
                            <div class="detail-icon">
                                <i class="fas fa-industry"></i>
                            </div>
                            <div class="detail-content">
                                <h4>Industry</h4>
                                <p id="detailIndustry">Not specified</p>
                            </div>
                        </div>
                        <div class="detail-card">
                            <div class="detail-icon">
                                <i class="fas fa-users"></i>
                            </div>
                            <div class="detail-content">
                                <h4>Company Size</h4>
                                <p id="detailSize">Not specified</p>
                            </div>
                        </div>
                        <div class="detail-card">
                            <div class="detail-icon">
                                <i class="fas fa-calendar-alt"></i>
                            </div>
                            <div class="detail-content">
                                <h4>Founded</h4>
                                <p id="detailFounded">Not specified</p>
                            </div>
                        </div>
                        <div class="detail-card">
                            <div class="detail-icon">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <div class="detail-content">
                                <h4>Email</h4>
                                <p id="detailEmail">Not specified</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Company Address Section -->
                <div class="company-section">
                    <h4 class="modal-section-title">
                        <i class="fas fa-map-marker-alt"></i>
                        Company Address
                    </h4>
                    <div class="address-card">
                        <div class="address-icon">
                            <i class="fas fa-building"></i>
                        </div>
                        <div class="address-content">
                            <p id="addressLine1">Address line 1</p>
                            <p id="addressLine2">Address line 2</p>
                            <p id="addressCityState">City, State</p>
                            <p id="addressCountry">Country</p>
                            <p id="addressPostalCode">Postal Code</p>
                        </div>
                    </div>
                </div>

                <!-- Social Media Section -->
                <div class="company-section">
                    <h4 class="modal-section-title">
                        <i class="fas fa-share-alt"></i>
                        Connect With Us
                    </h4>
                    <div class="social-links-grid" id="socialLinks">
                        <div style="grid-column: 1 / -1; text-align: center; padding: 2rem; color: var(--text-light); font-style: italic;">
                            <i class="fas fa-info-circle" style="font-size: 2rem; margin-bottom: 1rem; opacity: 0.5;"></i>
                            <p>Loading social links...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
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

        // Save job functionality
        const saveButtons = document.querySelectorAll('.save-job');
        saveButtons.forEach(button => {
            button.addEventListener('click', function() {
                const jobId = this.getAttribute('data-job-id');
                const icon = this.querySelector('i');
                
                if (icon.classList.contains('far')) {
                    icon.classList.remove('far');
                    icon.classList.add('fas');
                    this.style.background = 'var(--primary-very-light)';
                    
                    // In a real application, you would send an AJAX request to save the job
                    console.log('Job ' + jobId + ' saved');
                } else {
                    icon.classList.remove('fas');
                    icon.classList.add('far');
                    this.style.background = '';
                    
                    // In a real application, you would send an AJAX request to unsave the job
                    console.log('Job ' + jobId + ' unsaved');
                }
            });
        });

        // Company Profile Modal Functionality
        const modal = document.getElementById('companyModal');
        const closeModal = document.getElementById('closeModal');
        const viewCompanyButtons = document.querySelectorAll('.company-icon');

        // Open modal when View Company button is clicked
        viewCompanyButtons.forEach(button => {
            button.addEventListener('click', function() {
                const companyName = this.getAttribute('data-company-name');
                const companyDescription = this.getAttribute('data-company-description');
                const industry = this.getAttribute('data-industry');
                const companySize = this.getAttribute('data-company-size');
                const foundedYear = this.getAttribute('data-founded-year');
                const website = this.getAttribute('data-website');
                const linkedin = this.getAttribute('data-linkedin');
                const twitter = this.getAttribute('data-twitter');
                const facebook = this.getAttribute('data-facebook');
                const instagram = this.getAttribute('data-instagram');
                const companyEmail = this.getAttribute('data-company-email');
                const companyMission = this.getAttribute('data-company-mission');
                const addressLine1 = this.getAttribute('data-address-line1');
                const addressLine2 = this.getAttribute('data-address-line2');
                const city = this.getAttribute('data-city');
                const state = this.getAttribute('data-state');
                const country = this.getAttribute('data-country');
                const postalCode = this.getAttribute('data-postal-code');

                // Update modal content
                document.getElementById('modalCompanyName').textContent = companyName + ' - Company Profile';
                document.getElementById('companyName').textContent = companyName;
                document.getElementById('companyLogo').innerHTML = '<i class="fas fa-building"></i>';
                
                // Update website
                const websiteLink = document.getElementById('companyWebsite');
                const websiteContainer = document.getElementById('companyWebsiteContainer');
                if (website && website.trim() !== '') {
                    websiteLink.href = website;
                    websiteLink.innerHTML = '<i class="fas fa-globe"></i> Visit Website';
                    websiteContainer.style.display = 'block';
                 } else {
                    websiteContainer.style.display = 'none';
                }
                
                // Update company description and mission
                document.getElementById('companyDescription').textContent = companyDescription || 'No company description available.';
                document.getElementById('companyMission').textContent = companyMission || 'No mission statement available.';
                
                // Update details section
                document.getElementById('detailIndustry').textContent = industry || 'Not specified';
                document.getElementById('detailSize').textContent = companySize || 'Not specified';
                document.getElementById('detailFounded').textContent = foundedYear || 'Not specified';
                document.getElementById('detailEmail').textContent = companyEmail || 'Not specified';
                
                // Update address
                document.getElementById('addressLine1').textContent = addressLine1 || '';
                document.getElementById('addressLine2').textContent = addressLine2 || '';
                document.getElementById('addressCityState').textContent = [city, state].filter(Boolean).join(', ') || 'Not specified';
                document.getElementById('addressCountry').textContent = country || '';   
                 document.getElementById('addressPostalCode').textContent = postalCode || '';

                // Update social links - WORKING VERSION
                const socialLinksContainer = document.getElementById('socialLinks');
                socialLinksContainer.innerHTML = '';

                
       const platforms = [
  { url: linkedin, name: 'LinkedIn', icon: 'linkedin' },
  { url: twitter, name: 'Twitter', icon: 'twitter' },
  { url: facebook, name: 'Facebook', icon: 'facebook-f' },
  { url: instagram, name: 'Instagram', icon: 'instagram' },
  { url: website, name: 'Website', icon: 'globe' }
];

let hasValidLinks = false;
platforms.forEach(platform => {
  if (platform.url && platform.url.trim() !== '' && platform.url !== 'null') {
    hasValidLinks = true;

    const linkElement = document.createElement('a');
    linkElement.href = platform.url;
    linkElement.target = '_blank';
    linkElement.rel = 'noopener noreferrer';
    linkElement.className = 'social-link-card';

    // create icon element properly
    const iconEl = document.createElement('i');

    // prefer explicit FA6 class names: use 'fa-solid' for globe/website and 'fa-brands' for social brands
    if (platform.name === 'Website') {
      iconEl.className = 'fa-solid fa-' + platform.icon;
    } else {
      iconEl.className = 'fa-brands fa-' + platform.icon;
    }

    // accessibility
    iconEl.setAttribute('aria-hidden', 'true');
    iconEl.style.fontSize = '24px';

    const label = document.createElement('span');
    label.textContent = platform.name;
    label.style.marginTop = '6px';
    label.style.display = 'block';

    linkElement.appendChild(iconEl);
    linkElement.appendChild(label);
    socialLinksContainer.appendChild(linkElement);
  }
});


                      

                if (!hasValidLinks) {
                    socialLinksContainer.innerHTML = `
                        <div style="grid-column: 1 / -1; text-align: center; padding: 2rem; color: var(--text-light); font-style: italic;">
                            <i class="fas fa-info-circle" style="font-size: 2rem; margin-bottom: 1rem; opacity: 0.5;"></i>
                            <p>No social media links available for this company</p>
                        </div>
                    `;
                }

                // Show modal
                modal.style.display = 'block';
                document.body.style.overflow = 'hidden';
            });
        });

        // Close modal
        closeModal.addEventListener('click', function() {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        });

        // Close modal when clicking outside
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                modal.style.display = 'none';
                document.body.style.overflow = 'auto';
            }
        });

        // Close modal with Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && modal.style.display === 'block') {
                modal.style.display = 'none';
                document.body.style.overflow = 'auto';
            }
        });
    </script>
</body>
</html>