GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
GIT_TAG=$(shell git describe --exact-match --tags 2>/dev/null)
GIT_LAST_TAG=$(shell git describe --tags --abbrev=0)

ifeq ($(GIT_TAG),)
	ifeq ($(GIT_BRANCH), master)
		VERSION=snapshot
		CBD_VERSION=snapshot
  	else
		VERSION=$(GIT_BRANCH)-snapshot
		CBD_VERSION=$(GIT_LAST_TAG)
  	endif
else
	VERSION=$(GIT_TAG)
	CBD_VERSION=$(GIT_TAG)
endif

echo_version:
	$(info GIT_BRANCH=$(GIT_BRANCH))
	$(info GIT_TAG=$(GIT_TAG))
	$(info VERSION=$(VERSION))
	$(info CBD_VERSION=$(CBD_VERSION))

deps:
	curl -sL https://github.com/lalyos/sigil/releases/download/v0.4.1/sigil_0.4.1_$(shell uname)_x86_64.tgz | tar -xz -C /usr/local/bin
	curl -sL https://github.com/lalyos/atlas/releases/download/v0.0.5/atlas_0.0.5_$(shell uname)_x86_64.tgz | tar -xz -C /usr/local/bin/

build:
	@sigil -f mainTemplate.tmpl VERSION="$(CBD_VERSION)" > mainTemplate.json
	@sigil -f README.md.tmpl VERSION="$(CBD_VERSION)" > README.md
	if ! git diff --exit-code > /dev/null; then \
		git commit -am "update version"; \
		git tag $(NEW_VERSION); \
		git push origin HEAD:$(GIT_BRANCH) --tags; \
	fi

build-as-snapshot:
	rm -rf build
	git tag snapshot
	make build
	git tag snapshot -d

.PHONY: build