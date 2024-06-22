# Terraform modules

The following contains several terraform modules, scaffolding scripts, linting
formatting, automation etc.

The modules are used for several different demos and patterns.

## Secure by default

The modules, contrary to other modules, such as the [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/) and default Terraform resources, are supposed to be secure by default. Essentially, that means everything is private by default, meaning everything public is opt-in instead of defaulting to opt-out. The modules examples are also created to be ready to use.

## Playground

As the repository is also used for testing various tools in the eco-system, there might be specific files laying around, such as stacks for terramate, terragrunt files, linting etc.

## Make

[asdf](./scripts/asdf.sh) installs all necessary tools from [.tool-versions](./.tool-versions)

[scaffold.sh](./scripts/scaffold.sh) scaffolds a new module directory. Either use the script or make

### Initialize with make, intactive only

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
