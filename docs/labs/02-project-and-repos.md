# Lab 02 — Create Project & Repos

Create project **HDP-Labs** and two repos: **Azure-1** and **Azure-2**.

## Create project
1. `https://dev.azure.com/YOUR-ORG` → **+ New project**.  
2. Name: `HDP-Labs`, Private, Git, Agile.  
3. Create.

## Create repos
1. **Repos** → repo dropdown → **+ New repository**.  
2. Name: `Azure-1` (Add README). Repeat for `Azure-2`.  
3. Record clone URLs.

## Protect `main`
- **Project settings → Repositories →** select repo → **Policies → main**:  
  - Reviewers: min 1  
  - Comment resolution: **On**  
  - Linked work items: **Required**  
  - Merge types: **Squash** only  
  - Build validation → will add in Lab 07/08.
