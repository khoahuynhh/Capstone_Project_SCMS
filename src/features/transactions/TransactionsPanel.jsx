import { useEffect, useMemo, useState } from 'react';
import { serverApi as api } from '../../core/api';

export default function TransactionsPanel() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [branches, setBranches] = useState([]);
  const [branch, setBranch] = useState('');
  const [transactions, setTransactions] = useState([]);

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        const b = await api.branches();
        if (!mounted) return;
        const list = Array.isArray(b?.branches) ? b.branches : [];
        setBranches(list);
        if (list.length) {
          setBranch((current) => current || list[0]);
        }
      } catch (e) {
        if (!mounted) return;
        setError(e?.message || 'Failed to load branches');
      }
    })();
    return () => { mounted = false; };
  }, []);

  useEffect(() => {
    let mounted = true;
    (async () => {
      if (!branch) { setTransactions([]); return; }
      try {
        setLoading(true);
        setError(null);
        const tx = await api.transactions({ branchId: branch, limit: 25 });
        if (!mounted) return;
        setTransactions(Array.isArray(tx) ? tx : []);
      } catch (e) {
        if (!mounted) return;
        setError(e?.message || 'Failed to load transactions');
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    return () => { mounted = false; };
  }, [branch]);

  const totals = useMemo(() => {
    const total = transactions.reduce((s, t) => s + (t?.total_amount || 0), 0);
    return {
      count: transactions.length,
      amount: total,
    };
  }, [transactions]);

  return (
    <div className="mt-4 w-full max-w-6xl mx-auto">
      <div className="bg-slate-800/60 border border-slate-700 rounded-lg p-3 text-slate-100">
        <div className="flex items-center justify-between gap-3">
          <div className="text-sm font-semibold">Recent Transactions</div>
          <div className="flex items-center gap-2">
            <label className="text-xs text-slate-300">Branch</label>
            <select
              value={branch}
              onChange={(e) => setBranch(e.target.value)}
              className="bg-slate-900/60 border border-slate-700 rounded px-2 py-1 text-sm"
            >
              {branches.map(b => (
                <option key={b} value={b}>{b}</option>
              ))}
            </select>
          </div>
        </div>

        <div className="mt-2 text-xs text-slate-300">
          {loading ? 'Loading…' : error ? `Error: ${error}` : `${totals.count} items · ${Intl.NumberFormat('vi-VN').format(totals.amount)}₫`}
        </div>

        <div className="mt-2 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2">
          {transactions.map(tx => (
            <div key={tx.id} className="bg-slate-900/40 rounded p-2 text-sm border border-slate-700/50">
              <div className="font-medium text-slate-100">{tx.transaction_id}</div>
              <div className="text-slate-300">{new Date(tx.timestamp).toLocaleString('vi-VN')}</div>
              <div className="mt-1 flex items-center justify-between">
                <span className="text-slate-400">Items: {tx.items_count ?? 0}</span>
                <span className="font-semibold">{Intl.NumberFormat('vi-VN').format(tx.total_amount ?? 0)}₫</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
