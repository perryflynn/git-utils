# git-utils

A collection of hopefully helpful scripts to work with git repositories.

| Script | Description | Download Link |
|---|---|---|
| [git-clean-sync.sh](git-clean-sync/) | fetch, pull (merge), auto-set remote, push, delete merged PR branches; everything **without touching the checked out workcopy** | [Download](dist/git-clean-sync.sh) |
| [git-cleanup.sh](git-cleanup/) | Cleanup local and remote branches where the last commit is older than X days | [Download](dist/git-cleanup.sh) |
| [git-pr-changelog.sh](git-pr-changelog/) | Generates a changelog from pull request commit messages | [Download](dist/git-pr-changelog.sh) |

## No need to build

Just use the latest builds in the `dist/` folder.

## Changelog

- 2022-07-21: Add option to update default branch (aka `HEAD`) from remote
- 2022-07-21: Add new script `git-cleanup.sh`
- 2022-07-21: Add new script `git-pr-changelog.sh`

## Build

To make the life of the developer easier, the code is separated in
multiple files. You can use `make` to build the scripts.

- `make`: Builds all scripts
- `make clean`: Delete existing builds
