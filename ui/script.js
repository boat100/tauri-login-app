const { invoke } = window.__TAURI__.core;

// 页面切换
const loginPage = document.getElementById('loginPage');
const registerPage = document.getElementById('registerPage');
const successPage = document.getElementById('successPage');

function showPage(pageId) {
  [loginPage, registerPage, successPage].forEach(page => {
    page.classList.remove('active');
  });
  document.getElementById(pageId).classList.add('active');
}

// 页面切换事件
document.getElementById('showRegister').addEventListener('click', (e) => {
  e.preventDefault();
  showPage('registerPage');
});

document.getElementById('showLogin').addEventListener('click', (e) => {
  e.preventDefault();
  showPage('loginPage');
});

// 登录处理
const loginForm = document.getElementById('loginForm');
const loginBtn = document.getElementById('loginBtn');
const loginMessage = document.getElementById('loginMessage');

loginForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  const username = document.getElementById('loginUsername').value.trim();
  const password = document.getElementById('loginPassword').value;

  if (!username || !password) {
    showMessage(loginMessage, '请填写用户名和密码', 'error');
    return;
  }

  setLoading(loginBtn, true);
  loginMessage.style.display = 'none';

  try {
    const response = await invoke('login', {
      request: { username, password }
    });

    if (response.success) {
      showMessage(loginMessage, response.message, 'success');
      
      setTimeout(() => {
        document.getElementById('displayUsername').textContent = response.user.username;
        document.getElementById('displayRole').textContent = response.user.role === 'admin' ? '管理员' : '普通用户';
        showPage('successPage');
      }, 500);
    } else {
      showMessage(loginMessage, response.message, 'error');
    }
  } catch (error) {
    showMessage(loginMessage, '登录失败：' + error, 'error');
  } finally {
    setLoading(loginBtn, false);
  }
});

// 注册处理
const registerForm = document.getElementById('registerForm');
const registerBtn = document.getElementById('registerBtn');
const registerMessage = document.getElementById('registerMessage');

registerForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  const username = document.getElementById('regUsername').value.trim();
  const password = document.getElementById('regPassword').value;
  const confirmPassword = document.getElementById('regConfirmPassword').value;

  if (!username || !password || !confirmPassword) {
    showMessage(registerMessage, '请填写所有字段', 'error');
    return;
  }

  if (username.length < 3) {
    showMessage(registerMessage, '用户名至少3个字符', 'error');
    return;
  }

  if (password.length < 6) {
    showMessage(registerMessage, '密码至少6个字符', 'error');
    return;
  }

  if (password !== confirmPassword) {
    showMessage(registerMessage, '两次密码输入不一致', 'error');
    return;
  }

  setLoading(registerBtn, true);
  registerMessage.style.display = 'none';

  try {
    const response = await invoke('register', {
      request: { username, password }
    });

    if (response.success) {
      showMessage(registerMessage, response.message, 'success');
      
      setTimeout(() => {
        // 注册成功后自动跳转到登录页并填充用户名
        document.getElementById('loginUsername').value = username;
        showPage('loginPage');
      }, 1000);
    } else {
      showMessage(registerMessage, response.message, 'error');
    }
  } catch (error) {
    showMessage(registerMessage, '注册失败：' + error, 'error');
  } finally {
    setLoading(registerBtn, false);
  }
});

// 退出登录
document.getElementById('logoutBtn').addEventListener('click', () => {
  // 清空表单
  document.getElementById('loginUsername').value = '';
  document.getElementById('loginPassword').value = '';
  loginMessage.style.display = 'none';
  showPage('loginPage');
});

// 工具函数
function showMessage(element, text, type) {
  element.textContent = text;
  element.className = 'message ' + type;
  element.style.display = 'block';
}

function setLoading(button, loading) {
  if (loading) {
    button.classList.add('loading');
    button.disabled = true;
  } else {
    button.classList.remove('loading');
    button.disabled = false;
  }
}
