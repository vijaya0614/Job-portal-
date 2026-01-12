<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JobPortal - Find Your Perfect Career Match</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #FA976A;
            --primary-dark: #E55A2B;
            --primary-light: #FF8C5A;
            --primary-very-light: #FFF5F0;
            --text-color: #2C3E50;
            --text-light: #6c7a89;
            --bg-color: #f8f9fa;
            --white: #ffffff;
            --border-color: #eaeaea;
            --shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            --shadow-hover: 0 8px 24px rgba(0, 0, 0, 0.12);
            --card-radius: 16px;
            --transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            line-height: 1.6;
            overflow-x: hidden;
        }

        /* Header - Professional with white background */
        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 5%;
            background: var(--white);
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.05);
            transition: var(--transition);
        }

        .navbar.scrolled {
            padding: 0.75rem 5%;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }

        .logo {
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--primary-color);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            transition: var(--transition);
        }

        .logo i {
            font-size: 2rem;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 2.5rem;
        }

        .nav-link {
            text-decoration: none;
            color: var(--text-color);
            font-weight: 500;
            transition: var(--transition);
            position: relative;
            padding: 0.5rem 0;
        }

        .nav-link:after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: 0;
            left: 0;
            background-color: var(--primary-color);
            transition: var(--transition);
        }

        .nav-link:hover:after {
            width: 100%;
        }

        .btn-login {
            background: var(--primary-color);
            color: var(--white);
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            transition: var(--transition);
            box-shadow: 0 4px 12px rgba(255, 107, 53, 0.2);
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(255, 107, 53, 0.3);
        }

        /* Hero Section - White background with subtle gradient */
        .hero {
            padding: 5rem 5% 4rem;
            background: linear-gradient(to bottom, var(--white) 0%, var(--bg-color) 100%);
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 4rem;
            align-items: center;
            min-height: 92vh;
            color: var(--text-color);
            position: relative;
            overflow: hidden;
        }

        .hero-content h1 {
            font-size: 3.5rem;
            font-weight: 800;
            line-height: 1.1;
            margin-bottom: 1.5rem;
            color: var(--text-color);
        }

        .hero-content h1 span {
            color: var(--primary-color);
        }

        .hero-content p {
            font-size: 1.25rem;
            color: var(--text-light);
            margin-bottom: 2.5rem;
            max-width: 500px;
        }

        .cta-buttons {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            margin-bottom: 3rem;
        }

        .btn-primary {
            background: var(--primary-color);
            color: var(--white);
            padding: 1rem 2rem;
            border-radius: 12px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            transition: var(--transition);
            box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
        }

        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(255, 107, 53, 0.4);
        }

        .btn-secondary {
            background: transparent;
            color: var(--primary-color);
            padding: 1rem 2rem;
            border-radius: 12px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            border: 2px solid var(--primary-color);
            transition: var(--transition);
        }

        .btn-secondary:hover {
            background: var(--primary-color);
            color: var(--white);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(255, 107, 53, 0.3);
        }

        .hero-stats {
            display: flex;
            gap: 2.5rem;
            margin-top: 3rem;
        }

        .stat {
            text-align: left;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-color);
            display: block;
        }

        .stat-label {
            font-size: 0.9rem;
            color: var(--text-light);
        }

        .hero-visual {
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
        }

        .features-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            width: 100%;
        }

        .feature-card {
            background: var(--white);
            border-radius: var(--card-radius);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            transition: var(--transition);
            border-left: 4px solid var(--primary-color);
        }

        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-hover);
        }

        .feature-card h3 {
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
            color: var(--text-color);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .feature-card p {
            font-size: 0.9rem;
            color: var(--text-light);
        }

        /* Portal Section - Professional Cards */
        .portal-section {
            padding: 6rem 5%;
            background: var(--white);
        }

        .section-header {
            text-align: center;
            max-width: 700px;
            margin: 0 auto 4rem;
        }

        .section-header h2 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: var(--text-color);
        }

        .section-header p {
            font-size: 1.2rem;
            color: var(--text-light);
        }

        .portal-cards {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            max-width: 1000px;
            margin: 0 auto;
        }

        .portal-card {
            background: var(--white);
            border-radius: var(--card-radius);
            padding: 3rem 2.5rem;
            box-shadow: var(--shadow);
            text-align: center;
            transition: var(--transition);
            border: 1px solid var(--border-color);
            position: relative;
            overflow: hidden;
        }

        .portal-card:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background: linear-gradient(90deg, var(--primary-color), var(--primary-light));
        }

        .portal-card:hover {
            transform: translateY(-8px);
            box-shadow: var(--shadow-hover);
        }

        .portal-icon {
            width: 80px;
            height: 80px;
            background: var(--primary-very-light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 2rem;
            color: var(--primary-color);
            transition: var(--transition);
        }

        .portal-card:hover .portal-icon {
            transform: scale(1.1);
            background: var(--primary-color);
            color: var(--white);
        }

        .portal-card h3 {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: var(--text-color);
        }

        .portal-card p {
            color: var(--text-light);
            margin-bottom: 2rem;
        }

        /* Features Section - Modern Grid */
        .features-section {
            padding: 6rem 5%;
            background: var(--bg-color);
        }

        .features-grid-main {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .feature-card-main {
            background: var(--white);
            border-radius: var(--card-radius);
            padding: 2.5rem 2rem;
            box-shadow: var(--shadow);
            text-align: center;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }

        .feature-card-main:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-color), var(--primary-light));
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.5s ease;
        }

        .feature-card-main:hover:before {
            transform: scaleX(1);
        }

        .feature-card-main:hover {
            transform: translateY(-8px);
            box-shadow: var(--shadow-hover);
        }

        .feature-icon {
            width: 70px;
            height: 70px;
            background: var(--primary-very-light);
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 1.75rem;
            color: var(--primary-color);
            transition: var(--transition);
        }

        .feature-card-main:hover .feature-icon {
            transform: rotateY(180deg);
            background: var(--primary-color);
            color: var(--white);
        }

        .feature-card-main h3 {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: var(--text-color);
        }

        .feature-card-main p {
            color: var(--text-light);
            font-size: 0.95rem;
        }

        /* CTA Section - Professional */
        .cta-section {
            padding: 6rem 5%;
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: var(--white);
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .cta-section:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveAspectRatio="none"><path d="M0,0 L100,0 L100,100 Z" fill="rgba(255,255,255,0.05)"/></svg>');
            background-size: cover;
        }

        .cta-section h2 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            position: relative;
        }

        .cta-section p {
            font-size: 1.2rem;
            margin-bottom: 2.5rem;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            opacity: 0.9;
            position: relative;
        }

        .btn-light {
            background: var(--white);
            color: var(--primary-color);
            padding: 1rem 2.5rem;
            border-radius: 12px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            transition: var(--transition);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            position: relative;
        }

        .btn-light:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
        }

        /* Footer */
        .footer {
            padding: 4rem 5% 2rem;
            background: #2C3E50;
            color: var(--white);
        }

        .footer-content {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 3rem;
            max-width: 1200px;
            margin: 0 auto 3rem;
        }

        .footer-logo {
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--white);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
        }

        .footer-about p {
            margin-bottom: 1.5rem;
            opacity: 0.8;
        }

        .social-links {
            display: flex;
            gap: 1rem;
        }

        .social-link {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            text-decoration: none;
            transition: var(--transition);
        }

        .social-link:hover {
            background: var(--primary-color);
            transform: translateY(-3px);
        }

        .footer-heading {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
            color: var(--white);
        }

        .footer-links {
            list-style: none;
        }

        .footer-links li {
            margin-bottom: 0.75rem;
        }

        .footer-links a {
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            transition: var(--transition);
        }

        .footer-links a:hover {
            color: var(--primary-light);
            padding-left: 5px;
        }

        .footer-bottom {
            text-align: center;
            padding-top: 2rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            color: rgba(255, 255, 255, 0.7);
        }

        /* Responsive Design */
        @media (max-width: 1024px) {
            .hero {
                grid-template-columns: 1fr;
                text-align: center;
                padding-top: 4rem;
            }
            
            .hero-content h1 {
                font-size: 3rem;
            }
            
            .cta-buttons {
                justify-content: center;
            }
            
            .hero-stats {
                justify-content: center;
            }
            
            .features-grid-main {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .footer-content {
                grid-template-columns: 1fr 1fr;
            }
        }

        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }
            
            .hero-content h1 {
                font-size: 2.5rem;
            }
            
            .portal-cards {
                grid-template-columns: 1fr;
            }
            
            .features-grid-main {
                grid-template-columns: 1fr;
            }
            
            .hero-stats {
                flex-direction: column;
                gap: 1.5rem;
            }
            
            .features-grid {
                grid-template-columns: 1fr;
            }
            
            .footer-content {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .hero-content h1 {
                font-size: 2rem;
            }
            
            .cta-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .btn-primary, .btn-secondary {
                width: 100%;
                justify-content: center;
            }
            
            .section-header h2 {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <header class="navbar">
        <a href="index.jsp" class="logo">
            <i class="fas fa-briefcase"></i>
            JobPortal
        </a>
        <nav class="nav-links">
            <a href="#features" class="nav-link">Features</a>
            <a href="#portal" class="nav-link">For You</a>
            <a href="register.jsp" class="nav-link">Register</a>
            <a href="login.jsp" class="btn-login">Login</a>
        </nav>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-content">
            <h1>Find Your Perfect <span>Career Match</span></h1>
            <p>Connect with opportunities that align with your skills, ambitions, and values. The modern way to find jobs and talent.</p>
            <div class="cta-buttons">
                <a href="register.jsp?type=jobseeker" class="btn-primary">
                    <i class="fas fa-search"></i>
                    Find Jobs
                </a>
                <a href="register.jsp?type=recruiter" class="btn-secondary">
                    <i class="fas fa-bullhorn"></i>
                    Post Jobs
                </a>
            </div>
           
        </div>
        <div class="hero-visual">
            <div class="features-grid">
                <div class="feature-card">
    <h3><i class="fas fa-id-card"></i> Portfolio Builder</h3>
    <p>Showcase your projects and achievements with our portfolio builder</p>
</div>

                <div class="feature-card">
                    <h3><i class="fas fa-chart-line"></i> Track Applications</h3>
                    <p>Monitor your job search progress in real-time</p>
                </div>
                <div class="feature-card">
                    <h3><i class="fas fa-comments"></i> Direct Communication</h3>
                    <p>Connect with employers without intermediaries</p>
                </div>
                <div class="feature-card">
    <h3><i class="fas fa-briefcase"></i> Get Jobs</h3>
    <p>Receive personalized job recommendations based on your profile</p>
</div>
                <div class="feature-card">
                    <h3><i class="fas fa-user-check"></i> Profile Verification</h3>
                    <p>Verified profiles increase your chances of getting hired</p>
                </div>
                <div class="feature-card">
                    <h3><i class="fas fa-gem"></i> Premium Opportunities</h3>
                    <p>Access exclusive job listings from top companies</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Portal Section -->
    <section id="portal" class="portal-section">
        <div class="section-header">
            <h2>Built For Your Needs</h2>
            <p>Dedicated experiences designed specifically for different users</p>
        </div>
        <div class="portal-cards">
            <div class="portal-card">
                <div class="portal-icon">
                    <i class="fas fa-user-tie"></i>
                </div>
                <h3>For Job Seekers</h3>
                <p>Find roles that match your skills and career goals with personalized recommendations and application tracking.</p>
                <a href="register.jsp?type=jobseeker" class="btn-primary">
                    Start Job Search
                </a>
            </div>
            <div class="portal-card">
                <div class="portal-icon">
                    <i class="fas fa-building"></i>
                </div>
                <h3>For Recruiters</h3>
                <p>Streamline your hiring process with smart candidate matching and efficient pipeline management tools.</p>
                <a href="register.jsp?type=recruiter" class="btn-primary">
                    Find Talent
                </a>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="features-section">
        <div class="section-header">
            <h2>Why Choose JobPortal</h2>
            <p>Modern features designed to make your job search or hiring process efficient and effective</p>
        </div>
        <div class="features-grid-main">
            <div class="feature-card-main">
                <div class="feature-icon">
                    <i class="fas fa-brain"></i>
                </div>
                <h3>AI Matching</h3>
                <p>Intelligent algorithms that analyze skills and preferences to deliver perfect matches</p>
            </div>
            <div class="feature-card-main">
                <div class="feature-icon">
                    <i class="fas fa-tachometer-alt"></i>
                </div>
                <h3>Smart Dashboard</h3>
                <p>Customized interfaces with all the tools you need in one organized place</p>
            </div>
            <div class="feature-card-main">
                <div class="feature-icon">
                    <i class="fas fa-project-diagram"></i>
                </div>
                <h3>Pipeline Management</h3>
                <p>Track candidates or applications through every stage with ease</p>
            </div>
            <div class="feature-card-main">
                <div class="feature-icon">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <h3>Secure Platform</h3>
                <p>Bank-level encryption and privacy controls to protect your data</p>
            </div>
            <div class="feature-card-main">
                <div class="feature-icon">
                    <i class="fas fa-mobile-alt"></i>
                </div>
                <h3>Mobile Ready</h3>
                <p>Full functionality on any device with a seamless mobile experience</p>
            </div>
            <div class="feature-card-main">
                <div class="feature-icon">
                    <i class="fas fa-bolt"></i>
                </div>
                <h3>Real-time Updates</h3>
                <p>Instant notifications for new matches and application status changes</p>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section">
        <h2>Ready to Get Started?</h2>
        <p>Join thousands of job seekers and employers who found their perfect match through JobPortal</p>
        <a href="register.jsp" class="btn-light">
            <i class="fas fa-rocket"></i>
            Create Your Account
        </a>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="footer-content">
            <div class="footer-about">
                <a href="index.jsp" class="footer-logo">
                    <i class="fas fa-briefcase"></i>
                    JobPortal
                </a>
                <p>Connecting talent with opportunity through intelligent matching and a seamless user experience.</p>
                <div class="social-links">
                    <a href="#" class="social-link"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="social-link"><i class="fab fa-linkedin-in"></i></a>
                    <a href="#" class="social-link"><i class="fab fa-instagram"></i></a>
                </div>
            </div>
            <div class="footer-links-container">
                <h3 class="footer-heading">For Job Seekers</h3>
                <ul class="footer-links">
                    <li><a href="#">Browse Jobs</a></li>
                    <li><a href="#">Career Resources</a></li>
                    <li><a href="#">Resume Builder</a></li>
                    <li><a href="#">Job Alerts</a></li>
                </ul>
            </div>
            <div class="footer-links-container">
                <h3 class="footer-heading">For Employers</h3>
                <ul class="footer-links">
                    <li><a href="#">Post a Job</a></li>
                    <li><a href="#">Browse Candidates</a></li>
                    <li><a href="#">Pricing Plans</a></li>
                    <li><a href="#">Recruitment Tools</a></li>
                </ul>
            </div>
            <div class="footer-links-container">
                <h3 class="footer-heading">Company</h3>
                <ul class="footer-links">
                    <li><a href="#">About Us</a></li>
                    <li><a href="#">Careers</a></li>
                    <li><a href="#">Blog</a></li>
                    <li><a href="#">Contact</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2025 JobPortal. All rights reserved.</p>
        </div>
    </footer>

    <script>
        // Navbar scroll effect
        window.addEventListener('scroll', function() {
            const navbar = document.querySelector('.navbar');
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });

        // Add fade-in animation for elements on scroll
        document.addEventListener('DOMContentLoaded', function() {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = 1;
                        entry.target.style.transform = 'translateY(0)';
                    }
                });
            });

            // Observe feature cards and portal cards
            document.querySelectorAll('.feature-card-main, .portal-card, .feature-card').forEach(card => {
                card.style.opacity = 0;
                card.style.transform = 'translateY(20px)';
                card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                observer.observe(card);
            });
        });
    </script>
</body>
</html>