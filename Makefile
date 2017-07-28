GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
ifeq ($(GIT_BRANCH),master)
	export CBD_VERSION=snapshot
	export NEW_VERSION=master
else
	export CBD_VERSION=$(NEW_VERSION)
endif

echo_version:
	$(info GIT_BRANCH=$(GIT_BRANCH))
	$(info CBD_VERSION=$(CBD_VERSION))
	$(info NEW_VERSION=$(NEW_VERSION))

deps:
	curl -sL https://github.com/lalyos/sigil/releases/download/v0.4.1/sigil_0.4.1_$(shell uname)_x86_64.tgz | tar -xz -C /usr/local/bin
	curl -sL https://github.com/lalyos/atlas/releases/download/v0.0.5/atlas_0.0.5_$(shell uname)_x86_64.tgz | tar -xz -C /usr/local/bin/

build:
	./create-template.sh
	sigil -f README.md.tmpl VERSION="$(NEW_VERSION)" > README.md

push:
	if ! git diff --exit-code > /dev/null; then \
		echo "push git tag $(NEW_VERSION)"; \
		git commit -am "update version to $(NEW_VERSION)"; \
		if [[ "$NEW_VERSION" -ne "master" ]]; then \
			git tag -f $(NEW_VERSION); \
			git push origin $(NEW_VERSION); \
		fi; \
		git push -f origin HEAD:$(GIT_BRANCH); \
	fi

build-as-snapshot:
	rm -rf build
	git tag snapshot
	make build
	git tag snapshot -d

package:
	rm -rf package
	mkdir package
	zip package/ver ./* -x *.tmpl -x *Private* -x package/
	unzip -lv ./package/ver.zip

.PHONY: build package
