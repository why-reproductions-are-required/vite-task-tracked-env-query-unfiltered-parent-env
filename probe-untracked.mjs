import { getEnvs } from "@voidzero-dev/vite-task-client";
const all = getEnvs({ prefix: "" }, { tracked: false });
console.log("untracked bulk read, matched:", Object.keys(all).length);
