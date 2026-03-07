# GitOps: Bitbucket Pipelines

Create `bitbucket-pipelines.yml`:

```yaml
image: python:3.12-slim

pipelines:
  pull-requests:
    '**':
      - step:
          name: Validate TrueFoundry Specs
          script:
            - pip install 'truefoundry==0.5.0'
            - |
              while IFS= read -r file; do
                [ -z "$file" ] && continue
                echo "Validating $file..."
                tfy apply --file "$file" --dry-run
              done < <(git diff --name-only origin/"$BITBUCKET_PR_DESTINATION_BRANCH"...HEAD -- '*.yaml')

  branches:
    main:
      - step:
          name: Apply TrueFoundry Specs
          script:
            - pip install 'truefoundry==0.5.0'
            - |
              while IFS= read -r file; do
                [ -z "$file" ] && continue
                echo "Applying $file..."
                tfy apply --file "$file"
              done < <(git diff --name-only --diff-filter=ACMR HEAD~1 HEAD -- '*.yaml')
```

Set `TFY_HOST` and `TFY_API_KEY` as secured repository variables in Bitbucket. Restrict deployment pipelines to trusted branches only.
