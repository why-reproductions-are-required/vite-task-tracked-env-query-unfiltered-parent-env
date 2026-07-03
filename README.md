# vite-task: a tracked bulk env query is validated against the unfiltered parent env

Minimal reproduction: a `tracked` env query is validated against the **full
unfiltered parent process environment**. A broad query (empty prefix, matching
every variable) therefore cache-misses whenever *any* ambient variable changes,
even one the build never reads. In CI, per-run variables (e.g.
`ACTIONS_ORCHESTRATION_ID`) change every run, so such a build never cache-hits.

## Run

```bash
pnpm install
./repro.sh
```

## Expected vs actual

Both tasks call `getEnvs({ prefix: "" }, { tracked })` via
`@voidzero-dev/vite-task-client` and read no variable in particular. Run 3 sets
one unrelated ambient variable before running.

| task                 | `tracked` | run 3 (one unrelated ambient var set) |
| -------------------- | --------- | ------------------------------------- |
| `untracked-bulk-env` | `false`   | **HIT** (control)                     |
| `tracked-bulk-env`   | `true`    | **MISS** `TrackedEnvQueryChanged { Prefix "", Added ... }` |

## Where this bites a real build

`vp build` loads env via Vite's loader, which issues
`getEnvs({ prefix }, { tracked: true })` for each configured `envPrefix`
(`@voidzero-dev/vite-plus-core`, `chunks/node.js`). In a Vite + void app one of
those queries is empty-prefix (`Prefix ""`, all variables), so on GitHub Actions
`vp run build` misses every run:

```
$ vp build ○ cache miss: env 'ACTIONS_ORCHESTRATION_ID' changed, executing
```

The only workaround found is to run the build under a sanitized environment,
e.g. `env -i PATH="$PATH" HOME="$HOME" vp run build`.

## Question for maintainers

Is validating a `tracked` query against the *unfiltered* parent env intended?
A broad tracked query is unavoidably CI-hostile this way. Options might include
validating against the filtered env the task received, an ignore-list for
ambient/volatile variables, or scoping or untracking broad reads on the consumer
side (Vite env loader / void). Filing here to confirm where the fix belongs.

## Environment

- `vite-plus` 0.2.2, `@voidzero-dev/vite-task-client` 0.2.0
- Reproduced on macOS (darwin 25.x) and GitHub Actions `ubuntu-latest`
