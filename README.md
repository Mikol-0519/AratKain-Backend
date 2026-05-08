# AratKain Backend ☕🍽️

**AratKain Backend** is the server-side application of the AratKain web platform — a cafe and restaurant navigator. It handles authentication, user management, and restaurant data through a RESTful API.

## 📌 Project Description

This backend is built with **Java Spring Boot** and provides the API that powers the AratKain frontend. It manages user accounts, restaurant/cafe data, favorites, and secure authentication using JWT.

## 🚀 Features

- User registration and login
- JWT-based authentication
- Browse and search cafes and restaurants
- Save and manage favorite restaurants
- User profile management
- RESTful API endpoints
- Exception handling and validation

## 🛠️ Technologies Used

- **Java**
- **Spring Boot**
- **Spring Security**
- **JWT (JSON Web Token)**
- **Maven**
- **REST API**

## 📂 Project Structure

aratkain-backend/
│
├── src/
│   ├── main/
│   │   ├── java/com/aratkain/
│   │   │   ├── config/         # Security configuration
│   │   │   ├── controller/     # REST controllers
│   │   │   ├── dto/            # Data Transfer Objects
│   │   │   ├── entity/         # Database entities
│   │   │   ├── exception/      # Exception handling
│   │   │   ├── repository/     # Data repositories
│   │   │   ├── security/       # JWT filter and utilities
│   │   │   └── service/        # Business logic
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│
├── pom.xml
└── README.md

## ⚙️ Installation and Setup

### 1️⃣ Prerequisites

- Java 17+
- Maven 3.8+

### 2️⃣ Clone the repository

```bash
git clone https://github.com/Mikol-0519/AratKain-Backend.git
cd AratKain-Backend
```

### 3️⃣ Configure application properties

Edit `src/main/resources/application.properties` with your database and JWT settings:

```properties
spring.datasource.url=your_database_url
spring.datasource.username=your_username
spring.datasource.password=your_password
jwt.secret=your_jwt_secret
```

### 4️⃣ Build and Run

```bash
mvn clean install
mvn spring-boot:run
```

The server will start at `http://localhost:8080`.

## 📸 API Modules

- **Auth Module** — Register, Login, JWT token management
- **Establishment Module** — Cafe and restaurant data
- **Profile Module** — User profile management

## 🎯 Purpose of the Project

This backend was developed as part of an academic requirement, demonstrating the use of Java Spring Boot to build a secure and scalable REST API for a location-based restaurant discovery system.

## 👨‍💻 Developers

Developed by students of the Bachelor of Science in Information Technology (BSIT).

## 📄 License

This project is for educational purposes only.
