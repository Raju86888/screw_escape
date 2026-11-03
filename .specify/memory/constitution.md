# Engineering Constitution — Screw Escape

This constitution establishes the non-negotiable engineering principles and operational workflow for the "Screw Escape" repository. Every contributor and AI agent must adhere strictly to these rules.

---

## Core Engineering Principles

### 1. Spec-First Development
* No implementation code or architecture changes may be introduced without an approved specification document.
* Every feature, mechanics redesign, or non-trivial bug fix must begin with a formal specification (`specs/NNN-<feature>/spec.md`).
* Code is an expression of the specification; the specification remains the authoritative source of truth.

### 2. Requirements Traceability
* Every requirement must have a globally unique identifier (e.g., `REQ-001`, `REQ-002`).
* Each item in `plan.md` and every task in `tasks.md` must explicitly cite the requirement IDs it fulfills.
* Unit and widget tests must reference the corresponding requirement ID in their descriptions or annotations.
* No orphan tasks or unmapped code blocks are permitted.

### 3. Test-Driven Verification
* Domain logic (puzzle rules, board state, move validation, win/loss resolution) must be implemented with Test-Driven Development (TDD).
* Write failing tests before writing production code.
* Presentation widgets must be accompanied by widget tests covering core interaction states.
* A task cannot be marked completed until its corresponding test suite passes cleanly.

### 4. Small, Incremental Changes
* Decompose work into bite-sized, atomic, and verifiable tasks.
* Each commit or pull request must represent a single logical increment that keeps the build green and tests passing.
* Avoid massive batch updates or simultaneous refactors across multiple subsystems.

### 5. Branching & PR Strategy
* Strictly adhere to standardized branch prefixes:
  * `feat/<feature-name>` for new features and gameplay capabilities.
  * `fix/<bug-name>` for bug fixes and defect remediation.
  * `chore/<task-name>` for setup, tooling, documentation, and maintenance.
* Every branch must open a Pull Request (PR) targeting `main` and be merged into `main` upon approval and green checks. No direct pushes to `main`.

### 6. Minimal Dependencies
* Favor standard Dart and Flutter SDK capabilities before adding external packages.
* Any new dependency must be vetted for footprint, maintenance activity, Android performance impact, and license compatibility.
* Zero third-party dependencies are allowed without explicit evaluation recorded in `plan.md`.

### 7. Clean Flutter Architecture
* Strict separation of concerns:
  * **Domain Layer (Pure Dart)**: Puzzle algorithms, board models, move rules, score calculation. Zero Flutter/UI imports. Fully testable in headless Dart.
  * **Application / State Layer**: State management (e.g., ValueNotifiers, ChangeNotifier, BLoC/Cubit), coordinating player inputs with domain mechanics.
  * **Presentation Layer (Flutter Widgets)**: Canvas painting, animations, haptic triggers, sound cues, touch interaction widgets. Purely reactive, containing no business logic.
  * **Data / Infrastructure Layer**: Local storage (preferences, save states, level unlocks) abstracted behind interfaces.

### 8. Explicit Approval Before Implementation
* The development lifecycle follows distinct gated phases:
  1. **Specification** (`spec.md`) -> Review -> Approval
  2. **Technical Plan** (`plan.md`) -> Review -> Approval
  3. **Task Breakdown** (`tasks.md`) -> Review -> Approval
  4. **Implementation & Verification** -> Review -> Completion
* Writing production code is strictly prohibited until the specification, plan, and task list have received explicit user approval.

---

## Governance & Compliance

* Violations of these principles must be reported immediately and resolved before proceeding with further work.
* Amendments to this constitution require explicit consent from project leadership.

