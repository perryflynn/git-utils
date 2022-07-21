# git-utils

A collection of hopefully helpful scripts to work with git repositories.

| Script | Description | Download Link |
|---|---|---|
| [git-clean-sync.sh](git-clean-sync/) | fetch, pull, push, merge, delete merged PR branches, all-in-one | [Download](dist/git-clean-sync.sh) |
| [git-cleanup.sh](git-cleanup/) | Cleanup local and remote branches where the last commit is older than X days | [Download](dist/git-cleanup.sh) |

## No need to build

Just use the latest builds in the `dist/` folder.

## Changelog

- 2022-07-21: Add option to update default branch (aka `HEAD`) from remote
- 2022-07-21: Add new script `git-cleanup.sh`

## Build

To make the life of the developer easier, the code is separated in
multiple files. You can use `make` to build the scripts.

- `make`: Builds all scripts
- `make clean`: Delete existing builds
