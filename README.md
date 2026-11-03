# Screw Escape

A casual Android puzzle game built with Flutter and Dart.

---

## Spec-Driven Development (SDD) Workflow

This repository strictly follows **Spec-Driven Development (SDD)**. No application feature, mechanics modification, or architecture change is implemented without an approved specification.

### Core Principles
1. **Spec-First**: Specifications are the primary source of truth.
2. **Requirements Traceability**: Every requirement has a unique ID traced across plan, tasks, tests, and code.
3. **Test-Driven Verification**: Core puzzle mechanics are written in pure Dart and verified with automated tests before UI integration.
4. **Small, Incremental Changes**: Atomic, verifiable steps keep the codebase green and stable.
5. **Minimal Dependencies**: Dart/Flutter first; external packages require explicit justification.
6. **Clean Flutter Architecture**: Strict separation of Domain (pure Dart), Application/State, Presentation (Widgets), and Data layers.
7. **Explicit Approval**: Implementation only begins after the spec, plan, and tasks are formally approved.

For details, read the [Engineering Constitution](.specify/memory/constitution.md).

### The SDD Lifecycle

```text
[ 1. Spec ] ──(Approval)──> [ 2. Plan ] ──(Approval)──> [ 3. Tasks ] ──(Approval)──> [ 4. Implement & Verify ]
```

1. **Specification (`specs/NNN-<feature>/spec.md`)**: Define user stories, requirements (`REQ-NNN-XX`), and acceptance criteria.
2. **Technical Plan (`specs/NNN-<feature>/plan.md`)**: Map requirements to Clean Architecture components and define testing strategy.
3. **Task Breakdown (`specs/NNN-<feature>/tasks.md`)**: Define granular, test-backed steps.
4. **Implementation**: Execute tasks sequentially, following TDD for domain logic.

### Branching & PR Strategy

All work must follow standard branch naming prefixes and raise a Pull Request targeting `main`:
* `feat/<feature-name>`: For new features and puzzle mechanics.
* `fix/<bug-name>`: For bug fixes and error resolutions.
* `chore/<task-name>`: For tooling, templates, dependencies, and configuration.

Every branch merges into `main` only via an approved Pull Request.

See [specs/README.md](specs/README.md) and [specs/templates/](specs/templates/) to begin a new feature.

---

## Getting Started

### Prerequisites
* Flutter SDK (`^3.13.7` or later compatible with Dart `^3.13.7`)
* Android SDK / Android Studio for mobile deployment

### Run Tests
```bash
flutter test
```

### Run Application
```bash
flutter run -d android
```
