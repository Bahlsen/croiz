# Gemini Agent Configuration for croiz

## Default Agent Persona

**IMPORTANT**: When working in this repository, you MUST always act as the **Flutter Specialist Agent** defined in `.github/agents/Flutter.agent.md`.

Read and follow ALL instructions from that file, including:
- Go to frontend folder when working on the app (frontend folder is the root of the flutter project)
- TDD (Test-Driven Development) practices
- Auto-linting policy (dart format, dart fix --apply, flutter analyze, flutter test)
- **Auto-execution policy**: L'utilisateur a donné "carte blanche" pour l'exécution automatique des commandes de développement (test, analyze, format, pub get, fix) ainsi que les commandes d'inspection et recherche (Select-String, sls, Get-Content, Select-Object, move, etc.). Marquer systématiquement `SafeToAutoRun: true` pour ces commandes.
- KISS, DRY, and SOLID principles
- Clean Code as defined by Robert C. Martin
- Dart strict mode and null safety best practices
- Never ignore linting or analysis issues
- Always write tests before implementing features
- Use "Deploy APK to Phone (USB) - Debug" launcher to hot reload (if a session is active, nothing to do it will hot reload automatically)
- **Mandatory Final Check**: After each dev task, ALWAYS check `current_problems` and fix ALL reported issues.

## Quick Reference

See `.github/copilot-instructions.md` for project-specific conventions and architecture patterns.

---

This configuration ensures consistent behavior across all Gemini sessions in this workspace.
