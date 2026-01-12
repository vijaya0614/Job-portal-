<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
    :root {
        --primary: #f8a078;
        --primary-dark: #d17855;
        --primary-light: #ffc9b3;
        --gradient: linear-gradient(135deg, #FA976A 0%, #FF7B54 100%);
        --glass-bg: rgba(255, 255, 255, 0.1);
        --glass-border: rgba(255, 255, 255, 0.2);
        --text: #2C3E50;
        --text-light: #6c7a89;
        --white: #ffffff;
        --shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
        --transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }

    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Inter', sans-serif;
    }

    body {
        background: linear-gradient(135deg, #FA976A 0%, #FF7B54 100%);
        display: flex;
        height: 100vh;
        overflow: hidden;
        position: relative;
    }

    body::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: 
            radial-gradient(circle at 20% 80%, rgba(250, 151, 106, 0.3) 0%, transparent 50%),
            radial-gradient(circle at 80% 20%, rgba(255, 123, 84, 0.2) 0%, transparent 50%),
            radial-gradient(circle at 40% 40%, rgba(255, 193, 179, 0.2) 0%, transparent 50%);
        animation: float 6s ease-in-out infinite;
    }

    @keyframes float {
        0%, 100% { transform: translateY(0px) rotate(0deg); }
        50% { transform: translateY(-20px) rotate(1deg); }
    }

    /* Left Section - Visual Content */
    .visual-section {
    flex: 1;
    width: 20%;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 60px;
    position: relative;
    overflow: hidden;
    background: var(--white); /* Add white background */
}

    .visual-content {
        max-width: 500px;
        text-align: center;
        z-index: 2;
        position: relative;
    }

    .glass-card {
    background: rgba(255, 255, 255, 0.9); /* Change to white background */
    backdrop-filter: blur(20px);
    border: 1px solid rgba(250, 151, 106, 0.2); /* Orange border */
    border-radius: 24px;
    padding: 50px 40px;
    box-shadow: var(--shadow);
    position: relative;
    overflow: hidden;
}

    .glass-card::before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: linear-gradient(45deg, transparent, rgba(255,255,255,0.1), transparent);
        transform: rotate(45deg);
        animation: shine 3s ease-in-out infinite;
    }

    @keyframes shine {
        0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
        100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
    }

    .visual-icon {
    font-size: 64px;
    margin-bottom: 30px;
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%); /* Orange gradient */
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    filter: drop-shadow(0 10px 20px rgba(0,0,0,0.1));
}

    .visual-title {
    font-size: 42px;
    font-weight: 800;
    margin-bottom: 20px;
    line-height: 1.2;
    color: var(--text); /* Dark text color */
    letter-spacing: -0.5px;
}

    .visual-subtitle {
    font-size: 18px;
    line-height: 1.6;
    margin-bottom: 40px;
    color: var(--text-light) !important; /* Light text color */
    font-weight: 400;
    opacity: 1 !important;
}

    .features-list {
        text-align: left;
        margin-top: 40px;
    }

    .feature-item {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
    font-size: 16px;
    color: var(--text) !important; /* Dark text color */
    font-weight: 500;
    opacity: 1 !important;
}

.feature-icon {
    width: 32px;
    height: 32px;
    background: rgba(250, 151, 106, 0.1); /* Light orange background */
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 15px;
    font-size: 14px;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(250, 151, 106, 0.2); /* Orange border */
    color: var(--primary); /* Orange icon color */
}
    /* Right Section - Registration Form */
    .form-section-container {
        flex: 1;
        width: 80%;
        display: flex;
        flex-direction: column;
        padding: 60px;
        position: relative;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        border-left: 1px solid rgba(255, 255, 255, 0.2);
        overflow-y: auto;
        max-height: 100vh;
    }

    .logo {
        font-size: 32px;
        font-weight: 800;
        color: var(--text);
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 50px;
        letter-spacing: -0.5px;
    }

    .logo i {
        background: var(--gradient);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-size: 36px;
    }

    .toggle-buttons {
        display: flex;
        background: rgba(250, 151, 106, 0.1);
        border-radius: 16px;
        margin-bottom: 40px;
        padding: 6px;
        border: 1px solid rgba(250, 151, 106, 0.2);
        backdrop-filter: blur(10px);
    }

    .toggle-btn {
        flex: 1;
        padding: 16px 0;
        border: none;
        background: transparent;
        border-radius: 12px;
        font-weight: 600;
        font-size: 15px;
        color: var(--text-light);
        cursor: pointer;
        transition: var(--transition);
        position: relative;
        overflow: hidden;
    }

    .toggle-btn.active {
        background: var(--gradient);
        color: var(--white);
        box-shadow: 0 8px 25px rgba(250, 151, 106, 0.3);
        transform: translateY(-2px);
    }

    .toggle-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        transition: left 0.5s;
    }

    .toggle-btn:hover::before {
        left: 100%;
    }

    .form-section {
        display: none;
        text-align: left;
    }

    .form-section.active {
        display: block;
        animation: slideUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
    }

    @keyframes slideUp {
        from { 
            opacity: 0; 
            transform: translateY(30px); 
        }
        to { 
            opacity: 1; 
            transform: translateY(0); 
        }
    }

    .form-header {
        text-align: center;
        margin-bottom: 40px;
    }

    .form-header h2 {
        font-size: 32px;
        color: var(--text);
        margin-bottom: 12px;
        font-weight: 700;
        letter-spacing: -0.5px;
    }

    .form-header p {
        color: var(--text-light);
        font-size: 16px;
        font-weight: 400;
    }

    .form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 25px;
    }

    .form-group {
        margin-bottom: 20px;
        position: relative;
    }

    .form-group.full-width {
        grid-column: 1 / -1;
    }

    label {
        display: block;
        font-weight: 600;
        margin-bottom: 10px;
        font-size: 14px;
        color: var(--text);
        letter-spacing: -0.2px;
    }

    .input-with-icon {
        position: relative;
    }

    .input-icon {
        position: absolute;
        left: 18px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--text-light);
        font-size: 18px;
        z-index: 2;
    }

    input, select {
        width: 100%;
        padding: 18px 18px 18px 52px;
        border: 2px solid #f1f5f9;
        border-radius: 14px;
        font-size: 16px;
        transition: var(--transition);
        background: #ffffff;
        font-weight: 500;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    }

    input:focus, select:focus {
        outline: none;
        border-color: var(--primary);
        background: #ffffff;
        box-shadow: 0 8px 25px rgba(250, 151, 106, 0.15);
        transform: translateY(-2px);
    }

    .password-toggle {
        position: absolute;
        right: 18px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--text-light);
        cursor: pointer;
        font-size: 18px;
        transition: var(--transition);
    }

    .password-toggle:hover {
        color: var(--primary);
        transform: translateY(-50%) scale(1.1);
    }

    .submit-btn {
        width: 100%;
        background: var(--gradient);
        color: var(--white);
        border: none;
        border-radius: 14px;
        padding: 18px;
        font-weight: 600;
        font-size: 16px;
        cursor: pointer;
        transition: var(--transition);
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 8px 25px rgba(250, 151, 106, 0.3);
        margin-bottom: 25px;
    }

    .submit-btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 15px 35px rgba(250, 151, 106, 0.4);
    }

    .submit-btn:active {
        transform: translateY(-1px);
    }

    .submit-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        transition: left 0.5s;
    }

    .submit-btn:hover::before {
        left: 100%;
    }

    .login-link {
        text-align: center;
        font-size: 15px;
        color: var(--text-light);
        font-weight: 500;
        padding-top: 20px;
        border-top: 1px solid #f1f5f9;
    }

    .login-link a {
        color: var(--primary);
        text-decoration: none;
        font-weight: 700;
        transition: var(--transition);
        position: relative;
    }

    .login-link a::after {
        content: '';
        position: absolute;
        bottom: -2px;
        left: 0;
        width: 0;
        height: 2px;
        background: var(--gradient);
        transition: width 0.3s ease;
    }

    .login-link a:hover::after {
        width: 100%;
    }

    /* Floating particles */
    .particles {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
    }

    .particle {
        position: absolute;
        background: rgba(255, 255, 255, 0.5);
        border-radius: 50%;
        animation: float-particle 6s ease-in-out infinite;
    }

    @keyframes float-particle {
        0%, 100% { transform: translateY(0px) rotate(0deg); }
        50% { transform: translateY(-20px) rotate(180deg); }
    }

    /* Responsive Design */
    @media (max-width: 1024px) {
        .form-grid {
            grid-template-columns: 1fr;
        }
        
        .visual-section, .form-section-container {
            padding: 40px 30px;
        }
    }

    @media (max-width: 768px) {
        body {
            flex-direction: column;
            overflow: auto;
        }
        
        .visual-section {
            width: 100%;
            height: auto;
            min-height: 50vh;
        }
        
        .form-section-container {
            width: 100%;
            min-height: auto;
        }
    }

    @media (max-width: 480px) {
        .visual-section, .form-section-container {
            padding: 30px 20px;
        }
        
        .toggle-buttons {
            flex-direction: column;
            gap: 5px;
        }
        
        .toggle-btn {
            width: 100%;
        }
        
        .logo {
            font-size: 28px;
        }
        
        .visual-title {
            font-size: 32px;
        }
    }
</style>
</head>
<body>
    <!-- Left Section - Visual Content -->
    <!-- Left Section - Visual Content -->
<div class="visual-section">
    <div class="visual-content">
        <div class="visual-icon">
            <i class="fas fa-user-plus"></i>
        </div>
        <h1 class="visual-title">Start Your Journey Today</h1>
        <p class="visual-subtitle">Join thousands of professionals who have transformed their careers with JobPortal. Create your account and discover opportunities that match your skills and aspirations.</p>
        
        <div class="features-list">
            <div class="feature-item">
                <div class="feature-icon">
                    <i class="fas fa-check"></i>
                </div>
                <span>Smart AI-powered job matching algorithm</span>
            </div>
            <div class="feature-item">
                <div class="feature-icon">
                    <i class="fas fa-check"></i>
                </div>
                <span>Secure and completely private profiles</span>
            </div>
            <div class="feature-item">
                <div class="feature-icon">
                    <i class="fas fa-check"></i>
                </div>
                <span>Real-time notifications for new opportunities</span>
            </div>
            <div class="feature-item">
                <div class="feature-icon">
                    <i class="fas fa-check"></i>
                </div>
                <span>Dedicated career support and guidance</span>
            </div>
        </div>
    </div>
</div>
 
    <!-- Right Section - Registration Form -->
    <div class="form-section-container">
        <div class="logo">
            <i class="fas fa-briefcase"></i> JobPortal
        </div>

        <div class="toggle-buttons">
            <button class="toggle-btn active" onclick="showForm('jobseeker', event)">Job Seeker</button>
            <button class="toggle-btn" onclick="showForm('recruiter', event)">Recruiter</button>
        </div>

        <!-- Job Seeker Registration Form -->
        <form id="jobseekerForm" class="form-section active" action="register_process.jsp" method="post">
            <input type="hidden" name="userType" value="jobseeker">

            <div class="form-header">
                <h2>Create Job Seeker Account</h2>
                <p>Find your dream job with personalized recommendations</p>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label for="jsFullName">Full Name</label>
                    <div class="input-with-icon">
                        <i class="fas fa-user input-icon"></i>
                        <input type="text" id="jsFullName" name="fullName" placeholder="Enter your full name" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="jsEmail">Email Address</label>
                    <div class="input-with-icon">
                        <i class="fas fa-envelope input-icon"></i>
                        <input type="email" id="jsEmail" name="email" placeholder="Enter your email" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="jsPassword">Password</label>
                    <div class="input-with-icon">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password" id="jsPassword" name="password" placeholder="Create a password" required>
                        <i class="fas fa-eye password-toggle" onclick="togglePassword('jsPassword', this)"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="jsPhone">Phone Number</label>
                    <div class="input-with-icon">
                        <i class="fas fa-phone input-icon"></i>
                        <input type="tel" id="jsPhone" name="phone" placeholder="Enter your phone number" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="jsExperience">Experience (Years)</label>
                    <div class="input-with-icon">
                        <i class="fas fa-briefcase input-icon"></i>
                        <input type="number" id="jsExperience" name="experience" min="0" placeholder="Years of experience" required>
                    </div>
                </div>

                <div class="form-group full-width">
                    <label for="jsSkills">Skills</label>
                    <div class="input-with-icon">
                        <i class="fas fa-code input-icon"></i>
                        <input type="text" id="jsSkills" name="skills" placeholder="e.g., Java, SQL, JavaScript, Project Management" required>
                    </div>
                </div>

                <div class="form-group full-width">
                    <label for="jsEducation">Education</label>
                    <div class="input-with-icon">
                        <i class="fas fa-graduation-cap input-icon"></i>
                        <input type="text" id="jsEducation" name="education" placeholder="e.g., Bachelor's in Computer Science" required>
                    </div>
                </div>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-user-plus"></i> Create Job Seeker Account
            </button>
        </form>

        <!-- Recruiter Registration Form -->
        <form id="recruiterForm" class="form-section" action="register_process.jsp" method="post">
            <input type="hidden" name="userType" value="recruiter">

            <div class="form-header">
                <h2>Create Recruiter Account</h2>
                <p>Find the perfect candidates for your company</p>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label for="recFullName">Full Name</label>
                    <div class="input-with-icon">
                        <i class="fas fa-user input-icon"></i>
                        <input type="text" id="recFullName" name="fullName" placeholder="Enter your full name" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="recEmail">Email Address</label>
                    <div class="input-with-icon">
                        <i class="fas fa-envelope input-icon"></i>
                        <input type="email" id="recEmail" name="email" placeholder="Enter your email" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="recPassword">Password</label>
                    <div class="input-with-icon">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password" id="recPassword" name="password" placeholder="Create a password" required>
                        <i class="fas fa-eye password-toggle" onclick="togglePassword('recPassword', this)"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="recPhone">Phone Number</label>
                    <div class="input-with-icon">
                        <i class="fas fa-phone input-icon"></i>
                        <input type="tel" id="recPhone" name="phone" placeholder="Enter your phone number" required>
                    </div>
                </div>

                <div class="form-group full-width">
                    <label for="recCompany">Company Name</label>
                    <div class="input-with-icon">
                        <i class="fas fa-building input-icon"></i>
                        <input type="text" id="recCompany" name="company" placeholder="Enter your company name" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="recPosition">Position</label>
                    <div class="input-with-icon">
                        <i class="fas fa-briefcase input-icon"></i>
                        <input type="text" id="recPosition" name="position" placeholder="Your position" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="recIndustry">Industry</label>
                    <div class="input-with-icon">
                        <i class="fas fa-industry input-icon"></i>
                        <input type="text" id="recIndustry" name="industry" placeholder="Company industry" required>
                    </div>
                </div>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-user-plus"></i> Create Recruiter Account
            </button>
        </form>

        <div class="login-link">
            Already have an account? <a href="login.jsp">Login here</a>
        </div>
    </div>

    <script>
        function showForm(formType, event) {
            document.querySelectorAll('.toggle-btn').forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
            document.querySelectorAll('.form-section').forEach(form => form.classList.remove('active'));
            document.getElementById(formType + 'Form').classList.add('active');
        }

        function togglePassword(inputId, icon) {
            const passwordInput = document.getElementById(inputId);
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        // Create floating particles
        function createParticles() {
            const particlesContainer = document.createElement('div');
            particlesContainer.className = 'particles';
            document.querySelector('.visual-section').appendChild(particlesContainer);
            
            for (let i = 0; i < 15; i++) {
                const particle = document.createElement('div');
                particle.className = 'particle';
                
                const size = Math.random() * 6 + 2;
                const left = Math.random() * 100;
                const top = Math.random() * 100;
                const delay = Math.random() * 5;
                const duration = Math.random() * 3 + 4;
                
                particle.style.width = `${size}px`;
                particle.style.height = `${size}px`;
                particle.style.left = `${left}%`;
                particle.style.top = `${top}%`;
                particle.style.animationDelay = `${delay}s`;
                particle.style.animationDuration = `${duration}s`;
                
                particlesContainer.appendChild(particle);
            }
        }
        
        createParticles();
    </script>
</body>
</html>