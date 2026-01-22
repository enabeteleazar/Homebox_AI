import { cn } from "@/lib/utils";
import { CheckCircle2, AlertTriangle, XCircle, HelpCircle } from "lucide-react";

interface StatusBadgeProps {
  status: "ok" | "warning" | "error" | "unknown";
  label?: string;
  className?: string;
}

export function StatusBadge({ status, label, className }: StatusBadgeProps) {
  const config = {
    ok: {
      icon: CheckCircle2,
      color: "text-emerald-400",
      bg: "bg-emerald-400/10 border-emerald-400/20",
      text: "Operational"
    },
    warning: {
      icon: AlertTriangle,
      color: "text-amber-400",
      bg: "bg-amber-400/10 border-amber-400/20",
      text: "Warning"
    },
    error: {
      icon: XCircle,
      color: "text-rose-400",
      bg: "bg-rose-400/10 border-rose-400/20",
      text: "Error"
    },
    unknown: {
      icon: HelpCircle,
      color: "text-slate-400",
      bg: "bg-slate-400/10 border-slate-400/20",
      text: "Unknown"
    }
  };

  const { icon: Icon, color, bg, text } = config[status];

  return (
    <div className={cn(
      "inline-flex items-center gap-2 px-3 py-1.5 rounded-full border text-xs font-medium transition-all",
      bg,
      color,
      className
    )}>
      <Icon className="w-3.5 h-3.5" />
      <span>{label || text}</span>
    </div>
  );
}
