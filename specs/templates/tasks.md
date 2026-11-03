# Implementation Tasks: [Feature Name]

* **Feature ID**: `SPEC-[NNN]`
* **Spec Reference**: `specs/[NNN]-[feature-name]/spec.md`
* **Plan Reference**: `specs/[NNN]-[feature-name]/plan.md`
* **Status**: `[Pending Approval | In Progress | Completed]`

> **Rule**: No task may begin until the specification and plan have received explicit approval. Every task must be verified with tests before marking complete.

---

## Phase 1: Domain & Core Logic (Pure Dart)

- [ ] **TASK-[NNN]-01**: Define domain entities and board state models
  - **Traces**: `REQ-[NNN]-01`
  - **Verification**: `test/unit/[feature]_models_test.dart`
- [ ] **TASK-[NNN]-02**: Implement puzzle rule engine and move validation (TDD)
  - **Traces**: `REQ-[NNN]-01`, `REQ-[NNN]-02`
  - **Verification**: `test/unit/[feature]_engine_test.dart`

---

## Phase 2: State Management & Application Layer

- [ ] **TASK-[NNN]-03**: Implement state controller / notifier
  - **Traces**: `REQ-[NNN]-02`
  - **Verification**: `test/unit/[feature]_controller_test.dart`

---

## Phase 3: Presentation & UI Layer

- [ ] **TASK-[NNN]-04**: Implement custom painters / widgets for rendering
  - **Traces**: `REQ-[NNN]-03`
  - **Verification**: `test/widget/[feature]_widget_test.dart`
- [ ] **TASK-[NNN]-05**: Wire touch interaction and gesture recognizers
  - **Traces**: `REQ-[NNN]-03`, `NFR-[NNN]-03`
  - **Verification**: Tap gesture widget tests

---

## Phase 4: Polish, Edge Cases & Verification

- [ ] **TASK-[NNN]-06**: Implement edge case handlers (pause, interruptions, invalid moves)
  - **Traces**: Edge Cases in `spec.md`
  - **Verification**: Edge case unit/widget tests
- [ ] **TASK-[NNN]-07**: Run full test suite and verify acceptance criteria
  - **Traces**: All `AC-[NNN]` items in `spec.md`
  - **Verification**: `flutter test` passes 100%

---

## Sign-off & Completion
* **Verified By**: [Name/Role]
* **Date**: [YYYY-MM-DD]

