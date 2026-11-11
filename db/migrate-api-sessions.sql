-- Additive migration required by services/api for revocable bearer sessions.
-- Apply once after backing up the database. This does not modify existing data.
CREATE TABLE IF NOT EXISTS api_sessions (
    id_session CHAR(36) NOT NULL PRIMARY KEY,
    token_hash CHAR(64) NOT NULL UNIQUE,
    user_type ENUM('customer', 'employee') NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    expires_at DATETIME NOT NULL,
    revoked_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_api_sessions_owner (user_type, user_id),
    KEY idx_api_sessions_expiry (expires_at)
) ENGINE = InnoDB;
