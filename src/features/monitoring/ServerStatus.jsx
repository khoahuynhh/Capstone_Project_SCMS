import { useEffect, useMemo, useState } from 'react';
import { serverApi as api } from '../../../core/api';

const StatusPill = ({ ok, label }) => (
  <span className={`px-2 py-0.5 rounded text-xs font-medium ${ok ? 'bg-green-600/20 text-green-200' : 'bg-red-600/20 text-red-200'}`}>
    {label}
  </span>
);

export default function ServerStatus() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [health, setHealth] = useState(null);
  const [summary, setSummary] = useState(null);
  const [branches, setBranches] = useState([]);

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        setLoading(true);
        setError(null);
        const [h, s, b] = await Promise.all([
          api.health().catch(() => null),
          api.metricsSummary().catch(() => null),
          api.branches().catch(() => null),
        ]);
        if (!mounted) return;
        setHealth(h);
        setSummary(s);
        setBranches(Array.isArray(b?.branches) ? b.branches : []);
      } catch (e) {
        if (!mounted) return;
        setError(e?.message || 'Unknown error');
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    return () => { mounted = false; };
  }, []);

  const stats = useMemo(() => ({
    transactions: summary?.total_transactions ?? 0,
    revenue: summary?.total_revenue ?? 0,
    branches: branches.length,
  }), [summary, branches]);

  return (
    <div className="mt-4 w-full max-w-6xl mx-auto">
      <div className="bg-slate-800/60 border border-slate-700 rounded-lg p-3 text-slate-100">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="text-sm font-semibold">Cloud Server</span>
            <StatusPill ok={!!health} label={health ? 'Connected' : 'Offline'} />
            {health && (
              <>
                <StatusPill ok={!!health?.mqtt} label={`MQTT: ${health?.mqtt ? 'OK' : 'Down'}`} />
                <StatusPill ok label={`DB: assumed OK`} />
              </>
            )}
          </div>
          <div className="text-xs text-slate-300">
            {loading ? 'Loading…' : error ? `Error: ${error}` : 'Synced'}
          </div>
        </div>

        <div className="mt-2 grid grid-cols-3 gap-3 text-sm">
          <div className="bg-slate-900/40 rounded p-2">
            <div className="text-slate-400">24h Transactions</div>
            <div className="text-lg font-semibold">{stats.transactions}</div>
          </div>
          <div className="bg-slate-900/40 rounded p-2">
            <div className="text-slate-400">24h Revenue</div>
            <div className="text-lg font-semibold">{Intl.NumberFormat('vi-VN').format(stats.revenue)}₫</div>
          </div>
          <div className="bg-slate-900/40 rounded p-2">
            <div className="text-slate-400">Active Branches</div>
            <div className="text-lg font-semibold">{stats.branches}</div>
          </div>
        </div>

        {!!branches.length && (
          <div className="mt-2 text-xs text-slate-300">
            Branches: {branches.join(', ')}
          </div>
        )}
      </div>
    </div>
  );
}
