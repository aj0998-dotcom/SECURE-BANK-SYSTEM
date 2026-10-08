/**
 * API Helper - Centralized fetch wrapper with JWT auth
 */
const API_BASE = '/api';

function getToken() { return localStorage.getItem('sb_token'); }
function setToken(token) { localStorage.setItem('sb_token', token); }
function getUser() { const u = localStorage.getItem('sb_user'); return u ? JSON.parse(u) : null; }
function setUser(user) { localStorage.setItem('sb_user', JSON.stringify(user)); }
function clearAuth() { localStorage.removeItem('sb_token'); localStorage.removeItem('sb_user'); }

function isLoggedIn() { return !!getToken(); }
function requireAuth() { if (!isLoggedIn()) { window.location.href = '/'; return false; } return true; }

async function apiRequest(endpoint, options = {}) {
  const token = getToken();
  const headers = { 'Content-Type': 'application/json', ...(options.headers || {}) };
  if (token) headers['Authorization'] = `Bearer ${token}`;
  try {
    const res = await fetch(`${API_BASE}${endpoint}`, { ...options, headers });
    const data = await res.json();
    if (res.status === 401 || res.status === 403) {
      if (data.error && data.error.includes('expired')) { clearAuth(); window.location.href = '/'; }
    }
    if (!res.ok) throw { status: res.status, ...data };
    return data;
  } catch (err) {
    if (err.status) throw err;
    throw { status: 0, error: 'Network error. Please check your connection.' };
  }
}

function showToast(message, type = 'success') {
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    container.className = 'toast-container';
    document.body.appendChild(container);
  }
  const icons = { success: '✅', error: '❌', warning: '⚠️', info: 'ℹ️' };
  const toast = document.createElement('div');
  toast.className = `alert alert-${type}`;
  toast.innerHTML = `<span>${icons[type] || ''}</span> ${message}`;
  container.appendChild(toast);
  setTimeout(() => { toast.style.opacity = '0'; toast.style.transform = 'translateX(100px)'; setTimeout(() => toast.remove(), 300); }, 4000);
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 2 }).format(amount);
}

function formatDate(dateStr) {
  if (!dateStr) return '—';
  return new Date(dateStr).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
}

function formatDateTime(dateStr) {
  if (!dateStr) return '—';
  return new Date(dateStr).toLocaleString('en-IN', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function getStatusBadge(status) {
  const s = (status || '').toLowerCase();
  let cls = 'badge-active';
  if (['inactive', 'pending', 'applied', 'initiated', 'processing'].includes(s)) cls = 'badge-pending';
  else if (['blocked', 'failed', 'rejected', 'reversed'].includes(s)) cls = 'badge-failed';
  else if (['closed', 'frozen', 'expired', 'deleted'].includes(s)) cls = 'badge-closed';
  return `<span class="badge ${cls}">${status}</span>`;
}

function getTransactionBadge(type) {
  const t = (type || '').toLowerCase();
  if (t.includes('deposit') || t.includes('credit')) return `<span class="badge badge-deposit">${type}</span>`;
  if (t.includes('withdrawal') || t.includes('debit')) return `<span class="badge badge-withdrawal">${type}</span>`;
  return `<span class="badge badge-transfer">${type}</span>`;
}

function logout() { clearAuth(); window.location.href = '/'; }
