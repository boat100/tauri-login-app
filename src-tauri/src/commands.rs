use crate::{AppState, hash_password, verify_password};
use serde::{Deserialize, Serialize};
use tauri::State;

#[derive(Debug, Serialize, Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LoginResponse {
    pub success: bool,
    pub message: String,
    pub user: Option<UserInfo>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserInfo {
    pub username: String,
    pub role: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RegisterRequest {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    pub id: i32,
    pub username: String,
    pub role: String,
}

#[tauri::command]
pub fn login(state: State<'_, AppState>, request: LoginRequest) -> LoginResponse {
    let db = state.db.lock().expect("无法获取数据库连接");
    
    let mut stmt = db
        .prepare("SELECT password, role FROM users WHERE username = ?1")
        .expect("SQL 准备失败");

    let result = stmt.query_row([&request.username], |row| {
        Ok((row.get::<_, String>(0)?, row.get::<_, String>(1)?))
    });

    match result {
        Ok((stored_password, role)) => {
            if verify_password(&request.password, &stored_password) {
                LoginResponse {
                    success: true,
                    message: "登录成功！".to_string(),
                    user: Some(UserInfo {
                        username: request.username,
                        role,
                    }),
                }
            } else {
                LoginResponse {
                    success: false,
                    message: "用户名或密码错误".to_string(),
                    user: None,
                }
            }
        }
        Err(_) => LoginResponse {
            success: false,
            message: "用户名或密码错误".to_string(),
            user: None,
        },
    }
}

#[tauri::command]
pub fn register(state: State<'_, AppState>, request: RegisterRequest) -> LoginResponse {
    let db = state.db.lock().expect("无法获取数据库连接");
    
    let hashed_password = hash_password(&request.password);
    
    let result = db.execute(
        "INSERT INTO users (username, password, role) VALUES (?1, ?2, 'user')",
        [&request.username, &hashed_password],
    );

    match result {
        Ok(_) => LoginResponse {
            success: true,
            message: "注册成功！".to_string(),
            user: Some(UserInfo {
                username: request.username,
                role: "user".to_string(),
            }),
        },
        Err(_) => LoginResponse {
            success: false,
            message: "用户名已存在".to_string(),
            user: None,
        },
    }
}

#[tauri::command]
pub fn get_users(state: State<'_, AppState>) -> Vec<User> {
    let db = state.db.lock().expect("无法获取数据库连接");
    
    let mut stmt = db
        .prepare("SELECT id, username, role FROM users")
        .expect("SQL 准备失败");

    let users = stmt
        .query_map([], |row| {
            Ok(User {
                id: row.get(0)?,
                username: row.get(1)?,
                role: row.get(2)?,
            })
        })
        .expect("查询失败");

    users.filter_map(|u| u.ok()).collect()
}
