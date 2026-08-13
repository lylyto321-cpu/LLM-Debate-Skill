---
name: debate
description: Runs a structured, multi-round debate between Claude (host and proposer) and OpenAI Codex (reviewer, via the codex CLI) to work through a hard decision -- architecture choices, technical strategy, "should we do A or B" questions, or any problem where a single AI pass tends to produce shallow, symptom-level answers instead of addressing root causes. Progresses through four layers -- problem definition, ideal state, gap analysis, strategy -- with each layer requiring Codex's explicit sign-off before advancing, and a retrospective check before finalizing strategy so nothing agreed earlier gets quietly dropped. Use this whenever the user asks to "debate" or "war-game" something, wants a second opinion or independent challenge from another model, wants to "stress-test" a decision, mentions Codex reviewing or arguing against Claude's proposal, or is wrestling with a complex tradeoff and says things like "I don't want another shallow answer," "let's really think this through," or "poke holes in this."
---

# Debate

## Why this exists

Ask one model to fix six problems at once and it tends to hand back six independent patches -- treating each symptom where it appears rather than asking whether they share a root cause. The fix is structural, not "try harder": force a second, independent model to adversarially review every stage before you're allowed to move to the next one. A reviewer that didn't write the proposal notices missing definitions and premature conclusions that the author, mid-flow, glides past. This skill encodes that discipline as a repeatable procedure.

## Setup: confirm Codex is available

```bash
command -v codex
```

If this fails, tell the user the OpenAI Codex CLI needs to be installed and authenticated -- give them the concrete steps, don't just say "install it":

```bash
npm install -g @openai/codex   # NOT `npm i -g codex` -- that unscoped package is an unrelated 2012 project
codex login                    # opens a browser to sign in with ChatGPT, or use --with-api-key
codex --version                # verify
```

Then stop. Do not simulate the debate by arguing against yourself -- the entire value of this mechanism is an independent model's blind spots not overlapping with Claude's, and a self-debate quietly throws that away while looking like it worked.

`scripts/ask_codex.sh` pipes the prompt to `codex exec -` (reads the prompt from stdin, runs to completion, prints the reply to stdout) and already includes the install message above -- you don't need to duplicate it, just run the script and relay its stderr if it fails.

## The four layers

Work through these in order for whatever decision the user brought. Each layer is a gate, not a checkbox -- it ends only when Codex explicitly agrees it's sufficiently complete, not when Claude feels satisfied with it.

1. **Problem Definition** -- what is actually broken, or what is actually being decided? Push past the first framing the user gave you; a debate that starts from a slightly-wrong problem statement produces a well-argued answer to the wrong question.
2. **Ideal State** -- what would "good" look like, described structurally (relationships between the parts, lifecycles, ownership boundaries) rather than as a list of capabilities. A capability list ("it should support X, Y, Z") is a symptom of skipping this layer properly -- keep pushing until the shape of the thing is defined, not just its features.
3. **Gap Analysis** -- a dimensional comparison of the ideal state against the current one, not a flat list of complaints. If the analysis just re-lists the problems from layer 1, the ideal state wasn't structural enough; go back.
4. **Strategy** -- a phased plan. Classify each candidate move explicitly: safe to do immediately regardless of what comes later ("no-regret"), foundational work that has to happen before anything else can be real, or deferred/explicitly out of scope for now. Say what you're *not* doing as clearly as what you are.

## Running a turn

1. **Draft** -- as Proposer, write Claude's position for the current layer.
2. **Compose the reviewer prompt** -- include: a role framing telling Codex it's the Reviewer in an adversarial-but-constructive debate and should look for gaps, unstated assumptions, and premature conclusions rather than just agreeing; a short recap of what's been confirmed in prior layers; the current layer's goal; and the latest proposal. End with an explicit ask: either name what's missing and why it matters now, or state plainly that the layer is sufficiently converged to move on.
3. **Call Codex**:
   ```bash
   scripts/ask_codex.sh <<'EOF'
   <the composed prompt>
   EOF
   ```
4. **Log the turn** in the running transcript using the format in `references/turn_format.md`.
5. **Branch**: if Codex raises a structural gap, revise and repeat within this layer. If Codex signs off, or you hit the round cap (default 5 per layer -- raise it for a genuinely thorny topic, but a cap this size matches the roughly dozen-turn debates this mechanism is built around), advance to the next layer carrying forward a short recap of what got confirmed.

Use judgment on when a layer is actually done. If Codex's pushback starts repeating itself or fixates on something cosmetic rather than structural, it's fine to note the disagreement in the transcript and move on anyway -- the point is catching blind spots, not handing Codex a veto.

## Retrospective verification

Before locking in the Strategy layer, take every item being deferred or trimmed and check it against the commitments confirmed in layers 1-3. Ask explicitly: does dropping this quietly break something we already agreed mattered? Put this question to Codex directly rather than answering it yourself -- self-checking your own trims is exactly the blind spot this mechanism exists to avoid.

## Output

Produce two things:
- The full turn-by-turn transcript (useful for the user to see where the debate actually turned).
- A consensus document following `assets/consensus_template.md`, with one section per layer.

Ask the user where to save these (default to the current working directory, e.g. `<topic-slug>-debate.md` for the transcript and `<topic-slug>-consensus.md` for the final doc). Conduct the debate in whatever language the user is working in -- the mechanism doesn't depend on English.
