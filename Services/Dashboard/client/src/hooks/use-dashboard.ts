import { useQuery } from "@tanstack/react-query";
import { api } from "@shared/routes";

export function useSystemSummary() {
  return useQuery({
    queryKey: [api.summary.get.path],
    queryFn: async () => {
      const res = await fetch(api.summary.get.path);
      if (!res.ok) throw new Error("Failed to fetch system summary");
      return api.summary.get.responses[200].parse(await res.json());
    },
    refetchInterval: 5000, // Refresh every 5 seconds
  });
}

export function useSystemStats() {
  return useQuery({
    queryKey: [api.system.get.path],
    queryFn: async () => {
      const res = await fetch(api.system.get.path);
      if (!res.ok) throw new Error("Failed to fetch system stats");
      return api.system.get.responses[200].parse(await res.json());
    },
    refetchInterval: 5000,
  });
}

export function useDockerSummary() {
  return useQuery({
    queryKey: [api.docker.summary.path],
    queryFn: async () => {
      const res = await fetch(api.docker.summary.path);
      if (!res.ok) throw new Error("Failed to fetch docker summary");
      return api.docker.summary.responses[200].parse(await res.json());
    },
    refetchInterval: 10000,
  });
}

export function useHealthStats() {
  return useQuery({
    queryKey: [api.health.get.path],
    queryFn: async () => {
      const res = await fetch(api.health.get.path);
      if (!res.ok) throw new Error("Failed to fetch health stats");
      return api.health.get.responses[200].parse(await res.json());
    },
    refetchInterval: 10000,
  });
}
