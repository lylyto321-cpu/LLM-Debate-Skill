# Turn format

Log every turn in the transcript using this shape. It's adapted from a real Claude-vs-Codex debate transcript, and keeps each turn scannable: a reader should be able to tell what changed without rereading the whole thing.

```
### Turn <N> -- <Claude|Codex>
Type: <short label, e.g. "Comparative opinion -- Layer 2 completion" or "Convergence judgment -- advance to Layer 3">

**Position:**
1. <point>
2. <point>
3. <point>

**Comparison table (when the turn identifies missing definitions or dimensions):**
| # | Missing definition | Why it matters now |
|---|---|---|
| 1 | ... | ... |

**Suggestion:**
<concrete proposal for what to do about it -- not just "this is incomplete" but what would complete it>

**Rationale:**
- <why, citing what's already been confirmed and what's still missing>
```

## Worked example

Real turn from the source debate (translated), showing a Reviewer turn that pulled the discussion back from implementation detail to a missing structural definition:

```
### Turn 2 -- Codex
Type: Comparative opinion -- Layer 2 ideal-state completion

**Position:**
1. Agree with the direction so far, but the priority right now isn't "how,"
   it's pinning down what the conversational workspace actually IS on the
   product level.
2. The five product attributes from Turn 1 point the right way, but Layer 2
   isn't closed yet -- jumping to Layer 3 (gap analysis) now is premature.
3. What's missing isn't more features, it's a few more basic definitions --
   without them, later discussion drifts without anyone noticing.

**Comparison table:**
| # | Missing definition | Why it matters now |
|---|---|---|
| 1 | Relationship between the workspace and the main system | Unclear whether the two stay in sync or drift into a second, siloed system |
| 2 | Lifecycle semantics of a "session" | Currently just "a unit of work" -- no states defined, so "resume," "start new," "review history" are still just words |
| 3 | Object model of "work material" | Files, project state, history, agent output are all called "input material" with no distinction between one-shot inputs and long-lived project assets |

**Suggestion:**
Compress the ideal-state layer into four concrete questions: what information
structure does a user see on opening the workspace; what states does a
session move through; how do work material, conversation, and system output
relate; and how does a user resume/reuse a finished session without it
drifting from the main system's state.

**Rationale:**
- Turn 1 already extracted five attributes from the user journey, so the
  direction is right.
- But those five are still capability descriptions, not a precise object
  model -- without one, the gap analysis in Layer 3 will degenerate into "list
  the missing UI controls" instead of a real structural comparison.
```

Notice what the Reviewer turn does: it doesn't just say "this is incomplete," it names the specific missing definitions, explains the downstream cost of skipping them, and proposes exactly what would close the gap. That specificity is what separates a useful review from a rubber stamp or a vague "looks good but could be more thorough."
