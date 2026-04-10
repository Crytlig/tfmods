# AGENTS.md

Instructions for AI coding agents working on this repository.

## Repository Overview

This is a collection of reusable Terraform modules targeting **Microsoft Azure** (`azurerm ~> 4.0`, Terraform `>= 1.6`). Modules live under `modules/` and are sourced via GitHub:

```
source = "github.com/crytlig/tfmods//modules/<module_name>?ref=main"
```

<!-- <!- rtk-instructions v2 -> -->

# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:

```bash
# ❌ Wrong
go build ./cmd/api && go test ./... && git push

# ✅ Correct
rtk go build ./cmd/api && rtk go test ./... && rtk git push
```

## RTK Commands by Workflow

```bash
rtk terraform plan
rtk terraform init
rtk go build ./...          # Go build output, compact
rtk go build -o bin/api ./cmd/api   # Build specific binary
rtk go build -o bin/worker ./cmd/worker
rtk go vet ./...            # Go vet, compact
rtk go test ./... -v        # Go test failures only (90%)
rtk test go test ./... -v   # Generic test wrapper - failures only
rtk lint                    # golangci-lint / ESLint violations grouped (84%)
rtk tsc                     # TypeScript errors grouped by file/code (83%)
rtk prettier -check        # Files needing format only (70%)
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

### GitHub (26-87% savings)

```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)

```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### Docker & Infrastructure (85% savings)

```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk docker compose up   # Docker Compose output
rtk docker compose down
```

### Files & Search (60-75% savings)

```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%)
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)

```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Network (65-70% savings)

```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands

```bash
rtk gain                # View token savings statistics
rtk gain -history      # View command history with savings
rtk discover            # Analyze sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
```

<!-- <!- /rtk-instructions -> -->

## Project Structure

```
tfmods/
├── modules/               # All Terraform modules
│   ├── cooli-worker/      # Coolify worker VM (wraps AVM)
│   ├── key_vault/         # Azure Key Vault with RBAC
│   ├── private_endpoint/  # Azure Private Endpoint
│   ├── resource_group/    # Azure Resource Group
│   ├── subnet/            # Azure Subnet + optional associations
│   ├── virtual_machine/   # Azure Linux VM
│   ├── virtual_network/   # Azure Virtual Network
│   └── web_app/           # Azure Linux Web App
├── scripts/               # Automation scripts
│   ├── asdf.sh            # Install tool versions via asdf
│   ├── docs.sh            # Generate README docs for all modules
│   └── scaffold.sh        # Scaffold a new module (uses gum)
├── templates/             # Templates for scaffolding
│   ├── .terraform-docs.yml
│   └── provider.tf
├── .editorconfig          # 2-space indent for .tf/.tfvars/.hcl
├── .tflint.hcl            # TFLint config (azurerm plugin)
├── .tool-versions         # asdf pinned versions
└── Makefile               # make scaffold | make docs | make asdf
```

## Module File Layout

Every module must follow this structure:

```
modules/<module_name>/
├── main.tf                # Resource definitions
├── variables.tf           # Input variable declarations
├── outputs.tf             # Output value declarations
├── provider.tf            # required_version + required_providers ONLY
├── README.md              # Auto-generated by terraform-docs
├── .terraform-docs.yml    # terraform-docs configuration
└── examples/
    └── default/
        ├── main.tf        # Usage example
        └── provider.tf    # Includes provider "azurerm" { features {} }
```

## Creating a New Module

Use the scaffold script or make target:

```bash
./scripts/scaffold.sh my_module  # Non-interactive
```

This creates the full directory structure with template files. After scaffolding, implement the module and run `make docs` to generate the README.

## Code Conventions

Use the terraform-styleguides skill

### Formatting

- 2-space indentation, no tabs
- Always run `terraform fmt -recursive` before committing
- Align `=` signs for consecutive arguments within a block

### Naming

- **Module directories**: `snake_case` (e.g., `resource_group`, `virtual_network`)
- **Resource local names**: Use `"this"` as the default name (e.g., `azurerm_key_vault.this`). Only deviate when the module manages multiple resources of the same type.
- **Variable names**: `snake_case`, consistently reuse common names across modules

### Common Variables

These variables appear in nearly every module and should be included in new modules:

| Variable              | Type                        | Required | Description                  |
| --------------------- | --------------------------- | -------- | ---------------------------- |
| `name`                | `string`                    | yes      | Name of the primary resource |
| `location`            | `string`                    | yes      | Azure region                 |
| `resource_group_name` | `string`                    | yes      | Target resource group        |
| `tags`                | `map(any)` or `map(string)` | varies   | Tags to assign to resources  |

### Variables

- Every variable must have `type` and `description`
- Use `validation` blocks for input constraints (regex, value ranges, allowed values)
- Use HEREDOC (`<<DESCRIPTION ... DESCRIPTION`) for long multi-line descriptions, especially for complex object variables
- Use `optional()` with defaults inside object types
- Place required variables first, then optional variables with defaults
- Mark sensitive variables with `sensitive = true`

### Outputs

- Every output must have a `description`
- At minimum, expose the `id` of the primary resource

### Resources

- Place `data` sources before `resource` blocks in `main.tf`
- Use `dynamic` blocks for optional nested configuration
- Use `count` with ternary expressions for conditional resource creation: `count = var.x == null ? 0 : 1`
- Use `for_each` for maps/sets of resources
- Place `lifecycle` blocks last within a resource
- Place `tags = var.tags` as the last argument before any blocks

### Provider Configuration

- Module-level `provider.tf` declares `required_version` and `required_providers` only -- never include a `provider` block in the module itself
- The `provider "azurerm" {}` block belongs only in `examples/*/provider.tf`

### Provider Versions

```hcl
terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
```

## Documentation

READMEs are auto-generated. Never edit module README.md files by hand.

```bash
make docs
```

This runs `terraform-docs` against every module using each module's `.terraform-docs.yml` config. Generated docs include input/output tables and the embedded `examples/default/main.tf`.

## Linting

TFLint is configured with the `azurerm` plugin and enforces the `azurerm_resource_missing_tags` rule. All resources that support tags must include them.

```bash
tflint --init
tflint
```

## Tooling

Tools are managed via [asdf](https://asdf-vm.com/). Install all required versions:

```bash
make asdf
```

Pinned versions (from `.tool-versions`):

| Tool           | Version |
| -------------- | ------- |
| terragrunt     | 0.59.5  |
| terraform-docs | 0.16.0  |
| terramate      | 0.9.0   |
| tflint         | 0.51.1  |
| gum            | 0.14.1  |

## Reference Module

The `key_vault` module (`modules/key_vault/`) is the most mature module in this repository. Use it as a reference for:

- Input validation patterns (regex, value constraints, null-safety)
- HEREDOC descriptions for complex object variables
- Dynamic blocks for optional configuration
- Conditional resource creation with `count`
- Role assignment patterns
- Proper output definitions

## Things to Avoid

- Do not add `provider` blocks to module-level code (only in examples)
- Do not manually edit `README.md` files inside modules -- they are auto-generated
- Do not commit `.terraform/` directories, state files, or `*.auto.tfvars`
- Do not hardcode credentials or secrets in any file

## Hard rules

- Always use worktrees (located in .worktrees)
- Keep commits atomic: commit only the files you touched and list each path explicitly. For tracked files run `git commit -m "<scoped message>" - path/to/file1 path/to/file2`. For brand-new files, use the one-liner `git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<scoped message>" - path/to/file1 path/to/file2`.
- Quote any git paths containing brackets or parentheses (e.g., `src/app/[candidate]/**`) when staging or committing so the shell does not treat them as globs or subshells.
- When running `git rebase`, avoid opening editors—export `GIT_EDITOR=:` and `GIT_SEQUENCE_EDITOR=:` (or pass `--no-edit`) so the default messages are used automatically.
- Never amend commits unless you have explicit written approval in the task thread.
- When you need to search docs, use `context7` or `mcp:fetch` tools.
- NEVER edit .env or any environment variable files—only the user may change them.
- Moving/renaming and restoring files is allowed.
- ABSOLUTELY NEVER run destructive git operations (e.g., `git reset -hard`, `rm`, `git checkout`/`git restore` to an older commit) unless the user gives an explicit, written instruction in this conversation. Treat these commands as catastrophic; if you are even slightly unsure, stop and ask before touching them. _(When working within Cursor or Codex Web, these git limitations do not apply; use the tooling's capabilities as needed.)_
- Never use `git restore` (or similar commands) to revert files you didn't author—coordinate with other agents instead so their in-progress work stays intact.
- Always double-check git status before any commit
- Keep commits atomic: commit only the files you touched and list each path explicitly. For tracked files run `git commit -m "<scoped message>" - path/to/file1 path/to/file2`. For brand-new files, use the one-liner `git restore -staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<scoped message>" - path/to/file1 path/to/file2`.
- ALWAYS use single dashes when writing, i.e. `-`. Never `--`
- Never merge locally. Always push your changes to GitHub and create PRs there for a human to review
