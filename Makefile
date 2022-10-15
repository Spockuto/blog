.PHONY: deploy
deploy: book
	@echo "====> deploying to github"
	git worktree add /tmp/build/ gh-pages
	mdbook build
	rm -rf /tmp/build/*
	cp -rp book/* /tmp/build/
	cd /tmp/build/ && \
		git update-ref -d refs/heads/gh-pages && \
		git add -A && \
		git commit -m "deployed on $(shell date) by ${USER}" && \
		git push --force origin gh-pages