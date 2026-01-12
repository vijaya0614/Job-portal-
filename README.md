# Job Portal Web Application

A full-stack web application designed to connect Recruiters and Job Seekers on a single platform.
The system enables recruiters to post jobs with customized application forms and manage applications,
while job seekers can search for jobs, apply online, track application status, and maintain a professional portfolio.

The project is developed using JSP, JDBC, MySQL, and Apache Tomcat, following a client–server architecture
and real-world recruitment workflows.

---

## Features

- Dual user roles with separate login and dashboards for Recruiters and Job Seekers
- Secure authentication using email, password, and session management
- Job posting with dynamic, recruiter-defined application forms
- Support for up to 10 custom fields per job application
- Application status management (Pending, Accepted, Rejected, Marked for Review)
- Application filtering based on status
- Job search and recommendation functionality
- Company profile creation and management
- Job seeker portfolio management (skills, projects, experience)
- Application tracking for job seekers
- User settings including password update and theme preferences

---

## System Architecture

The application follows a client–server model.

- JSP pages act as the client interface
- Apache Tomcat handles server-side processing
- JDBC is used for database connectivity
- MySQL is used for persistent data storage
- HttpSession is used for authentication and role-based access control

---

## User Roles

### Recruiter
- Register and login securely
- Access recruiter dashboard with job statistics
- Post jobs with basic details and custom application fields
- View jobs posted and number of applications received
- Review applications and update their status
- Filter applications by status
- Create and update company profile information

### Job Seeker
- Register and login securely
- View latest and available job postings
- Search for specific jobs
- View company profiles before applying
- Apply to jobs using dynamically generated application forms
- Track application status
- Manage personal portfolio including skills, projects, and experience

---

## Tech Stack

| Technology     | Purpose                        |
|---------------|--------------------------------|
| JSP           | Server-side web development    |
| JDBC          | Database connectivity          |
| MySQL         | Relational database            |
| Apache Tomcat | Web server                     |
| HTML/CSS/JS   | Frontend structure and styling |

---

## Database Design 

- Recruiters and Job Seekers stored in separate tables
- Jobs table stores job details and dynamic custom fields
- Job Applications table stores applicant data and application status
- Company profile and address tables for recruiter information
- Portfolio-related tables for job seeker data

---

## Key Highlights

- Role-based access and dashboards
- Dynamic form generation without page duplication
- Real-world recruitment workflow implementation
- Clean separation of concerns between user roles
- Scalable and structured database design

---

## Conclusion

This Job Portal Web Application implements a complete recruitment management system.
It demonstrates practical use of JSP, JDBC, session handling, and database design
to build a scalable and functional web application.

---

## Authors

- Navya Alikanti
- Vijaya Sree Mallikanti

