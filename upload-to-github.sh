#!/bin/bash

# Tauri 登录应用 - GitHub 上传脚本
# 使用方法：bash upload-to-github.sh

set -e

echo "========================================"
echo "  Tauri 登录应用 - GitHub 上传工具"
echo "========================================"
echo ""

# 检查 git
if ! command -v git &> /dev/null; then
    echo "错误：请先安装 git"
    exit 1
fi

# 获取用户输入
read -p "请输入您的 GitHub 用户名: " USERNAME
read -p "请输入仓库名称 (默认 login-app): " REPO_NAME
REPO_NAME=${REPO_NAME:-login-app}

echo ""
echo "即将创建仓库: $USERNAME/$REPO_NAME"
echo ""

# 初始化 git（如果还没有）
if [ ! -d ".git" ]; then
    git init
    git add .
    git commit -m "Initial commit: Tauri login application"
fi

# 创建 GitHub 仓库并推送
echo "请输入您的 GitHub Personal Access Token:"
echo "(Token 需要 repo 权限，可在 GitHub Settings -> Developer settings -> Personal access tokens 创建)"
echo ""
read -s TOKEN

# 使用 GitHub API 创建仓库
echo ""
echo "正在创建 GitHub 仓库..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user/repos \
    -d "{\"name\":\"$REPO_NAME\",\"description\":\"Tauri 登录应用 - 轻量级桌面登录系统\",\"private\":false}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "201" ]; then
    echo "✅ 仓库创建成功！"
elif [ "$HTTP_CODE" = "422" ]; then
    echo "⚠️  仓库已存在，将推送到现有仓库..."
else
    echo "❌ 创建仓库失败: $BODY"
    exit 1
fi

# 添加远程仓库并推送
git remote remove origin 2>/dev/null || true
git remote add origin https://$TOKEN@github.com/$USERNAME/$REPO_NAME.git
git branch -M main
git push -u origin main

# 创建 tag 触发自动构建
echo ""
echo "正在创建 tag 触发自动构建..."
git tag v1.0.0
git push origin v1.0.0

echo ""
echo "========================================"
echo "✅ 上传完成！"
echo ""
echo "仓库地址: https://github.com/$USERNAME/$REPO_NAME"
echo ""
echo "GitHub Actions 正在构建中..."
echo "请访问: https://github.com/$USERNAME/$REPO_NAME/actions"
echo ""
echo "构建完成后，在 Releases 页面下载安装包:"
echo "https://github.com/$USERNAME/$REPO_NAME/releases"
echo "========================================"
