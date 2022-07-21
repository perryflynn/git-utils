# git-cleanup.sh

This script cleans up orpahned branches.

[Prebuild Download in ../dist](../dist/git-cleanup.sh)

```txt
git cleanup script

The operations will executed in the order as displayed here:

Operations:
-a, --all                     Perform all operations
                              operations on the current working copy possible
--local-branches              Delete local branches unchanged more than X days
--untracked-remote-branches   Delete untracked remote branches unchanged more than X days

Other options:
--max-age 60                  Max branch age in days, default is 60
-r, --remote                  Set the default remote, default: origin
-h, --help                    Print this help and exit
```

## Clean local branches (`--local-branches`)

This option will remove all local branches where the last commit is older
than `--max-age`. The main branch will skipped.

For each branch the script will ask you if deleting is okay. 
(Unless `--force` is set)

## Clean remote branches (`--untracked-remote-branches`)

This option will remove all untracked remote branches where the last commit is
older than `--max-age`. The main branch of the respective remote (`HEAD`) will
skipped.

For each branch the script will ask you if deleting is okay. 
(Unless `--force` is set)
