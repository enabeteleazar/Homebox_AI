import { ReactNode } from "react";
import { cn } from "@/lib/utils";
import { motion } from "framer-motion";

interface MetricCardProps {
  title: string;
  children: ReactNode;
  className?: string;
  icon?: ReactNode;
  trend?: "up" | "down" | "neutral";
}

export function MetricCard({ title, children, className, icon, trend }: MetricCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className={cn(
        "glass-card rounded-2xl p-6 relative overflow-hidden group hover:border-white/10 transition-colors duration-300",
        className
      )}
    >
      <div className="absolute top-0 right-0 p-32 bg-primary/5 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 pointer-events-none group-hover:bg-primary/10 transition-colors duration-500" />
      
      <div className="flex items-center justify-between mb-4 relative z-10">
        <h3 className="text-sm font-medium text-muted-foreground uppercase tracking-wider">{title}</h3>
        {icon && <div className="text-primary/80">{icon}</div>}
      </div>
      
      <div className="relative z-10">
        {children}
      </div>
    </motion.div>
  );
}
