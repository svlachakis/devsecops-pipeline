// src/vulnerable-app/app.js
// ΠΡΟΣΟΧΗ: Αυτή η εφαρμογή περιέχει ΣΚΟΠΙΜΑ ευπάθειες για εκπαιδευτικούς σκοπούς!

const express = require('express');
const mysql = require('mysql');
const crypto = require('crypto');
const exec = require('child_process').exec;
const fs = require('fs');
const path = require('path');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// VULNERABILITY 1: Hardcoded credentials (για TruffleHog)
const DB_PASSWORD = "SuperSecret123!";
const API_KEY = "sk-1234567890abcdef1234567890abcdef";
const AWS_SECRET = "aws_secret_access_key=AKIAIOSFODNN7EXAMPLE";

// VULNERABILITY 2: SQL Injection prone database connection
const db = mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: 'root',
    password: DB_PASSWORD,
    database: 'vulnerable_db'
});

// VULNERABILITY 3: No input validation - SQL Injection
app.get('/api/users', (req, res) => {
    const userId = req.query.id;
    // Vulnerable SQL query - concatenation instead of parameterized query
    const query = `SELECT * FROM users WHERE id = ${userId}`;
    
    db.query(query, (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(results);
        }
    });
});

// VULNERABILITY 4: SQL Injection in login
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    // Vulnerable to SQL injection
    const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
    
    db.query(query, (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else if (results.length > 0) {
            res.json({ message: 'Login successful', user: results[0] });
        } else {
            res.status(401).json({ message: 'Invalid credentials' });
        }
    });
});

// VULNERABILITY 5: Command Injection
app.post('/api/ping', (req, res) => {
    const { host } = req.body;
    // Vulnerable to command injection
    exec(`ping -c 4 ${host}`, (error, stdout, stderr) => {
        if (error) {
            res.status(500).json({ error: error.message });
        } else {
            res.json({ output: stdout });
        }
    });
});

// VULNERABILITY 6: Path Traversal
app.get('/api/file', (req, res) => {
    const filename = req.query.name;
    // Vulnerable to path traversal
    const filepath = path.join(__dirname, 'uploads', filename);
    
    fs.readFile(filepath, 'utf8', (err, data) => {
        if (err) {
            res.status(404).json({ error: 'File not found' });
        } else {
            res.send(data);
        }
    });
});

// VULNERABILITY 7: Weak encryption
app.post('/api/encrypt', (req, res) => {
    const { data } = req.body;
    // Using deprecated and weak MD5
    const hash = crypto.createHash('md5').update(data).digest('hex');
    res.json({ encrypted: hash });
});

// VULNERABILITY 8: XSS Vulnerability
app.get('/api/search', (req, res) => {
    const query = req.query.q;
    // Reflecting user input without sanitization
    res.send(`
        <html>
            <body>
                <h1>Search Results</h1>
                <p>You searched for: ${query}</p>
            </body>
        </html>
    `);
});

// VULNERABILITY 9: Insecure Direct Object Reference
app.get('/api/account/:id', (req, res) => {
    const accountId = req.params.id;
    // No authorization check
    const query = `SELECT * FROM accounts WHERE id = ?`;
    
    db.query(query, [accountId], (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(results);
        }
    });
});

// VULNERABILITY 10: XXE Injection (if XML parsing is used)
app.post('/api/xml', (req, res) => {
    const xmlData = req.body;
    // Vulnerable XML parsing would go here
    res.json({ message: 'XML processed' });
});

// VULNERABILITY 11: Sensitive data in logs
app.use((req, res, next) => {
    // Logging sensitive data
    console.log(`Request: ${req.method} ${req.url} - Body: ${JSON.stringify(req.body)}`);
    next();
});

// VULNERABILITY 12: No rate limiting
app.post('/api/reset-password', (req, res) => {
    const { email } = req.body;
    // No rate limiting - vulnerable to brute force
    res.json({ message: `Password reset link sent to ${email}` });
});

// VULNERABILITY 13: Insecure session management
let sessions = {};
app.post('/api/session', (req, res) => {
    const sessionId = Math.random().toString(36).substr(2, 9); // Predictable session ID
    sessions[sessionId] = { user: req.body.username };
    res.json({ sessionId });
});

// VULNERABILITY 14: CORS misconfiguration
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*'); // Too permissive
    res.header('Access-Control-Allow-Headers', '*');
    res.header('Access-Control-Allow-Methods', '*');
    next();
});

// VULNERABILITY 15: Debug mode enabled in production
app.get('/api/debug', (req, res) => {
    res.json({
        env: process.env,
        memory: process.memoryUsage(),
        uptime: process.uptime()
    });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Vulnerable app running on port ${PORT}`);
    console.log('WARNING: This app contains intentional vulnerabilities!');
});

module.exports = app;