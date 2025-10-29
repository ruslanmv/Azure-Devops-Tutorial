# Lab 09 — Branch Policies & Best Practices

## Policies
- Reviewers ≥ 1, comment resolution, linked work, squash merges.  
- Build validation required (Lab 07/08).

## PR Template
`.azuredevops/pull_request_template.md`
```markdown
## Description
What & why

## Type
- [ ] Feature
- [ ] Fix
- [ ] Refactor
- [ ] Docs

## Tests
How tested?

## Checklist
- [ ] Self-review
- [ ] Comments for complex logic
- [ ] Tests updated/added
- [ ] Pipeline green
- [ ] Linked work items
```

## Secrets
- Pipelines → Library → Variable group (lock 🔒 secrets).  
- Use in YAML:
  ```yaml
  variables:
    - group: production-secrets
  steps:
    - script: echo "Using secrets safely"
      env:
        API_KEY: $(API_KEY)
  ```

## Performance
- Shallow checkout (`fetchDepth: 1`)  
- Cache dependencies (Cache@2)  
- Pin container/tool versions.

## Templates
```yaml
# templates/common.yml
parameters:
  - name: folder
    type: string
  - name: build
    type: string
steps:
  - bash: |
      cd ${{ parameters.folder }}
      ${{ parameters.build }}
```

## Agent Hygiene
- Keep up to date, monitor disk usage, run as non‑root (DevOps Box already does).
