import { getEnvs } from "@voidzero-dev/vite-task-client";
const all = getEnvs({ prefix: "" }, { tracked: true });
console.log("tracked bulk read, matched:", Object.keys(all).length);
