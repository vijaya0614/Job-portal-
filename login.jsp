<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | JobPortal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
    :root {
        --primary: #FA976A;
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
    width: 50%;
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
    opacity: 0.9;
    line-height: 1.6;
    margin-bottom: 40px;
    color: var(--text-light); /* Light text color */
    font-weight: 400;
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
    color: var(--text); /* Dark text color */
    font-weight: 500;
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


    /* Right Section - Login Form */
    .form-section-container {
        flex: 1;
        width: 50%;
        display: flex;
        flex-direction: column;
        justify-content: center;
        padding: 60px;
        position: relative;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        border-left: 1px solid rgba(255, 255, 255, 0.2);
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

    .form-group {
        margin-bottom: 24px;
        position: relative;
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

    input {
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

    input:focus {
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

    .forgot-password {
        text-align: right;
        margin-bottom: 30px;
    }

    .forgot-password a {
        color: var(--primary);
        font-size: 14px;
        text-decoration: none;
        font-weight: 600;
        transition: var(--transition);
        position: relative;
    }

    .forgot-password a::after {
        content: '';
        position: absolute;
        bottom: -2px;
        left: 0;
        width: 0;
        height: 2px;
        background: var(--gradient);
        transition: width 0.3s ease;
    }

    .forgot-password a:hover::after {
        width: 100%;
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

    .divider {
        display: flex;
        align-items: center;
        margin: 35px 0;
        color: var(--text-light);
        font-size: 14px;
        font-weight: 500;
    }

    .divider::before, .divider::after {
        content: '';
        flex: 1;
        height: 1px;
        background: linear-gradient(90deg, transparent, #e2e8f0, transparent);
    }

    .divider span {
        padding: 0 20px;
    }

    .social-login {
        display: flex;
        gap: 16px;
        margin-bottom: 35px;
    }

    .social-btn {
        flex: 1;
        padding: 16px;
        border: 2px solid #f1f5f9;
        border-radius: 14px;
        background: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        font-weight: 600;
        font-size: 14px;
        cursor: pointer;
        transition: var(--transition);
        position: relative;
        overflow: hidden;
    }

    .social-btn:hover {
        border-color: var(--primary);
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
    }

    .social-btn.google {
        color: #DB4437;
    }

    .social-btn.linkedin {
        color: #0077B5;
    }

    .register-link {
        text-align: center;
        font-size: 15px;
        color: var(--text-light);
        font-weight: 500;
    }

    .register-link a {
        color: var(--primary);
        text-decoration: none;
        font-weight: 700;
        transition: var(--transition);
        position: relative;
    }

    .register-link a::after {
        content: '';
        position: absolute;
        bottom: -2px;
        left: 0;
        width: 0;
        height: 2px;
        background: var(--gradient);
        transition: width 0.3s ease;
    }

    .register-link a:hover::after {
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
    .submit-btn {
    margin-bottom: 25px; /* Add this line */
    /* your existing submit-btn styles */
}

    @keyframes float-particle {
        0%, 100% { transform: translateY(0px) rotate(0deg); }
        50% { transform: translateY(-20px) rotate(180deg); }
    }
</style>
</head>
<body>
    <!-- Left Section - Visual Content -->
    <div class="visual-section">
        <div class="visual-content">
            <div class="visual-icon">
                <i class="fas fa-briefcase"></i>
            </div>
            <h1 class="visual-title">Find Your Dream Career Today</h1>
            <p class="visual-subtitle">Join thousands of professionals who have transformed their careers with JobPortal. Discover opportunities that match your skills and aspirations.</p>
            
            <div class="features-list">
                <div class="feature-item">
                    <div class="feature-icon">
                        <i class="fas fa-check"></i>
                    </div>
                    <span>Personalized job recommendations</span>
                </div>
                <div class="feature-item">
                    <div class="feature-icon">
                        <i class="fas fa-check"></i>
                    </div>
                    <span>Connect with top companies</span>
                </div>
                <div class="feature-item">
                    <div class="feature-icon">
                        <i class="fas fa-check"></i>
                    </div>
                    <span>Advanced application tracking</span>
                </div>
                <div class="feature-item">
                    <div class="feature-icon">
                        <i class="fas fa-check"></i>
                    </div>
                    <span>Career growth insights</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Right Section - Login Form -->
    <div class="form-section-container">
        <div class="logo">
            <i class="fas fa-briefcase"></i> JobPortal
        </div>

        <div class="toggle-buttons">
            <button class="toggle-btn active" onclick="showForm('jobseeker', event)">Job Seeker</button>
            <button class="toggle-btn" onclick="showForm('recruiter', event)">Recruiter</button>
        </div>

        <!-- Job Seeker Form -->
        <form id="jobseekerForm" class="form-section active" action="login_process.jsp" method="post">
            <input type="hidden" name="userType" value="jobseeker">

            <div class="form-header">
                <h2>Welcome Back</h2>
                <p>Sign in to explore your next opportunity</p>
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
                    <input type="password" id="jsPassword" name="password" placeholder="Enter your password" required>
                    <i class="fas fa-eye password-toggle" onclick="togglePassword('jsPassword', this)"></i>
                </div>
            </div>

            <div class="forgot-password">
                <a href="forgot_password.jsp">Forgot Password?</a>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-sign-in-alt"></i> Sign In as Job Seeker
            </button>

            
        </form>

        <!-- Recruiter Form -->
        <form id="recruiterForm" class="form-section" action="login_process.jsp" method="post">
            <input type="hidden" name="userType" value="recruiter">

            <div class="form-header">
                <h2>Welcome Back</h2>
                <p>Manage your job posts and candidates</p>
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
                    <input type="password" id="recPassword" name="password" placeholder="Enter your password" required>
                    <i class="fas fa-eye password-toggle" onclick="togglePassword('recPassword', this)"></i>
                </div>
            </div>

            <div class="forgot-password">
                <a href="forgot_password.jsp">Forgot Password?</a>
            </div>

            <button type="submit" class="submit-btn">
                <i class="fas fa-sign-in-alt"></i> Sign In as Recruiter
            </button>

            
        </form>

        <div class="register-link">
            Don't have an account? <a href="register.jsp">Register Now</a>
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
    </script>
    <script>
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