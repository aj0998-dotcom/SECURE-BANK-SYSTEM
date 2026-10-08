/**
 * Login Page Logic
 */
document.addEventListener('DOMContentLoaded', () => {
  // Redirect if already logged in
  if (isLoggedIn()) {
    const user = getUser();
    window.location.href = user && user.role === 'admin' ? '/admin.html' : '/dashboard.html';
    return;
  }

  let selectedRole = 'customer';
  const form = document.getElementById('login-form');
  const alertBox = document.getElementById('alert-box');
  const roleButtons = document.querySelectorAll('#role-toggle button');
  const registerSection = document.getElementById('register-section');
  const loginForm = document.getElementById('login-form');
  const regForm = document.getElementById('register-form');

  // Role toggle
  roleButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      roleButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      selectedRole = btn.dataset.role;
      if (selectedRole === 'admin') {
        document.getElementById('login-email').value = 'admin@securebank.com';
      } else {
        document.getElementById('login-email').value = '';
      }
    });
  });

  // Show register / login toggle
  document.getElementById('show-register').addEventListener('click', e => {
    e.preventDefault();
    loginForm.parentElement.querySelector('h2').style.display = 'none';
    loginForm.parentElement.querySelector('.subtitle').style.display = 'none';
    document.getElementById('role-toggle').style.display = 'none';
    loginForm.style.display = 'none';
    loginForm.nextElementSibling.style.display = 'none';
    registerSection.classList.remove('hidden');
  });
  document.getElementById('show-login').addEventListener('click', e => {
    e.preventDefault();
    loginForm.parentElement.querySelector('h2').style.display = '';
    loginForm.parentElement.querySelector('.subtitle').style.display = '';
    document.getElementById('role-toggle').style.display = '';
    loginForm.style.display = '';
    loginForm.nextElementSibling.style.display = '';
    registerSection.classList.add('hidden');
  });

  // Login submit
  form.addEventListener('submit', async e => {
    e.preventDefault();
    const email = document.getElementById('login-email').value.trim();
    const password = document.getElementById('login-password').value;
    const btn = document.getElementById('login-btn');

    if (!email || !password) {
      alertBox.innerHTML = '<div class="alert alert-error">❌ Please fill in all fields.</div>';
      return;
    }

    btn.disabled = true;
    btn.innerHTML = '<span class="spinner"></span> Signing in...';
    alertBox.innerHTML = '';

    try {
      const data = await apiRequest('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password })
      });
      setToken(data.token);
      setUser(data.user);
      alertBox.innerHTML = '<div class="alert alert-success">✅ Login successful! Redirecting...</div>';
      setTimeout(() => {
        window.location.href = data.user.role === 'admin' ? '/admin.html' : '/dashboard.html';
      }, 800);
    } catch (err) {
      alertBox.innerHTML = `<div class="alert alert-error">❌ ${err.error || 'Login failed.'}</div>`;
      btn.disabled = false;
      btn.innerHTML = 'Sign In';
    }
  });

  // Register submit
  regForm.addEventListener('submit', async e => {
    e.preventDefault();
    const regBtn = document.getElementById('reg-btn');
    const regAlert = document.getElementById('reg-alert-box');
    const body = {
      first_name: document.getElementById('reg-fname').value.trim(),
      last_name: document.getElementById('reg-lname').value.trim(),
      date_of_birth: document.getElementById('reg-dob').value,
      email: document.getElementById('reg-email').value.trim(),
      phone: document.getElementById('reg-phone').value.trim(),
      address: document.getElementById('reg-address').value.trim(),
      pan_number: document.getElementById('reg-pan').value.trim().toUpperCase(),
      aadhar_number: document.getElementById('reg-aadhar').value.trim(),
      password: document.getElementById('reg-password').value
    };

    if (!body.first_name || !body.last_name || !body.date_of_birth || !body.email || !body.phone || !body.pan_number || !body.aadhar_number || !body.password) {
      regAlert.innerHTML = '<div class="alert alert-error">❌ All fields are required.</div>';
      return;
    }

    regBtn.disabled = true;
    regBtn.innerHTML = '<span class="spinner"></span> Registering...';
    regAlert.innerHTML = '';

    try {
      await apiRequest('/auth/register', { method: 'POST', body: JSON.stringify(body) });
      regAlert.innerHTML = '<div class="alert alert-success">✅ Registration successful! Please sign in.</div>';
      setTimeout(() => document.getElementById('show-login').click(), 1500);
    } catch (err) {
      regAlert.innerHTML = `<div class="alert alert-error">❌ ${err.error || 'Registration failed.'}</div>`;
    }
    regBtn.disabled = false;
    regBtn.innerHTML = 'Register';
  });
});
