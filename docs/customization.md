# Customization

Public core runs without overlays. Overlay discovery order:

1. CLI flag `--overlay <path>`.
2. `FRANK_WORKFLOW_OVERLAY_DIR`.
3. `.frank-workflow/config.toml`.
4. `$HOME/.frank-workflow/config.toml`.
5. No overlay.

v0.1 and v0.2 use manual overlay: copy templates and edit project sections. v0.3 will add deterministic append-only rendering.

v0.2 adds policy keys and migration guidance only; it does not implement the v0.3 renderer. Existing generated files remain local and are preserved unless bootstrap is run with `--force`.

The example `[workflow]` and `[capacity]` keys are illustrative overlay policy. The public v0.2 bootstrap does not enforce them; an external adapter or future renderer may consume them.
