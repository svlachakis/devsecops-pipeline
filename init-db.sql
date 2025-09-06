-- Initialize vulnerable database for testing

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    balance DECIMAL(10, 2) DEFAULT 0.00,
    account_number VARCHAR(20) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(100) PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    data TEXT,
    expires_at TIMESTAMP
);

-- Insert test data (with weak passwords for testing)
INSERT INTO users (username, password, email, role) VALUES
    ('admin', 'admin123', 'admin@vulnerable.com', 'admin'),
    ('user1', 'password123', 'user1@vulnerable.com', 'user'),
    ('user2', 'qwerty', 'user2@vulnerable.com', 'user'),
    ('test', 'test', 'test@vulnerable.com', 'user');

INSERT INTO accounts (user_id, balance, account_number) VALUES
    (1, 10000.00, 'ACC001'),
    (2, 500.00, 'ACC002'),
    (3, 1500.00, 'ACC003'),
    (4, 100.00, 'ACC004');
