.PHONY: help
help: Makefile
	@echo
	@echo " Choose a make command to run"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## asdf: uses asdf to install versions defined in .tool-versions
.PHONY: asdf
asdf:	
	./scripts/asdf.sh

## scaffold: scaffolds a new terraform module
.PHONY: scaffold
scaffold:
	./scripts/scaffold.sh

