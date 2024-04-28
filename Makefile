.PHONY: all
all:
	false

.PHONY: CHANGELOG.md
CHANGELOG.md:
	git cliff --output CHANGELOG.md

CHANGELOG.html: CHANGELOG.md
	pandoc \
		--standalone \
		--output CHANGELOG.html \
		--metadata title='peaceful+ changelog' \
		peaceful+/CHANGELOG.md

.PHONY: export
export: CHANGELOG.md CHANGELOG.html
	sed -i 's/Peaceful+ .*/Peaceful+ v'"$$(make -s version)"'"/g' \
		peaceful+/pack.mcmeta
	7z a -tzip peaceful+.zip -w peaceful+/. 
	sed -i 's/Peaceful+ .*/Peaceful+ USES_GIT"/g' \
		peaceful+/pack.mcmeta

.PHONY: clean
clean:
	rm peaceful+.zip

.PHONY: tag-release
tag-release:
	# Ensure we're at the right commit/branch
	[ "$$(git rev-parse --abbrev-ref HEAD)" = "main" ]
	# Ensure working directory is clean
	[ -z "$$(git status --porcelain :/)" ]
	# Ensure we're up to date
	git pull --ff-only
	[ "$$(git rev-parse HEAD)" = "$$(git rev-parse origin/main)" ]
	# If not tagged, tag to the next version and push.
	git describe --exact-match --match 'v*' > /dev/null || { \
		version="$$(git cliff --bumped-version)" && \
		git tag -a -m "$$version" "$$version"; \
		git push --follow-tags; \
	}

# Just give current version
.PHONY: version
version:
	@git describe --match 'v*' | cut -c 2-

