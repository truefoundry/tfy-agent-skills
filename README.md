# TrueFoundry Agent Skills

[![CI](https://github.com/truefoundry/tfy-agent-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/truefoundry/tfy-agent-skills/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills.sh-truefoundry-blue)](https://skills.sh/truefoundry/tfy-agent-skills)

Deploy, monitor, and manage ML infrastructure — from your AI coding agent.

25 skills that teach your agent to work with [TrueFoundry](https://truefoundry.com). Just install and start asking.

Works with Claude Code, Cursor, Codex, OpenCode, Windsurf, Cline, and Roo Code.

## Install

```bash
npx skills add truefoundry/tfy-agent-skills
```

Or use the direct installer:

```bash
curl -fsSL https://raw.githubusercontent.com/truefoundry/tfy-agent-skills/main/scripts/install.sh | bash
```

Set your credentials (env vars or `.env` in your project root):

```bash
export TFY_BASE_URL=https://your-org.truefoundry.cloud
export TFY_API_KEY=tfy-...  # https://docs.truefoundry.com/docs/generate-api-key
```

Restart your agent. That's it.

> Do not commit `.env` or API keys to Git.

## What You Can Do

Just ask your agent in plain English:

- *"deploy my FastAPI app"*
- *"show logs for my-service"*
- *"what's deployed?"*
- *"launch a Jupyter notebook with a GPU"*
- *"deploy Postgres with Helm"*
- *"set up a secret for my database password"*
- *"show me the costs for my workspace"*

Your agent automatically picks the right skill based on what you ask.

## Skills

| Category | Skills |
|----------|--------|
| **Deploy** | deploy, gitops |
| **LLM & AI** | llm-deploy, ai-gateway, mcp-servers |
| **Infrastructure** | helm, volumes, secrets |
| **Security** | guardrails, access-control |
| **Jobs & Pipelines** | jobs, workflows |
| **Dev Environments** | notebooks, ssh-server |
| **Observe & Debug** | logs, service-test, applications, tracing |
| **Utility** | status, workspaces, prompts, docs, preferences, access-tokens, ml-repos |

Each skill is a standalone markdown file (`skills/{name}/SKILL.md`) following the [Agent Skills](https://agentskills.io) open format.

## How It Works

Skills are markdown files with instructions your agent reads at runtime. When you ask a question, your agent matches it to the right skill and follows the instructions — calling TrueFoundry APIs, running CLI commands, or both.

No SDKs to learn, no code to write. Your agent handles everything.

## Development

```bash
# Edit shared files in skills/_shared/, then sync to all skills
./scripts/sync-shared.sh

# Install and restart
./scripts/install.sh
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on adding new skills.

## Advanced: Auto-Approve API Calls (Claude Code)

By default, Claude Code prompts for approval on each API call. To auto-approve TrueFoundry calls only:

```bash
cp -r hooks/ ~/.claude/hooks/
```

Requires `jq`. The hook validates and approves only `tfy-api.sh` commands — everything else still requires manual approval.

## Community

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)
- [Support](SUPPORT.md)

## License

MIT
