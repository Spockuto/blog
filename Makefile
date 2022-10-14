.PHONY: deploy
deploy: book
	@echo "====> deploying to github"
	git worktree add ./build/ gh-pages
	mdbook build
	rm -rf ./build/*
	cp -rp book/* ./build/
	cd ./build/ && \
		git update-ref -d refs/heads/gh-pages && \
		git add -A && \
		git commit -m "deployed on $(shell date) by ${USER}" && \
		git push --force origin gh-pages