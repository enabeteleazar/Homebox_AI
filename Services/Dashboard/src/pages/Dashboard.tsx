import { useSystemSummary } from "@/hooks/use-dashboard";
import { MetricCard } from "@/components/MetricCard";
import { RadialProgress } from "@/components/RadialProgress";
import { StatusBadge } from "@/components/StatusBadge";
import { 
  Activity, 
  Server, 
  HardDrive, 
  Box, 
  Clock, 
  Cpu, 
  Thermometer 
} from "lucide-react";
import { motion } from "framer-motion";
import { formatDistanceToNow } from "date-fns";

function DashboardLoading() {
  return (
    <div className="min-h-screen bg-background p-8 flex items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <div className="h-12 w-12 border-4 border-primary border-t-transparent rounded-full animate-spin" />
        <p className="text-muted-foreground animate-pulse">Establishing connection to mainframe...</p>
      </div>
    </div>
  );
}

function DashboardError() {
  return (
    <div className="min-h-screen bg-background p-8 flex items-center justify-center">
      <div className="max-w-md text-center space-y-4">
        <div className="inline-flex h-16 w-16 items-center justify-center rounded-full bg-destructive/10 text-destructive mb-4">
          <Activity className="h-8 w-8" />
        </div>
        <h1 className="text-2xl font-bold font-display">System Offline</h1>
        <p className="text-muted-foreground">Unable to retrieve telemetry data. The backend services might be down or unreachable.</p>
        <button 
          onClick={() => window.location.reload()}
          className="mt-6 px-6 py-2 bg-white text-black font-semibold rounded-lg hover:bg-gray-200 transition-colors"
        >
          Reconnect
        </button>
      </div>
    </div>
  );
}

export default function Dashboard() {
  const { data: summary, isLoading, error } = useSystemSummary();

  if (isLoading) return <DashboardLoading />;
  if (error || !summary) return <DashboardError />;

  const { system, docker, health } = summary.data;

  // Calculate GB for memory for cleaner display
  const memUsedGB = (system.memory.ram.used_mb / 1024).toFixed(1);
  const memTotalGB = (system.memory.ram.total_mb / 1024).toFixed(1);

  // Format uptime (converting seconds to readable string)
  const formatUptime = (seconds: number) => {
    const d = Math.floor(seconds / (3600 * 24));
    const h = Math.floor((seconds % (3600 * 24)) / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    return `${d}d ${h}h ${m}m`;
  };

  return (
    <div className="min-h-screen bg-background text-foreground p-4 sm:p-6 lg:p-8 font-sans selection:bg-indigo-500/30">
      <div className="max-w-7xl mx-auto space-y-8">
        
        {/* Header Section */}
        <header className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-12">
          <div>
            <h1 className="text-4xl md:text-5xl font-bold font-display tracking-tight bg-gradient-to-r from-white to-white/60 bg-clip-text text-transparent">
              Homebox
            </h1>
            <p className="text-muted-foreground mt-2 font-mono text-sm">
              SYSTEM_ID: HMBX-01 • <span className="text-emerald-400">ONLINE</span>
            </p>
          </div>
          <div className="flex items-center gap-3 bg-card/50 border border-white/5 rounded-full px-4 py-2 backdrop-blur-md">
            <div className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
            <span className="text-xs font-mono text-muted-foreground">
              Last update: {new Date(summary.timestamp).toLocaleTimeString()}
            </span>
          </div>
        </header>

        {/* Primary Metrics Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* CPU Stats */}
          <MetricCard 
            title="CPU Load" 
            icon={<Cpu className="w-5 h-5" />}
            className="border-indigo-500/20 hover:border-indigo-500/40"
          >
            <div className="flex flex-col items-center py-4">
              <RadialProgress 
                value={system.cpu.percent} 
                color="hsl(var(--chart-1))"
                label="Usage"
              />
              <div className="mt-6 flex items-center gap-2 text-sm font-mono text-muted-foreground">
                <Thermometer className="w-4 h-4" />
                <span>{system.cpu.temperature ? `${system.cpu.temperature}°C` : 'N/A'}</span>
              </div>
            </div>
          </MetricCard>

          {/* Memory Stats */}
          <MetricCard 
            title="Memory" 
            icon={<Server className="w-5 h-5" />}
            className="border-emerald-500/20 hover:border-emerald-500/40"
          >
            <div className="flex flex-col items-center py-4">
              <RadialProgress 
                value={system.memory.ram.percent} 
                color="hsl(var(--chart-2))"
                label="RAM"
              />
              <div className="mt-6 text-sm font-mono text-muted-foreground">
                {memUsedGB} GB / {memTotalGB} GB
              </div>
            </div>
          </MetricCard>

          {/* Disk Stats */}
          <MetricCard 
            title="Storage" 
            icon={<HardDrive className="w-5 h-5" />}
            className="border-amber-500/20 hover:border-amber-500/40"
          >
            <div className="flex flex-col items-center py-4">
              <RadialProgress 
                value={system.disk.percent} 
                color="hsl(var(--chart-3))"
                label="SSD"
              />
              <div className="mt-6 text-sm font-mono text-muted-foreground">
                {system.disk.used_gb} GB Used
              </div>
            </div>
          </MetricCard>

          {/* Uptime */}
          <MetricCard 
            title="System Uptime" 
            icon={<Clock className="w-5 h-5" />}
            className="flex flex-col justify-between"
          >
            <div className="flex flex-col items-center justify-center h-full min-h-[160px]">
              <div className="text-4xl font-bold font-display text-white mb-2">
                {formatUptime(system.uptime_seconds).split(' ')[0]}
              </div>
              <div className="text-sm font-mono text-muted-foreground uppercase tracking-widest mb-6">
                Days Online
              </div>
              <div className="w-full bg-secondary/50 rounded-full h-1.5 overflow-hidden">
                <motion.div 
                  initial={{ width: 0 }}
                  animate={{ width: "100%" }}
                  transition={{ duration: 2 }}
                  className="h-full bg-white/20" 
                />
              </div>
              <p className="mt-4 text-xs text-muted-foreground font-mono">
                {formatUptime(system.uptime_seconds)}
              </p>
            </div>
          </MetricCard>
        </div>

        {/* Secondary Section: Docker & Health */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          {/* Docker Status */}
          <MetricCard 
            title="Container Status" 
            icon={<Box className="w-5 h-5" />}
            className="lg:col-span-1"
          >
            <div className="space-y-6 mt-2">
              <div className="flex items-center justify-between p-4 rounded-xl bg-white/5 border border-white/5">
                <span className="text-sm font-medium">Running</span>
                <span className="text-xl font-bold font-mono text-emerald-400">{docker.running}</span>
              </div>
              <div className="flex items-center justify-between p-4 rounded-xl bg-white/5 border border-white/5">
                <span className="text-sm font-medium">Stopped</span>
                <span className="text-xl font-bold font-mono text-rose-400">{docker.stopped}</span>
              </div>
              <div className="pt-4 border-t border-white/5 flex justify-between items-center text-sm text-muted-foreground">
                <span>Total Containers</span>
                <span className="font-mono">{docker.total}</span>
              </div>
            </div>
          </MetricCard>

          {/* Service Health */}
          <MetricCard 
            title="Service Health" 
            icon={<Activity className="w-5 h-5" />}
            className="lg:col-span-2"
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-2">
              {Object.entries(health).map(([service, status], idx) => (
                <motion.div
                  key={service}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: idx * 0.1 }}
                  className="flex items-center justify-between p-4 rounded-xl bg-white/5 border border-white/5 hover:bg-white/10 transition-colors"
                >
                  <span className="font-medium capitalize">{service}</span>
                  <StatusBadge status={status as any} />
                </motion.div>
              ))}
            </div>
          </MetricCard>

        </div>
      </div>
    </div>
  );
}
