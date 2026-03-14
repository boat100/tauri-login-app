# Tauri 登录应用 - GitHub 上传脚本 (Windows)
# 使用方法：在 PowerShell 中运行 .\upload-to-github.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Tauri 登录应用 - GitHub 上传工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "错误：请先安装 git" -ForegroundColor Red
    exit 1
}

# 获取用户输入
$Username = Read-Host "请输入您的 GitHub 用户名"
$RepoName = Read-Host "请输入仓库名称 (默认 login-app)"
if ([string]::IsNullOrWhiteSpace($RepoName)) {
    $RepoName = "login-app"
}

Write-Host ""
Write-Host "即将创建仓库: $Username/$RepoName" -ForegroundColor Yellow
Write-Host ""

# 初始化 git（如果还没有）
if (-not (Test-Path ".git")) {
    git init
    git add .
    git commit -m "Initial commit: Tauri login application"
}

# 获取 Token
Write-Host "请输入您的 GitHub Personal Access Token:" -ForegroundColor Yellow
Write-Host "(Token 需要 repo 权限，可在 GitHub Settings -> Developer settings -> Personal access tokens 创建)"
Write-Host ""
$Token = Read-Host -AsSecureString
$TokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token))

# 使用 GitHub API 创建仓库
Write-Host ""
Write-Host "正在创建 GitHub 仓库..." -ForegroundColor Yellow

$Headers = @{
    "Authorization" = "token $TokenPlain"
    "Accept" = "application/vnd.github.v3+json"
}

$Body = @{
    name = $RepoName
    description = "Tauri 登录应用 - 轻量级桌面登录系统"
    private = $false
} | ConvertTo-Json

try {
    $Response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $Headers -Body $Body -ContentType "application/json"
    Write-Host "✅ 仓库创建成功！" -ForegroundColor Green
}
catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "⚠️  仓库已存在，将推送到现有仓库..." -ForegroundColor Yellow
    }
    else {
        Write-Host "❌ 创建仓库失败: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# 添加远程仓库并推送
git remote remove origin 2>$null
git remote add origin "https://$TokenPlain@github.com/$Username/$RepoName.git"
git branch -M main
git push -u origin main

# 创建 tag 触发自动构建
Write-Host ""
Write-Host "正在创建 tag 触发自动构建..." -ForegroundColor Yellow
git tag v1.0.0
git push origin v1.0.0

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ 上传完成！"
Write-Host ""
Write-Host "仓库地址: https://github.com/$Username/$RepoName"
Write-Host ""
Write-Host "GitHub Actions 正在构建中..."
Write-Host "请访问: https://github.com/$Username/$RepoName/actions"
Write-Host ""
Write-Host "构建完成后，在 Releases 页面下载安装包:"
Write-Host "https://github.com/$Username/$RepoName/releases"
Write-Host "========================================" -ForegroundColor Green
