# Lab 01 — Prerequisites (Zero‑to‑Hero)

## 1) Install tools
- **Git** 2.39+
- **Docker** Desktop/Engine (with **Docker Compose**)
- **PowerShell 7+** or **Bash**
- (Optional) **VS Code** with *YAML* + *Git* extensions

## 2) Create/confirm an Azure DevOps Organization
- Browse to `https://dev.azure.com/` and create (or select) your org.

## 3) Create a Personal Access Token (PAT)
> Least‑privilege and short‑lived.

1. In Azure DevOps, click your avatar (top‑right) → **User settings** → **Personal access tokens** → **+ New Token**.

2. Name it: `devops-box-agent`.

3. Expiration: 90 days (or shorter for labs).

4. **Scopes → Custom defined → Show all scopes**. Tick only:

   - **Agent Pools (Read & manage)**

   - **Code (Read & write)**

   - **Project and Team (Read)**

5. Click **Create** and copy the token **immediately**. Store it securely.


## 4) Prepare local repo folder
Clone or download this repository. We’ll keep **secrets in `.env`** (gitignored).

```bash

cp .env.example .env

# edit .env with your values (AZP_URL, AZP_TOKEN, ...)

```

