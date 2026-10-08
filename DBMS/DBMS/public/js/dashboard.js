/**
 * Dashboard Page Logic
 */
document.addEventListener('DOMContentLoaded', async () => {
  if (!requireAuth()) return;
  const user = getUser();
  if (user.role === 'admin') { window.location.href = '/admin.html'; return; }

  // Sidebar toggle
  document.getElementById('sidebar-toggle').addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('open');
  });

  // Set user info
  const name = user.customer ? `${user.customer.first_name} ${user.customer.last_name}` : user.email;
  document.getElementById('user-avatar').textContent = name.charAt(0).toUpperCase();
  document.getElementById('user-name').textContent = name;
  document.getElementById('user-email').textContent = user.email;
  document.getElementById('welcome-msg').textContent = `Welcome back, ${user.customer ? user.customer.first_name : 'User'}!`;
  document.getElementById('date-display').textContent = new Date().toLocaleDateString('en-IN', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' });

  try {
    const data = await apiRequest(`/dashboard/${user.customerId}`);
    renderStats(data.summary);
    renderTransactions(data.recentTransactions);
    renderAccountsPreview(data.accounts);
  } catch (err) {
    showToast(err.error || 'Failed to load dashboard', 'error');
  }
});

function renderStats(s) {
  const balElem = document.getElementById('stat-balance');
  const accElem = document.getElementById('stat-accounts');
  const loanElem = document.getElementById('stat-loans');
  
  if (balElem) balElem.textContent = formatCurrency(s.totalBalance);
  if (accElem) accElem.textContent = `${s.activeAccounts} Active`;
  if (loanElem) loanElem.textContent = formatCurrency(s.totalOutstanding);
}

function renderTransactions(txns) {
  const tbody = document.getElementById('txn-tbody');
  if (!tbody) return;
  if (!txns || txns.length === 0) { 
    tbody.innerHTML = '<tr><td colspan="7" class="text-muted" style="text-align:center;padding:2rem;">No recent transactions</td></tr>'; 
    return; 
  }
  tbody.innerHTML = txns.map(t => `<tr class="animate-fade">
    <td>${formatDateTime(t.transaction_date)}</td>
    <td style="font-family:'Courier New', monospace;font-weight:700;">${t.account_number ? '•••• ' + t.account_number.slice(-4) : '—'}</td>
    <td>${getTransactionBadge(t.transaction_type)}</td>
    <td style="font-family:monospace;font-size:0.8rem;color:var(--text-muted);">${t.reference_number || 'TXN-GEN'}</td>
    <td class="${t.transaction_type === 'Deposit' || t.transaction_type === 'Interest Credit' ? 'text-green' : 'text-red'}" style="font-weight:800;font-family:'Outfit';">
      ${t.transaction_type === 'Deposit' || t.transaction_type === 'Interest Credit' ? '+' : '-'}${formatCurrency(t.amount)}
    </td>
    <td style="font-family:'Outfit';font-weight:700;">${formatCurrency(t.balance_after)}</td>
    <td>${getStatusBadge(t.status)}</td>
  </tr>`).join('');
}

function renderAccountsPreview(accounts) {
  const container = document.getElementById('accounts-preview');
  if (!container) return;
  if (!accounts || accounts.length === 0) { 
    container.innerHTML = '<div class="empty-state"><div class="empty-icon">💳</div><h3>No bank accounts yet</h3><p>Open your first account to start digital banking.</p></div>'; 
    return; 
  }
  container.innerHTML = accounts.slice(0, 3).map(a => {
    const typeClass = a.account_type === 'Savings' ? 'savings' : a.account_type === 'Current' ? 'current' : 'fd';
    return `<div class="account-card ${typeClass} animate-fade">
      <div style="display:flex;justify-content:space-between;align-items:center;">
        <span class="type-badge">${a.account_type} Account</span>
        ${getStatusBadge(a.status)}
      </div>
      <div class="acc-num">
        <span>•••• •••• •••• ${a.account_number.slice(-4)}</span>
        <button class="copy-btn" onclick="navigator.clipboard.writeText('${a.account_number}');showToast('Account number copied!','info')" title="Copy Account Number">📋</button>
      </div>
      <div class="balance-amount"><span style="font-size:1.1rem;color:var(--text-muted);">₹</span>${parseFloat(a.balance).toLocaleString('en-IN', {minimumFractionDigits:2})}</div>
      <div style="display:flex;justify-content:space-between;margin-top:1rem;font-size:0.75rem;color:var(--text-muted);">
        <span>Branch: <strong>${a.branch_code}</strong></span>
        <span>Interest: <strong>${a.interest_rate}% p.a.</strong></span>
      </div>
    </div>`;
  }).join('');
}
