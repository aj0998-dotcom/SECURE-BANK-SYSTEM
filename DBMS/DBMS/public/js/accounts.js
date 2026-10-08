/**
 * Accounts Page Logic
 */
document.addEventListener('DOMContentLoaded', async () => {
  if (!requireAuth()) return;
  const user = getUser();
  if (user.role === 'admin') { window.location.href = '/admin.html'; return; }

  document.getElementById('sidebar-toggle').addEventListener('click', () => document.getElementById('sidebar').classList.toggle('open'));
  const name = user.customer ? `${user.customer.first_name} ${user.customer.last_name}` : user.email;
  document.getElementById('user-avatar').textContent = name.charAt(0).toUpperCase();
  document.getElementById('user-name').textContent = name;
  document.getElementById('user-email').textContent = user.email;

  const modal = document.getElementById('modal-overlay');
  document.getElementById('btn-new-account').addEventListener('click', () => modal.classList.remove('hidden'));
  document.getElementById('modal-cancel').addEventListener('click', () => modal.classList.add('hidden'));
  modal.addEventListener('click', e => { if (e.target === modal) modal.classList.add('hidden'); });

  await loadAccounts();

  document.getElementById('create-account-form').addEventListener('submit', async e => {
    e.preventDefault();
    const alertBox = document.getElementById('modal-alert');
    try {
      await apiRequest('/accounts', {
        method: 'POST',
        body: JSON.stringify({
          customer_id: user.customerId,
          account_type: document.getElementById('acc-type').value,
          branch_code: document.getElementById('acc-branch').value,
          initial_deposit: document.getElementById('acc-deposit').value
        })
      });
      showToast('New bank account opened successfully!', 'success');
      modal.classList.add('hidden');
      await loadAccounts();
    } catch (err) {
      alertBox.innerHTML = `<div class="alert alert-error">❌ ${err.error || 'Failed to create account'}</div>`;
    }
  });
});

async function loadAccounts() {
  const user = getUser();
  const container = document.getElementById('accounts-container');
  const custName = user.customer ? `${user.customer.first_name} ${user.customer.last_name}` : 'ACCOUNT HOLDER';

  try {
    const data = await apiRequest(`/accounts/${user.customerId}`);
    if (!data.accounts || data.accounts.length === 0) {
      container.innerHTML = '<div class="empty-state"><div class="empty-icon">💳</div><h3>No accounts found</h3><p>Click "Open New Account" to get started.</p></div>';
      return;
    }

    container.innerHTML = data.accounts.map(a => {
      const tc = a.account_type === 'Savings' ? 'savings' : a.account_type === 'Current' ? 'current' : 'fd';
      const formattedNum = a.account_number.replace(/(.{4})/g, '$1 ').trim();
      
      return `<div class="account-card ${tc} animate-fade">
        <div style="display:flex;justify-content:space-between;align-items:center;">
          <span class="type-badge">${a.account_type} Account</span>
          ${getStatusBadge(a.status)}
        </div>

        <div class="acc-num" style="margin-top:0.75rem;">
          <span>${formattedNum}</span>
          <button class="copy-btn" onclick="navigator.clipboard.writeText('${a.account_number}');showToast('Account number copied!','info')" title="Copy Account Number">📋</button>
        </div>

        <div class="balance-amount">
          <span style="font-size:1.1rem;color:var(--text-muted);">₹</span>${parseFloat(a.balance).toLocaleString('en-IN', {minimumFractionDigits: 2})}
        </div>

        <!-- Realistic Card Graphic Widget -->
        <div class="bank-card-visual" style="margin: 1.25rem 0;">
          <div class="bank-card-header">
            <span class="bank-card-brand">SecureBank</span>
            <div class="bank-card-chip"></div>
          </div>
          <div class="bank-card-number">•••• •••• •••• ${a.account_number.slice(-4)}</div>
          <div class="bank-card-footer">
            <span class="bank-card-holder">${custName}</span>
            <span>VALID THRU 12/28</span>
          </div>
        </div>

        <div style="display:flex;justify-content:space-between;font-size:0.75rem;color:var(--text-muted);margin-bottom:1.25rem;">
          <span>Branch: <strong>${a.branch_code}</strong></span>
          <span>Opened: <strong>${formatDate(a.opening_date)}</strong></span>
          <span>Interest: <strong>${a.interest_rate}% p.a.</strong></span>
        </div>

        <div style="display:flex;gap:0.5rem;">
          <a href="/transactions.html" class="btn btn-outline btn-sm" style="flex:1;">💸 Transfer Money</a>
          ${a.status === 'Active' ? `<button class="btn btn-danger btn-sm" onclick="closeAccount(${a.account_id})">Close Account</button>` : ''}
        </div>
      </div>`;
    }).join('');
  } catch (err) {
    container.innerHTML = `<div class="alert alert-error">❌ ${err.error || 'Failed to load accounts'}</div>`;
  }
}

async function closeAccount(accountId) {
  if (!confirm('Are you sure you want to close this account? Status will be updated to Closed.')) return;
  try {
    await apiRequest(`/accounts/${accountId}`, { method: 'DELETE' });
    showToast('Account closed successfully.', 'success');
    await loadAccounts();
  } catch (err) {
    showToast(err.error || 'Failed to close account', 'error');
  }
}
