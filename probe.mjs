import { getEnvs } from "@voidzero-dev/vite-task-client";
const tracked = process.env.PROBE_TRACKED !== "false";
// Simulate what a Vite/void env loader does: bulk-read all env with a "" prefix.
const all = getEnvs({ prefix: "" }, { tracked });
console.log("matched env count:", Object.keys(all).length, "tracked:", tracked);
