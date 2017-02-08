# See LICENSE for licensing information.
PROJECT = pub_params
VERSION = 0.1.0
CHMOD = $(shell chmod +x ./rebar3)
REBAR = ./rebar3

.PHONY: build clean version release doc #dialyze test

all: clean build

build:
	@$(CHMOD)
	@$(REBAR) compile

version:
	@echo "Setting version:$(VERSION)"
	perl -p -i -e "s/^\s*{vsn,.*/  {vsn, \"$(VERSION)\"},/g" src/${PROJECT}.app.src
	perl -p -i -e "s/^{relx,.*/{relx, [{release, { ${PROJECT} , \"$(VERSION)\" },/g" rebar.config
	perl -p -i -e "s/^{.*/{\"$(VERSION)\",/g" src/${PROJECT}.appup.src
	@echo "Version Changed Done!"

#Generate a release 
release:
	@$(CHMOD)
	@$(REBAR) release

console:
	./_build/default/rel/${PROJECT}/bin/${PROJECT} console

doc:
	@$(REBAR) edoc

clean:
	@$(REBAR) clean

.PHONY: pack upgrade relup test

pack:
	@$(REBAR) as ${VERSION} tar
	# @$(REBAR) tar -n ${PROJECT} -i true

#Generate a release for upgrade 
relup:
	@$(REBAR) relup -u ${VERSION} tar

upgrade:
	@$(REBAR) upgrade

test:
	@$(REBAR) ct
	@$(REBAR) eunit