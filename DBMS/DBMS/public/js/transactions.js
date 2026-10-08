/**
 * Transactions Page Logic
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

  // Tab switching
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
      btn.classList.add('active');
      document.getElementById(`tab-${btn.dataset.tab}`).classList.add('active');
    });
  });

  // Load accounts into selects
  let accounts = [];
  try {
    const data = await apiRequest(`/accounts/${user.customerId}`);
    accounts = data.accounts.filter(a => a.status === 'Active');
  } catch (err) { showToast('Failed to load accounts', 'error'); }

  const optionsHtml = accounts.map(a => `<option value="${a.account_id}">${a.account_type} — ****${a.account_number.slice(-4)} (₹${parseFloat(a.balance).toLocaleString('en-IN')})</option>`).join('');
  const histOptions = '<option value="">Select account...</option>' + accounts.map(a => `<option value="${a.account_id}">${a.account_type} — ****${a.account_number.slice(-4)}</option>`).join('');
  ['dep-account', 'wd-account', 'tf-from'].forEach(id => document.getElementById(id).innerHTML = optionsHtml);
  document.getElementById('hist-account').innerHTML = histOptions;

  // Check URL for preselected account
  const params = new URLSearchParams(window.location.search);
  if (params.get('account')) {
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
    document.querySelector('[data-tab="history"]').classList.add('active');
    document.getElementById('tab-history').classList.add('active');
    document.getElementById('hist-account').value = params.get('account');
    loadHistory(params.get('account'));
  }

  // Deposit
  document.getElementById('deposit-form').addEventListener('submit', async e => {
    e.preventDefault();
    const alertBox = document.getElementById('deposit-alert');
    try {
      const res = await apiRequest('/transactions/deposit', { method: 'POST', body: JSON.stringify({ account_id: document.getElementById('dep-account').value, amount: document.getElementById('dep-amount').value, description: document.getElementById('dep-desc').value }) });
      alertBox.innerHTML = `<div class="alert alert-success">✅ ${res.message} Ref: ${res.transaction.reference_number}</div>`;
      showToast('Deposit successful!', 'success');
      document.getElementById('dep-amount').value = '';
      reloadAccountOptions(user.customerId);
    } catch (err) { alertBox.innerHTML = `<div class="alert alert-error">❌ ${err.error}</div>`; }
  });

  // Withdraw
  document.getElementById('withdraw-form').addEventListener('submit', async e => {
    e.preventDefault();
    const alertBox = document.getElementById('withdraw-alert');
    try {
      const res = await apiRequest('/transactions/withdraw', { method: 'POST', body: JSON.stringify({ account_id: document.getElementById('wd-account').value, amount: document.getElementById('wd-amount').value, description: document.getElementById('wd-desc').value }) });
      alertBox.innerHTML = `<div class="alert alert-success">✅ ${res.message} Ref: ${res.transaction.reference_number}</div>`;
      showToast('Withdrawal successful!', 'success');
      document.getElementById('wd-amount').value = '';
      reloadAccountOptions(user.customerId);
    } catch (err) { alertBox.innerHTML = `<div class="alert alert-error">❌ ${err.error}</div>`; }
  });

  // Transfer
  document.getElementById('transfer-form').addEventListener('submit', async e => {
    e.preventDefault();
    const alertBox = document.getElementById('transfer-alert');
    try {
      const res = await apiRequest('/transactions/transfer', { method: 'POST', body: JSON.stringify({ from_account_id: document.getElementById('tf-from').value, to_account_number: document.getElementById('tf-to').value, amount: document.getElementById('tf-amount').value, transfer_type: document.getElementById('tf-type').value, remarks: document.getElementById('tf-remarks').value }) });
      alertBox.innerHTML = `<div class="alert alert-success">✅ ${res.message} Ref: ${res.transfer.reference_number}</div>`;
      showToast('Transfer successful!', 'success');
      document.getElementById('tf-amount').value = '';
      document.getElementById('tf-to').value = '';
      reloadAccountOptions(user.customerId);
    } catch (err) { alertBox.innerHTML = `<div class="alert alert-error">❌ ${err.error}</div>`; }
  });

  // History
  document.getElementById('hist-account').addEventListener('change', e => { if (e.target.value) loadHistory(e.target.value); });
});

async function loadHistory(accountId) {
  const tbody = document.getElementById('hist-tbody');
  tbody.innerHTML = '<tr><td colspan="7" class="text-muted" style="text-align:center;padding:2rem;">Loading...</td></tr>';
  try {
    const data = await apiRequest(`/transactions/${accountId}`);
    if (!data.transactions.length) { tbody.innerHTML = '<tr><td colspan="7" class="text-muted" style="text-align:center;padding:2rem;">No transactions found</td></tr>'; return; }
    tbody.innerHTML = data.transactions.map(t => `<tr>
      <td>${formatDateTime(t.transaction_date)}</td>
      <td>${getTransactionBadge(t.transaction_type)}</td>
      <td class="${['Deposit','Interest Credit'].includes(t.transaction_type) ? 'text-green' : 'text-red'}" style="font-weight:600;">${['Deposit','Interest Credit'].includes(t.transaction_type) ? '+' : '-'}${formatCurrency(t.amount)}</td>
      <td>${formatCurrency(t.balance_after)}</td>
      <td>${t.description || '—'}</td>
      <td style="font-family:monospace;font-size:0.75rem;">${t.reference_number || '—'}</td>
      <td>${getStatusBadge(t.status)}</td>
    </tr>`).join('');
  } catch (err) { tbody.innerHTML = `<tr><td colspan="7" class="alert alert-error">❌ ${err.error}</td></tr>`; }
}

async function reloadAccountOptions(customerId) {
  try {
    const data = await apiRequest(`/accounts/${customerId}`);
    const accs = data.accounts.filter(a => a.status === 'Active');
    const html = accs.map(a => `<option value="${a.account_id}">${a.account_type} — ****${a.account_number.slice(-4)} (₹${parseFloat(a.balance).toLocaleString('en-IN')})</option>`).join('');
    ['dep-account', 'wd-account', 'tf-from'].forEach(id => document.getElementById(id).innerHTML = html);
  } catch (e) { /* ignore */ }
}
