#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use login_app::{init_database, AppState, commands};
use tauri::Manager;

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .setup(|app| {
            // 初始化数据库
            let app_handle = app.handle();
            init_database(&app_handle).expect("数据库初始化失败");
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            commands::login,
            commands::register,
            commands::get_users,
        ])
        .run(tauri::generate_context!())
        .expect("启动应用失败");
}
