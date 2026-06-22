# Customization

Public core runs without overlays. Overlay discovery order:

1. CLI flag `--overlay <path>`.
2. `FRANK_WORKFLOW_OVERLAY_DIR`.
3. `.frank-workflow/config.toml`.
4. `$HOME/.frank-workflow/config.toml`.
5. No overlay.

v0.1 uses manual overlay: copy templates and edit project sections. v0.3 will add deterministic append-only rendering.
