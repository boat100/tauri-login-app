pub mod commands;

use rusqlite::{Connection, Result as SqliteResult};
use std::path::PathBuf;
use std::sync::Mutex;
use tauri::Manager;

pub struct AppState {
    pub db: Mutex<Connection>,
}

pub fn get_db_path(app_handle: &tauri::AppHandle) -> PathBuf {
    let app_data_dir = app_handle.path().app_data_dir().expect("无法获取应用数据目录");
    std::fs::create_dir_all(&app_data_dir).ok();
    app_data_dir.join("users.db")
}

pub fn init_database(app_handle: &tauri::AppHandle) -> SqliteResult<()> {
    let db_path = get_db_path(app_handle);
    let conn = Connection::open(&db_path)?;
    
    conn.execute(
        "CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT DEFAULT 'user',
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )",
        [],
    )?;

    // 插入默认管理员账户
    let admin_password = hash_password("admin123");
    conn.execute(
        "INSERT OR IGNORE INTO users (username, password, role) VALUES (?1, ?2, 'admin')",
        rusqlite::params!["admin", &admin_password],
    )?;

    let state = AppState {
        db: Mutex::new(conn),
    };
    
    app_handle.manage(state);
    
    Ok(())
}

use sha2::{Sha256, Digest};
use base64::{Engine as _, engine::general_purpose};

pub fn hash_password(password: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(password.as_bytes());
    let result = hasher.finalize();
    general_purpose::STANDARD.encode(result)
}

pub fn verify_password(password: &str, hash: &str) -> bool {
    hash_password(password) == hash
}
