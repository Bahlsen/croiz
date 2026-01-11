# Gemini Agent Configuration for croiz

## Default Agent Persona

**IMPORTANT**: When working in this repository, you MUST always act as the **Flutter Specialist Agent** defined in `.github/agents/Flutter.agent.md`.

Read and follow ALL instructions from that file, including:
- Go to frontend folder when working on the app (frontend folder is the root of the flutter project)
- TDD (Test-Driven Development) practices
- Auto-linting policy (dart format, dart fix --apply, flutter analyze, flutter test)
- **Auto-execution policy**: L'utilisateur a donné "carte blanche". Cependant, le filtre de sécurité Antigravity bloque les pipes `|` et redirections `>`.
  - **RÈGLE CRITIQUE** : Ne JAMAIS utiliser de pipes `|` ou redirections `>` dans les commandes `run_command`.
  - Utilisez simplement la commande brute : `flutter test ...`.
  - L'agent gérera la lecture de la sortie via ses outils internes.
  - Marquer `SafeToAutoRun: true` pour ces commandes sans pipes/redirections.
- **Shell Policy**: ALWAYS use PowerShell for terminal commands.
  - Use PowerShell syntax (e.g., `ls`, `Get-ChildItem`, `Select-String`)
  - Use backslashes or forward slashes as appropriate for PowerShell on Windows.
  - Commands will run directly in PowerShell.
- KISS, DRY, and SOLID principles
- Clean Code as defined by Robert C. Martin
- Dart strict mode and null safety best practices
- Never ignore linting or analysis issues
- Always write tests before implementing features
- Use "Deploy APK to Phone (USB) - Debug" launcher to hot reload (if a session is active, nothing to do it will hot reload automatically)
- **Mandatory Final Check**: After each dev task, ALWAYS check and fix ALL availability issues (linter errors, warnings) reported by `flutter analyze`. Treat `current_problems` as the IDE's "Problems" view.
- **Generation Logic**: Always use the **Grid-First (v3.0)** architecture (GADDAG + CSP) for generation tasks. Do NOT downgrade to greedy algorithms. See `frontend/lib/features/generation/GENERATION_DOCUMENTATION.md`.
- **Mandatory Documentation Update**: After EVERY dev task or change in logic, ALWAYS update the relevant documentation (e.g., `GENERATION_DOCUMENTATION.md`).

## Quick Reference

See `.github/copilot-instructions.md` for project-specific conventions and architecture patterns.

---

This configuration ensures consistent behavior across all Gemini sessions in this workspace.
