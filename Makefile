all: build_git-clean-sync

build_git-clean-sync:
	@echo "#-> Build git-clean-sync.sh"

	mkdir -p dist/
	cat shared/header.sh > dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	cat shared/functions.sh >> dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	cat git-clean-sync/args.sh >> dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	cat git-clean-sync/init.sh >> dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	cat git-clean-sync/main.sh >> dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	chmod a+x dist/git-clean-sync.sh

clean:
	rm -rf dist/
