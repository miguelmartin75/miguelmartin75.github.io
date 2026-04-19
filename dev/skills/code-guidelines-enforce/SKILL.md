---
name: code-guidelines-enforce
description: Audit repository code against layout and style rules documented in AGENTS.md, CODE_GUIDELINES.md, CODE_STYLE.md, or README.md; apply clear behavior-preserving refactors by default, or broader repo-local cleanups when the user explicitly asks for them.
---

# Code Guidelines Enforce

Use this skill when asked to enforce the repo's code guidelines, clean up style violations, or apply small behavior-preserving refactors that align code with the repository's documented standards.

## Source Of Truth

- Read `AGENTS.md` first and treat it as authoritative for workflow constraints and validation commands.
- Determine the intended code layout from `AGENTS.md`. If `AGENTS.md` does not define it clearly, read `README.md` and use the documented source directories, modules, packages, or apps as the audit scope.
- Read `CODE_GUIDELINES.md` if it exists.
- If `CODE_GUIDELINES.md` does not exist, read `CODE_STYLE.md` if it exists.
- If neither file exists, use the relevant code-guidelines section in `AGENTS.md`.
- Check `git status --short` before editing so you do not disturb unrelated user changes.

## Workflow

1. Identify potential problematic sections.
   - Read `AGENTS.md`.
   - Read `README.md` only if you need it to identify the intended code layout or active code directories.
   - Read `CODE_GUIDELINES.md` if present. If it is absent, read `CODE_STYLE.md` if present. Otherwise, extract the applicable rules from `AGENTS.md`.
   - Derive the candidate file set from the documented code layout instead of assuming a fixed language, extension, or directory.
   - Use `rg --files` and targeted `rg -n` searches to find likely violations based on the actual documented rules, then open each match in context before deciding it is a real problem.
2. For each problematic section, break the work into batches and hand those batches off to sub-agents.
   - Split the work so each sub-agent owns a clear, non-overlapping batch, usually by file group, module, or rule family.
   - Provide explicit instructions that tell the sub-agent to analyze the code and produce its own behavior-preserving refactor rather than mechanically applying a guessed rewrite.
   - Give enough context for the sub-agent to work independently:
     - what the repository does,
     - what the specific code area is responsible for,
     - why the section was identified as complex or problematic,
     - which documented rules and exceptions apply,
     - whether the user requested only narrow fixes or a broader cleanup,
     - which files are safe to edit and which dirty or unrelated files must be avoided,
     - which validation commands from `AGENTS.md` should be run.
   - If the user explicitly asks for a broader cleanup, allow safe repo-local refactors such as ordering fixes, naming cleanups, or API-shape adjustments when the rule is explicit and validation can confirm the refactor.
   - Still avoid risky semantic changes, vendored code, generated assets, and unrelated dirty files.
3. Wait for all sub-agents and review their work.
   - Inspect each batch for correctness, scope control, and conflicts with other batches.
   - Re-read the relevant rule and its exceptions.
   - Check whether each edit fixed a real violation or merely rewrote code that was already allowed.
   - Revert or adjust any edit that over-applies the guideline, ignores an exception, or changes behavior.
   - Run the relevant validation command or commands from `AGENTS.md` for the touched surface.
4. Go back to step 1 and search again for additional clear guideline violations. Repeat until no remaining violations are present in the codebase or until the remaining cases are ambiguous enough that they should be reported instead of changed.
5. Produce the expected output.

## Search Strategy

- Build search patterns from the actual rule set you found. Do not reuse language-specific seeds unless the repo's guidelines call for them.
- Start with file discovery in the documented code directories, then search for concrete rule-driven patterns such as:
  - discouraged naming forms,
  - banned or deprecated APIs,
  - forbidden control-flow patterns,
  - import or declaration ordering issues,
  - guideline-specific comment, dependency, or formatting violations.
- Treat searches as starting points, not automatic edits. A match is only a candidate until you confirm the local context.

## Over-Application Checks

- Do not apply style rules mechanically from a grep match alone. Always confirm that the matched code violates the rule after considering exceptions and local context.
- If a rule has an explicit exception, the exception wins.
- Favor the narrower interpretation when a refactor is stylistic but not clearly required.
- Before keeping an edit, ask: "Does this code actually violate the documented guideline, or did I just restyle an allowed pattern?"
- If the answer is unclear, skip the change and add it to the ambiguous or skipped list for the final output.
- If the user explicitly requests a wider cleanup, use the wider interpretation only for repo-local renames, ordering fixes, or structural moves that remain mechanically verifiable.

## Refactor Priorities

Use these priorities to order the audit. For exact rules and exceptions, defer to `CODE_GUIDELINES.md`, `CODE_STYLE.md`, or `AGENTS.md`.

1. Behavior-preserving structural issues:
   - Prioritize low-risk cleanup around control flow, needless complexity, or other clearly documented patterns that can be fixed safely.
2. Simplicity:
   - Prefer simpler direct code and lighter abstractions when the current form adds little value and the guideline clearly prefers the simpler form.
3. Ordering and structure:
   - Enforce file, module, import, declaration, or member ordering only when the repo documents the required order.
4. Naming and API shape:
   - Clean up naming, exports, public surface, or similar API-shape issues only when intent is clear and repo-local updates are safe.
5. Data shape and abstraction boundaries:
   - Prefer narrower, clearer data and abstraction changes only when the guideline explicitly supports them and the refactor stays behavior-preserving.
6. Dependencies, comments, and formatting:
   - Avoid style-only dependency churn, keep comments brief, and make formatting edits only when they are part of a clear guideline fix.

## Constraints

- Keep changes small and direct.
- Do not mass-reformat files unless the user explicitly asks for that scope.
- Do not touch vendored code, generated assets, or unrelated dirty files.
- Default to the documented code directories. Only update call sites outside that scope when a safe repo-local rename or API cleanup requires it.
- If a style fix is semantically risky or ambiguous, skip it and report it instead of forcing it.
- Follow the validation instructions in `AGENTS.md`. If multiple commands are available, prefer the narrowest command that still validates the touched surface while iterating.

## Verification

- Before running validation, do one final over-application pass across the diff and revert any change that no longer looks like a clear guideline violation after considering exceptions and edge cases.
- Run the validation command or commands documented in `AGENTS.md`.
- If a narrower validation command is sufficient while iterating, use it before running broader validation.
- If validation cannot run, say so explicitly in the final report.

## Expected Output

- List the files changed.
- Summarize which documented rules were enforced and where those rules came from, such as `CODE_GUIDELINES.md`, `CODE_STYLE.md`, or a section of `AGENTS.md`.
- Call out ambiguous cases that were skipped, with a brief reason for each.
- State which validation commands were run, or why validation could not be run.
