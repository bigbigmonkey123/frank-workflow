# Codex Review: Discovery, Scope, and Model Selection

A request for a Codex review identifies the reviewer and task. It does not require every input to use the native `codex review` subcommand. Keep skill discovery, material selection, and model selection separate.

## Resolve the skill name first

If instructions invoke `Skill(codex)` but the installed personal skill is named `codex-review`, `Unknown skill: codex` is a discovery failure. Check the actual skill inventory and applicable project instructions before investigating CLI installation or authentication.

Use one canonical skill name consistently. If a legacy alias is needed, keep it a small, non-recursive entry point to the canonical instructions and test discovery in a fresh Claude session. Do not duplicate the entire policy in two skills. A manual file-read fallback must be labelled as such; it does not prove that Skill invocation succeeded.

Personal skills remain outside this repository, as required by [Runtime Environment](runtime-environment.md). This document neither installs a skill nor changes a running session.

## Route by the material being reviewed

| Material | Review approach |
|---|---|
| Working-tree changes, one commit, or a base comparison | Use the installed CLI's supported native review target and record the precise scope. |
| Markdown changes inside a Git repository | Treat them as reviewable changes; a document extension is not a reason to reject review. |
| Staged-only or explicitly selected material | Supply the exact selected patch and necessary matching context to an exec-based review; do not substitute a broader working-tree diff. |
| A standalone plan, design, or QA evidence packet | Use an explicit, sanitized snapshot and read-only `codex exec`; include `--skip-git-repo-check` when appropriate. Record file hashes instead of inventing a Git HEAD. |

Check `codex review --help` and `codex exec --help` in the installed version. Native review supports custom instructions, but that alone does not establish equivalent behavior for every non-Git input. Respect an explicitly requested command; explain any verified incompatibility before changing the approach.

Bind every result to the reviewed input. A subsequent change invalidates approval for the changed scope. Do not call a review complete when coverage or execution evidence is missing.

## Enforce an explicit model policy

When a user requires a model and reasoning effort, pass both explicitly for every invocation. This applies equally to code review and exec-based reviews of plans or evidence. A local default, native `review_model`, profile, historical artifact, or CLI help example must not override the requirement.

For a policy explicitly requiring **gpt-6-astra / high**, the invocations are:

```sh
# Selected native working-tree scope; inspect its contents before dispatch.
codex review --uncommitted \
  -c 'model="gpt-6-astra"' \
  -c 'review_model="gpt-6-astra"' \
  -c 'model_reasoning_effort="high"' \
  -c 'sandbox_mode="read-only"'

# review-input.txt and review-snapshot must be prepared and inspected first.
codex exec -m gpt-6-astra \
  -c 'model_reasoning_effort="high"' \
  -C review-snapshot --skip-git-repo-check -s read-only - < review-input.txt
```

Validate flags and configuration keys against the installed version. These examples illustrate that explicit user policy; they do not impose a model on all Frank Workflow users or establish account availability. Only a newer explicit user instruction changes an existing required pair.

If the required model or effort is unavailable, preserve the error and report FAILED/INCOMPLETE. Do not silently switch models, lower effort, change authentication/providers, or approve based on another reviewer's output. A timeout, transport error, or quota error does not by itself mean a model does not exist. Follow the applicable retry budget and preserve separate attempts.

Record the input fingerprint, exact invocation, CLI version, requested settings, runtime-confirmed settings, timestamps, exit status, and final response in private artifacts. A model naming itself in prose is not runtime evidence. Report absent metadata as unconfirmed. Runtime metadata from a configured endpoint does not independently verify the upstream model behind a proxy.

A retry must use the original frozen material. If the original failed request is unavailable, identify any new validation scope and do not claim the old review was successfully retried. Keep credentials and raw private logs out of public issues and commits.

## Regression acceptance and current limits

Behavioral acceptance should cover canonical and legacy skill discovery, code changes, Git document changes, standalone plans, QA packets, staged-only isolation, explicit model/effort preservation, and honest failure handling. A frontmatter check alone is not end-to-end validation.

The reported model-policy patch was validated in a local environment through a real Codex exec response with exit zero and runtime metadata showing the required pair; its personal skill passed format validation. The original failed request was not recovered. The name compatibility fix, broader material routing, and old-session reload behavior remain unverified and must not be marked complete by this documentation commit.

Track the discovery, routing, and model-policy problems separately in [issue #3](https://github.com/bigbigmonkey123/frank-workflow/issues/3). The public documentation does not install the locally validated policy or repair other users' environments automatically.
