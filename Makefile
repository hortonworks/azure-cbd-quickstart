GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)


echo_version:
	$(info GIT_BRANCH=$(GIT_BRANCH))
	$(info NEW_VERSION=$(NEW_VERSION))

deps:
	curl -sL https://github.com/lalyos/sigil/releases/download/v0.4.1/sigil_0.4.1_$(shell uname)_x86_64.tgz | tar -xz -C /usr/local/bin
	curl -sL https://github.com/lalyos/atlas/releases/download/v0.0.5/atlas_0.0.5_$(shell uname)_x86_64.tgz | tar -xz -C /usr/local/bin/

build:
	@sigil -f mainTemplate.tmpl VERSION="$(NEW_VERSION)" > mainTemplate.json
	@sigil -f README.md.tmpl VERSION="$(NEW_VERSION)" > README.md
	if ! git diff --exit-code > /dev/null; then \
		git commit -am "update version to $(NEW_VERSION)"; \
		git tag $(NEW_VERSION); \
		git push origin HEAD:$(GIT_BRANCH) --tags; \
	fi

build-as-snapshot:
	rm -rf build
	git tag snapshot
	make build
	git tag snapshot -d

.PHONY: build