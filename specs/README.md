# Specifications Directory

This directory houses all feature specifications, technical plans, and task breakdowns for **Screw Escape** following Spec-Driven Development (SDD).

---

## Structure

```text
specs/
├── README.md                      # This guide
├── templates/                     # Document templates
│   ├── spec.md                    # Feature specification template
│   ├── plan.md                    # Architecture and technical plan template
│   └── tasks.md                   # Phased task breakdown template
└── 001-<feature-name>/            # Concrete feature specification folder
    ├── spec.md
    ├── plan.md
    └── tasks.md
```

## How to Start a Feature

1. Create a new directory under `specs/`: `specs/NNN-<short-name>/` (e.g., `specs/001-board-mechanics/`).
2. Copy `templates/spec.md` into the new directory as `spec.md`. Fill out goals, stories, and numbered requirements (`REQ-NNN-XX`).
3. Submit `spec.md` for review and obtain explicit approval.
4. Copy `templates/plan.md` into the directory as `plan.md`. Define the clean architecture design and requirement mappings. Obtain approval.
5. Copy `templates/tasks.md` into the directory as `tasks.md`. Break down implementation into test-driven, incremental phases. Obtain approval.
6. Begin implementation strictly following the tasks.

