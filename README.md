# 登录系统 - Tauri 桌面应用

一个基于 Tauri 的轻量级桌面登录应用，支持用户注册、登录，数据本地存储。

## 功能特性

- 用户注册与登录
- SQLite 数据库本地存储
- 密码 SHA-256 加密
- 开箱即用的单文件安装包
- 跨平台支持（Windows、macOS、Linux）

## 快速开始

### 方式一：下载安装包（推荐）

1. 在 GitHub Releases 页面下载对应平台的安装包
2. Windows: 下载 `.msi` 或安装程序
3. macOS: 下载 `.dmg` 文件
4. Linux: 下载 `.deb` 或 `.AppImage`

### 方式二：从源码构建

#### 前置要求

- [Node.js](https://nodejs.org/) 18+
- [Rust](https://www.rust-lang.org/) 1.70+
- [pnpm](https://pnpm.io/) (推荐)

#### 构建步骤

```bash
# 1. 克隆仓库
git clone <your-repo-url>
cd login-app

# 2. 安装依赖
pnpm install

# 3. 开发模式运行
pnpm dev

# 4. 构建生产版本
pnpm build
```

构建完成后，安装包位于 `src-tauri/target/release/bundle/` 目录。

## 默认账户

- 用户名: `admin`
- 密码: `admin123`

## 技术栈

- **前端**: HTML + CSS + JavaScript
- **后端**: Rust + Tauri
- **数据库**: SQLite (bundled)
- **加密**: SHA-256

## 项目结构

```
login-app/
├── src-tauri/           # Rust 后端
│   ├── src/
│   │   ├── main.rs      # 入口文件
│   │   ├── lib.rs       # 数据库初始化
│   │   ├── commands.rs  # Tauri 命令
│   │   └── database.rs  # 数据库操作
│   ├── Cargo.toml       # Rust 依赖
│   └── tauri.conf.json  # Tauri 配置
├── ui/                  # 前端界面
│   ├── index.html
│   ├── style.css
│   └── script.js
├── .github/
│   └── workflows/
│       └── release.yml  # 自动构建配置
├── package.json
└── README.md
```

## 自动构建

本项目配置了 GitHub Actions 自动构建：

1. 推送 tag 触发构建:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. 或在 GitHub Actions 页面手动触发

构建完成后，可在 Releases 页面下载安装包。

## 许可证

MIT
