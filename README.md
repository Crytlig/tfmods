# Terraform modules

The following contains several terraform modules, scaffolding scripts, linting
formatting, automation etc.

The modules are used for several different demos and patterns.

## Playground

As the repository is also used for testing various tools in the eco-system, there might be specific files laying around, such as stacks for terramate, terragrunt files, linting etc.

## Make

[scripts/asdf.sh](./scripts/asdf.sh) installs all necessary tools from [.tool-versions](./.tool-versions)

[scripts/scaffold.sh](./scripts/scaffold.sh) scaffolds a new module directory. Either use the script or make

### Initialize with make, interactive only

```bash
make scaffold
```

### Initialize with named module

```bash
module=new_module
./scripts/scaffold.sh $module
```

### Initialize interactive

```bash
./scripts/scaffold.sh
> Input module name

enter submit
```

## TODOS

- [ ] Add precommit hook
- [ ] Fix tflint
- [ ] Update all examples
- [ ] Add CI workflow
- [ ] Add pattern modules
