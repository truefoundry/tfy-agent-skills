# GitOps: GitLab CI Pipeline

Create `.gitlab-ci.yml`:

```yaml
stages:
  - validate
  - deploy

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

cache:
  paths:
    - .cache/pip

.tfy-setup: &tfy-setup
  image: python:3.12-slim
  before_script:
    - pip install 'truefoundry>=0.5.0,<1.0'

dry-run:
  <<: *tfy-setup
  stage: validate
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes:
        - "**/*.yaml"
  script:
    - |
      while IFS= read -r file; do
        [ -z "$file" ] && continue
        echo "Validating $file..."
        tfy apply --file "$file" --dry-run
      done < <(git diff --name-only origin/"$CI_MERGE_REQUEST_TARGET_BRANCH_NAME"...HEAD -- '*.yaml')

apply:
  <<: *tfy-setup
  stage: deploy
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      changes:
        - "**/*.yaml"
  script:
    - |
      while IFS= read -r file; do
        [ -z "$file" ] && continue
        echo "Applying $file..."
        tfy apply --file "$file"
      done < <(git diff --name-only --diff-filter=ACMR HEAD~1 HEAD -- '*.yaml')
```

Set `TFY_HOST` and `TFY_API_KEY` as CI/CD variables in GitLab (Settings -> CI/CD -> Variables).
