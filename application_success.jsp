<%@ page import="java.sql.*" %>
<%
    String jobId = request.getParameter("job_id");
    String jobTitle = "";
    
    if (jobId != null) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            String url = "jdbc:mysql://localhost:3306/jobportal";
            String username = "root";
            String password = "navya@2006";
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, username, password);
            
            String sql = "SELECT job_title FROM jobs WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(jobId));
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                jobTitle = rs.getString("job_title");
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
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Submitted | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #FA976A;
            --primary-dark: #e0865c;
            --text-dark: #2C3E50;
            --text-light: #6c757d;
            --bg-light: #f8f9fa;
            --white: #ffffff;
            --success: #28a745;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-light);
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 20px;
        }

        .success-container {
            background: var(--white);
            padding: 50px 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 600px;
            width: 100%;
            border-left: 5px solid var(--success);
        }

        .success-icon {
            font-size: 4rem;
            color: var(--success);
            margin-bottom: 25px;
        }

        h1 {
            color: var(--text-dark);
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 15px;
        }

        .job-title {
            color: var(--primary);
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 20px;
            padding: 8px 20px;
            background: #fce0d5;
            border-radius: 25px;
            display: inline-block;
        }

        p {
            color: var(--text-light);
            font-size: 1.1rem;
            line-height: 1.6;
            margin-bottom: 30px;
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            padding: 12px 24px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-success {
            background: var(--success);
            color: white;
        }

        .btn-secondary {
            background: var(--text-light);
            color: white;
        }

        .btn:hover {
            opacity: 0.9;
            transform: translateY(-2px);
        }

        @media (max-width: 768px) {
            .success-container {
                padding: 40px 25px;
            }
            
            h1 {
                font-size: 1.8rem;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="success-container">
        <div class="success-icon">✅</div>
        <h1>Application Submitted Successfully!</h1>
        
        <% if (!jobTitle.isEmpty()) { %>
            <div class="job-title">
                <i class="fas fa-briefcase"></i> <%= jobTitle %>
            </div>
        <% } %>
        
        <p>
            Your application has been successfully submitted to the recruiter. 
            They will review your qualifications and contact you if you're shortlisted for the next stage.
        </p>
        
        <div class="action-buttons">
            <a href="jobseek_dashboard.jsp" class="btn btn-primary">
                <i class="fas fa-home"></i> Back to Dashboard
            </a>
            <a href="application_tracker.jsp" class="btn btn-success">
                <i class="fas fa-file-alt"></i> Track Applications
            </a>
            <a href="job_recommendations.jsp" class="btn btn-secondary">
                <i class="fas fa-search"></i> Find More Jobs
            </a>
        </div>
    </div>
</body>
</html>