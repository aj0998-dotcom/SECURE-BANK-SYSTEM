/**
 * Admin Panel Logic
 */
document.addEventListener('DOMContentLoaded', async () => {
  if (!requireAuth()) return;
  const user = getUser();
  if (user.role !== 'admin') { window.location.href = '/dashboard.html'; return; }

  document.getElementById('sidebar-toggle').addEventListener('click', () => document.getElementById('sidebar').classList.toggle('open'));
  document.getElementById('user-name').textContent = 'Administrator';
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

  // Load stats
  try {
    const stats = await apiRequest('/admin/stats');
    document.getElementById('admin-stats').innerHTML = `
      <div class="stat-card blue animate-fade"><div class="stat-icon">👥</div><div class="stat-value">${stats.totalCustomers}</div><div class="stat-label">Registered Customers</div></div>
      <div class="stat-card emerald animate-fade" style="animation-delay:.1s"><div class="stat-icon">💳</div><div class="stat-value">${stats.activeAccounts}</div><div class="stat-label">Active Bank Accounts</div></div>
      <div class="stat-card violet animate-fade" style="animation-delay:.2s"><div class="stat-icon">💰</div><div class="stat-value">${formatCurrency(stats.totalBalance)}</div><div class="stat-label">Total System Deposits</div></div>
      <div class="stat-card amber animate-fade" style="animation-delay:.3s"><div class="stat-icon">📋</div><div class="stat-value">${stats.totalTransactions}</div><div class="stat-label">Global Transaction Logs</div></div>
    `;
  } catch (err) { showToast('Failed to load system stats', 'error'); }

  // Load customers
  try {
    const data = await apiRequest('/admin/customers');
    document.getElementById('cust-tbody').innerHTML = data.customers.map(c => `<tr class="animate-fade">
      <td>#${c.customer_id}</td>
      <td><strong>${c.first_name} ${c.last_name}</strong></td>
      <td>${c.email}</td>
      <td>${c.phone}</td>
      <td><span class="badge ${c.customer_type === 'Business' ? 'badge-transfer' : 'badge-active'}">${c.customer_type}</span></td>
      <td><strong>${c.account_count}</strong> Accounts</td>
      <td style="font-weight:800;font-family:'Outfit';color:var(--accent-emerald);">${formatCurrency(c.total_balance)}</td>
      <td>${getStatusBadge(c.status)}</td>
    </tr>`).join('');
  } catch (err) { document.getElementById('cust-tbody').innerHTML = '<tr><td colspan="8" class="text-muted">Failed to load customer directory</td></tr>'; }

  // Load accounts
  try {
    const data = await apiRequest('/admin/accounts');
    document.getElementById('acc-tbody').innerHTML = data.accounts.map(a => `<tr class="animate-fade">
      <td>#${a.account_id}</td>
      <td style="font-family:'Courier New', monospace;font-weight:700;">${a.account_number}</td>
      <td><strong>${a.customer_name}</strong></td>
      <td><span class="type-badge">${a.account_type}</span></td>
      <td style="font-weight:800;font-family:'Outfit';">${formatCurrency(a.balance)}</td>
      <td>${a.branch_code}</td>
      <td>${formatDate(a.opening_date)}</td>
      <td>${getStatusBadge(a.status)}</td>
    </tr>`).join('');
  } catch (err) { document.getElementById('acc-tbody').innerHTML = '<tr><td colspan="8" class="text-muted">Failed to load accounts registry</td></tr>'; }

  // Load transactions
  try {
    const data = await apiRequest('/admin/transactions');
    document.getElementById('txn-tbody').innerHTML = data.transactions.map(t => `<tr class="animate-fade">
      <td>#${t.transaction_id}</td>
      <td><strong>${t.customer_name}</strong></td>
      <td style="font-family:'Courier New', monospace;font-size:0.85rem;">•••• ${t.account_number ? t.account_number.slice(-4) : '—'}</td>
      <td>${getTransactionBadge(t.transaction_type)}</td>
      <td style="font-family:monospace;font-size:0.8rem;color:var(--text-muted);">${t.reference_number || '—'}</td>
      <td class="${['Deposit','Interest Credit'].includes(t.transaction_type) ? 'text-green' : 'text-red'}" style="font-weight:800;font-family:'Outfit';">
        ${['Deposit','Interest Credit'].includes(t.transaction_type) ? '+' : '-'}${formatCurrency(t.amount)}
      </td>
      <td style="font-family:'Outfit';font-weight:700;">${formatCurrency(t.balance_after)}</td>
      <td>${formatDateTime(t.transaction_date)}</td>
      <td>${getStatusBadge(t.status)}</td>
    </tr>`).join('');
  } catch (err) { document.getElementById('txn-tbody').innerHTML = '<tr><td colspan="9" class="text-muted">Failed to load transaction audit trail</td></tr>'; }
});
