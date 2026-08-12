# debate

A [Claude Code skill](https://docs.claude.com/en/docs/claude-code/skills) that forces a hard decision through an adversarial review loop instead of a single AI pass, by having **Claude propose** and **OpenAI Codex review** across four gated layers: Problem Definition → Ideal State → Gap Analysis → Strategy.

The idea: ask one model to fix six problems at once and it tends to hand back six independent patches -- treating each symptom where it appears, never asking whether they share a root cause. An independent second model, reviewing each layer before you're allowed to advance, catches the missing definitions and premature conclusions that the author glides past mid-flow.

General-purpose: architecture choices, technical strategy, "should we do A or B" -- any decision where a shallow, symptom-level answer isn't good enough. For product/PRD work specifically, see the companion skill, [`prd-debate`](https://github.com/<your-username>/prd-debate-skill).

## What it does

- Progresses through four layers, advancing only when Codex explicitly signs off (default cap: 5 review rounds per layer, overridable by judgment)
- Runs a retrospective check before locking in the final strategy, mapping every deferred/trimmed item back against earlier commitments so nothing gets quietly dropped
- Logs a full turn-by-turn transcript alongside the final consensus document
- Refuses to fake the debate solo if the Codex CLI isn't available -- an independent model's blind spots not overlapping with Claude's is the entire point

## Prerequisites

The [OpenAI Codex CLI](https://developers.openai.com/codex) must be installed and authenticated:

```bash
npm install -g @openai/codex   # NOT `npm i -g codex` -- that unscoped package is an unrelated 2012 project
codex auth                     # or sign in with a ChatGPT Plus/Pro/Team/Edu/Enterprise account
codex --version                # verify
```

The skill checks for `codex` on `PATH` before starting and prints these exact steps if it's missing, so this isn't a hard blocker to installing the skill itself -- just to actually running a debate.

## Installing

```bash
git clone https://github.com/<your-username>/debate-skill.git
cp -r debate-skill ~/.claude/skills/debate
```

Claude Code picks up skills from `~/.claude/skills/<name>/SKILL.md` automatically -- no restart needed for a fresh session. To install for one project only, copy into `<project>/.claude/skills/debate` instead. The destination directory name (`debate`) is what Claude Code uses to key the skill, so keep it as `debate` even though the GitHub repo is named `debate-skill`.

## Using it

Just ask, in whatever words fit the moment -- this triggers on intent, not on exact phrasing:

- *"Let's debate this architecture decision -- I don't want another shallow answer."*
- *"Have Codex challenge this before we commit to it."*
- *"Stress-test this migration plan with another model before we run it."*

Each debate produces two files (path/naming is asked at the end, defaulting to the current directory):
- `<slug>-debate.md` -- the full turn-by-turn transcript, including where Codex pushed back and why
- `<slug>-consensus.md` -- the final layered document

## How a layer actually converges

A layer ends when Codex explicitly signs off, not when Claude feels done. A real turn from this mechanism's origin, where Codex pulled a proposal back from implementation detail to a missing structural definition:

> Agree with the direction so far, but the priority right now isn't "how," it's pinning down what the workspace actually *is* on the product level... What's missing isn't more features, it's a few more basic definitions -- without them, later discussion drifts without anyone noticing.

See [`references/turn_format.md`](references/turn_format.md) for the full worked example and the transcript format this skill uses.

## Design notes

- **Why a script instead of inline `codex` calls**: `scripts/ask_codex.sh` pipes the composed review prompt to `codex exec -` (reads from stdin, avoids shell-quoting issues with long multi-line prompts) and centralizes the "Codex isn't installed" error message so it's consistent and actionable.
- **Why Codex can't be faked**: `SKILL.md` explicitly instructs against having Claude argue both sides if Codex is unavailable. A solo debate looks like it worked but silently throws away the one thing this mechanism buys you.
- **Why round caps exist**: unbounded review loops are a real failure mode. The default cap is a judgment call, not a hard rule -- the skill explicitly tells Claude to use judgment and move on if Codex's pushback turns repetitive or cosmetic rather than structural.

## Credit

The debate mechanism itself is adapted from a product manager's write-up on using adversarial multi-model review to avoid "quality degradation in single-session analysis of complex problems." This skill is an independent implementation of that idea for Claude Code, not an official Anthropic or OpenAI product.

## License

MIT -- see [LICENSE](LICENSE).
