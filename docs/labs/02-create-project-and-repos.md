# Lab 02 — Create Project and Repos

## 1) Create the project
1. Azure DevOps → **New project**

2. Name: `HDP-Labs`, Visibility: **Private**, Version control: **Git**


## 2) Create two empty repos
Within the project’s **Repos** area:

- Create repository **Azure-1** (empty)

- Create repository **Azure-2** (empty)


## 3) Protect `main`
Navigate to **Project Settings → Repositories → (repo) → Policies → Branches → main**:

- Require **Pull request** to update `main`

- **Minimum reviewers**: 1–2

- **Build validation**: add later after we create pipelines

- **Merge type**: prefer **Squash**

- (Optional) Enforce comment resolution & linked work items


## 4) Permissions (least privilege)
- Use built‑in groups: **Contributors** (push/PR), **Readers** (read‑only)

- Grant only what’s necessary; avoid org‑wide PATs for routine tasks

