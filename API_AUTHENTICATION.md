# 🔐 API Authentication Documentation

API-only Rails authentication system using Devise with JWT tokens, including user registration, email confirmation, login, and password reset functionality.

## 📋 Table of Contents

- [Authentication Overview](#authentication-overview)
- [Base URL & Headers](#base-url--headers)
- [Authentication Endpoints](#authentication-endpoints)
  - [User Registration](#1-user-registration)
  - [Email Confirmation](#2-email-confirmation)
  - [Resend Confirmation](#3-resend-confirmation-instructions)
  - [User Login](#4-user-login)
  - [User Logout](#5-user-logout)
  - [Request Password Reset](#6-request-password-reset)
  - [Reset Password](#7-reset-password)
- [Protected Endpoints](#protected-endpoints)
- [Error Responses](#error-responses)
- [Complete Flow Examples](#complete-flow-examples)

---

## Authentication Overview

### Technologies Used:
- **Devise** for authentication
- **Devise-JWT** for JWT token generation
- **ActionMailer** for email notifications
- **Rails 8** API-only mode

### JWT Configuration:
- **Expiration Time:** 24 hours
- **Algorithm:** HS256
- **Header Format:** `Authorization: Bearer <JWT_TOKEN>`

---

## Base URL & Headers

### Base URL
```
http://localhost:3000
```

### Required Headers
```http
Content-Type: application/json
Authorization: Bearer <JWT_TOKEN>  # Only for protected endpoints
```

---

## Authentication Endpoints

### 1. User Registration

Register a new user account. Email confirmation will be sent after successful registration.

**Endpoint:** `POST /signup`

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Signed up successfully."
  },
  "data": {
    "id": 1,
    "email": "user@example.com",
    "confirmed_at": null,
    "created_at": "2025-06-30T15:13:05.000Z",
    "updated_at": "2025-06-30T15:13:05.000Z"
  }
}
```

**Example cURL:**
```bash
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "newuser@example.com",
      "password": "securepassword123",
      "password_confirmation": "securepassword123"
    }
  }'
```

**Error Response (422):**
```json
{
  "status": {
    "message": "User couldn't be created successfully. Email has already been taken"
  }
}
```

---

### 2. Email Confirmation

Confirm account using token received via email.

**Endpoint:** `GET /confirmation?confirmation_token=<TOKEN>`

**Parameters:**
- `confirmation_token` (required): Token received via email

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Account confirmed successfully."
  }
}
```

**Example cURL:**
```bash
curl -X GET "http://localhost:3000/confirmation?confirmation_token=your_confirmation_token_here" \
  -H "Content-Type: application/json"
```

**Error Response (422):**
```json
{
  "status": {
    "message": "Account confirmation failed. Confirmation token is invalid"
  }
}
```

---

### 3. Resend Confirmation Instructions

Resend confirmation email for unconfirmed users.

**Endpoint:** `POST /confirmation`

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com"
  }
}
```

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Confirmation instructions sent successfully."
  }
}
```

**Example cURL:**
```bash
curl -X POST http://localhost:3000/confirmation \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com"
    }
  }'
```

**Error Response (404):**
```json
{
  "status": {
    "message": "Email not found."
  }
}
```

---

### 4. User Login

Authenticate user and receive JWT token. Account must be confirmed first.

**Endpoint:** `POST /login`

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Logged in successfully.",
    "data": {
      "user": {
        "id": 1,
        "email": "user@example.com",
        "confirmed_at": "2025-06-30T15:15:00.000Z",
        "created_at": "2025-06-30T15:13:05.000Z",
        "updated_at": "2025-06-30T15:15:00.000Z"
      },
      "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiZXhwIjoxNjI0..."
    }
  }
}
```

**Response Headers:**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiZXhwIjoxNjI0...
```

**Note:** JWT token is provided in both response body (`data.token`) and response header (`Authorization`) for flexibility.

**Example cURL:**
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password123"
    }
  }' \
  -i  # Include headers to see JWT token
```

**Error Response (401) - Unconfirmed Account:**
```json
{
  "error": "You have to confirm your email address before continuing."
}
```

**Error Response (401) - Invalid Credentials:**
```json
{
  "error": "Invalid Email or password."
}
```

---

### 5. User Logout

Log out and invalidate current JWT token.

**Endpoint:** `DELETE /logout`

**Headers:**
```http
Authorization: Bearer <JWT_TOKEN>
```

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Logged out successfully."
  }
}
```

**Example cURL:**
```bash
curl -X DELETE http://localhost:3000/logout \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Error Response (401):**
```json
{
  "status": {
    "code": 401,
    "message": "Couldn't find an active session."
  }
}
```

---

### 6. Request Password Reset

Send email with password reset link.

**Endpoint:** `POST /password`

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com"
  }
}
```

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Password reset instructions sent successfully."
  }
}
```

**Example cURL:**
```bash
curl -X POST http://localhost:3000/password \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com"
    }
  }'
```

**Error Response (404):**
```json
{
  "status": {
    "message": "Email not found."
  }
}
```

---

### 7. Reset Password

Reset password using reset token received via email.

**Endpoint:** `PUT /password`

**Request Body:**
```json
{
  "user": {
    "reset_password_token": "your_reset_token_here",
    "password": "newpassword123",
    "password_confirmation": "newpassword123"
  }
}
```

**Success Response (200):**
```json
{
  "status": {
    "code": 200,
    "message": "Password updated successfully."
  }
}
```

**Example cURL:**
```bash
curl -X PUT http://localhost:3000/password \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "reset_password_token": "your_reset_token_from_email",
      "password": "mynewpassword123",
      "password_confirmation": "mynewpassword123"
    }
  }'
```

**Error Response (422):**
```json
{
  "status": {
    "message": "Password reset failed. Reset password token is invalid"
  }
}
```

---

## Protected Endpoints

All API endpoints under `/api/v1/` require authentication.

### How to use JWT Token:

**Headers:**
```http
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Example Protected Endpoint:**
```bash
curl -X GET http://localhost:3000/api/v1/assets \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**Unauthorized Response (401):**
```json
{
  "status": {
    "code": 401,
    "message": "You need to sign in or sign up before continuing."
  }
}
```

---

## Error Responses

### Common HTTP Status Codes:

| Status Code | Description | Example |
|------------|-------------|---------|
| `200` | Success | Login successful |
| `401` | Unauthorized | JWT token invalid or missing |
| `404` | Not Found | Email does not exist |
| `422` | Unprocessable Entity | Validation errors |

### Error Response Format:
```json
{
  "status": {
    "message": "Error description here"
  }
}
```

---

## Complete Flow Examples

### 🔄 Registration & Login Flow

```bash
# 1. Register new user
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "testuser@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }'

# 2. Check email and click confirmation link
# GET http://localhost:3000/confirmation?confirmation_token=<TOKEN>

# 3. Login to get JWT token
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "testuser@example.com",
      "password": "password123"
    }
  }' \
  -i

# 4. Use JWT token to access protected endpoints
curl -X GET http://localhost:3000/api/v1/assets \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json"

# 5. Logout
curl -X DELETE http://localhost:3000/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### 🔑 Password Reset Flow

```bash
# 1. Request password reset
curl -X POST http://localhost:3000/password \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "testuser@example.com"
    }
  }'

# 2. Use token from email to reset password
curl -X PUT http://localhost:3000/password \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "reset_password_token": "TOKEN_FROM_EMAIL",
      "password": "newpassword123",
      "password_confirmation": "newpassword123"
    }
  }'

# 3. Login with new password
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "testuser@example.com",
      "password": "newpassword123"
    }
  }'
```

---

## 🔧 Development Notes

### Email Testing in Development:
```bash
# Install MailCatcher to test emails
gem install mailcatcher
mailcatcher
# Access http://localhost:1080 to view emails
```

### JWT Token Expiration:
- Tokens expire after **24 hours**
- Client needs to handle token refresh or re-authentication

### Security Best Practices:
- ✅ HTTPS in production
- ✅ Secure JWT secret key
- ✅ Email confirmation required
- ✅ Password strength validation
- ✅ Rate limiting (recommended)

---

## 📞 Support

If you encounter issues with the authentication API:

1. Check email confirmation status
2. Verify JWT token format and expiration
3. Check request headers and body format
4. Review error messages in response

**Happy coding! 🚀**
