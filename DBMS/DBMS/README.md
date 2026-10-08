# SecureBank — Secure Bank Management System

A full-stack banking web application built as a DBMS project.

## Tech Stack
- **Frontend**: HTML, CSS, JavaScript
- **Backend**: Node.js + Express
- **Database**: MySQL

## Prerequisites
1. **Node.js** (v16+) — [Download](https://nodejs.org/)
2. **MySQL** (v8+) — Running on localhost:3306

## Setup Instructions

### 1. Database Setup
Open MySQL command line or MySQL Workbench and run:
```sql
SOURCE c:/Users/Triya/Desktop/DBMS/Secure_Bank_DBMS.sql;
```
This creates the `securebank` database with all tables and sample data.

### 2. Configure Environment
Edit the `.env` file in the project root and set your MySQL password:
```
DB_PASSWORD=your_mysql_root_password
```

### 3. Install Dependencies
```bash
cd c:\Users\Triya\Desktop\DBMS
npm install
```

### 4. Start the Server
```bash
npm start
```
The server will start at **http://localhost:3000**

## Login Credentials

### Admin
- Email: `admin@securebank.com`
- Password: `admin123`

### Demo Customers
All existing customers use password: `password123`
- Rajesh Kumar: `rajesh.kumar@email.com`
- Priya Sharma: `priya.sharma@email.com`
- Vikram Reddy: `vikram.reddy@email.com`
- Anjali Patel: `anjali.patel@email.com`

## Pages
| Page | URL | Description |
|------|-----|-------------|
| Login | `/` | Customer/Admin login + registration |
| Dashboard | `/dashboard.html` | Account summary, recent transactions |
| Accounts | `/accounts.html` | Create/view/close accounts |
| Transactions | `/transactions.html` | Deposit, withdraw, transfer, history |
| Loans | `/loans.html` | View loan details and progress |
| Admin Panel | `/admin.html` | All customers, accounts, transactions |

## API Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/register` | Register new customer |
| GET | `/api/dashboard/:customerId` | Dashboard data |
| GET | `/api/accounts/:customerId` | List accounts |
| POST | `/api/accounts` | Create account |
| DELETE | `/api/accounts/:accountId` | Close account |
| POST | `/api/transactions/deposit` | Deposit |
| POST | `/api/transactions/withdraw` | Withdraw |
| POST | `/api/transactions/transfer` | Transfer |
| GET | `/api/transactions/:accountId` | Transaction history |
| GET | `/api/loans/:customerId` | Loans |
| GET | `/api/admin/stats` | Admin stats |
| GET | `/api/admin/customers` | All customers |
| GET | `/api/admin/accounts` | All accounts |
| GET | `/api/admin/transactions` | All transactions |

## Security
- JWT-based authentication
- Bcrypt password hashing
- Prepared statements (SQL injection prevention)
- Role-based access control (customer vs admin)
