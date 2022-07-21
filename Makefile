all: clean build_git-clean-sync build_git-cleanup build_git-pr-changelog

build_git-clean-sync:
	@echo "#-> Build git-clean-sync.sh"

	mkdir -p dist/
	cat shared/header.sh > dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	cat shared/functions.sh >> dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	cat git-clean-sync/args.sh >> dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	cat git-clean-sync/help.sh >> dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	cat shared/init.sh >> dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	cat git-clean-sync/main.sh >> dist/git-clean-sync.sh
	echo "\n\n" >> dist/git-clean-sync.sh

	chmod a+x dist/git-clean-sync.sh

build_git-cleanup:
	@echo "#-> Build git-cleanup.sh"

	mkdir -p dist/
	cat shared/header.sh > dist/git-cleanup.sh
	echo "\n\n" >> dist/git-cleanup.sh

	cat shared/functions.sh >> dist/git-cleanup.sh
	echo "\n\n" >> dist/git-cleanup.sh

	cat git-cleanup/args.sh >> dist/git-cleanup.sh
	echo "\n\n" >> dist/git-cleanup.sh

	cat git-cleanup/help.sh >> dist/git-cleanup.sh
	echo "\n\n" >> dist/git-cleanup.sh

	cat shared/init.sh >> dist/git-cleanup.sh
	echo "\n\n" >> dist/git-cleanup.sh

	cat git-cleanup/main.sh >> dist/git-cleanup.sh
	echo "\n\n" >> dist/git-cleanup.sh

	chmod a+x dist/git-cleanup.sh

build_git-pr-changelog:
	@echo "#-> Build git-pr-changelog.sh"

	mkdir -p dist/
	cat shared/header.sh > dist/git-pr-changelog.sh
	echo "\n\n" >> dist/git-pr-changelog.sh

	cat shared/functions.sh >> dist/git-pr-changelog.sh
	echo "\n\n" >> dist/git-pr-changelog.sh

	cat git-pr-changelog/args.sh >> dist/git-pr-changelog.sh
	echo "\n\n" >> dist/git-pr-changelog.sh

	cat git-pr-changelog/help.sh >> dist/git-pr-changelog.sh
	echo "\n\n" >> dist/git-pr-changelog.sh

	cat shared/init.sh >> dist/git-pr-changelog.sh
	echo "\n\n" >> dist/git-pr-changelog.sh

	cat git-pr-changelog/main.sh >> dist/git-pr-changelog.sh
	echo "\n\n" >> dist/git-pr-changelog.sh

	chmod a+x dist/git-pr-changelog.sh

clean:
	rm -rf dist/
	mkdir -p dist/
	touch dist/.gitkeep
