import { defineConfig } from "vite-plus";
export default defineConfig({
  run: { tasks: {
    "tracked-bulk-env":   { command: "node probe-tracked.mjs",   env: [] },
    "untracked-bulk-env": { command: "node probe-untracked.mjs", env: [] },
  } },
});
