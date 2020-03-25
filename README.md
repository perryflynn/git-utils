# git-utils

A collection of hopefully helpful scripts to work with git repositories.

## No need to build

Just use the existing builds in the `dist/` folder.

## Build

To make the life of the developer easier, the code is separated in
multiple files. You can use `make` to build the scripts.

- `make`: Builds all scripts
- `make clean`: Delete existing builds

## git-clean-sync.sh

This script makes working with branches much more easier.

```
git cleanup and synchronization script

The operations will executed in the order as displayed here:

Operations:
-a, --all-pull        Perform all local operations
-aa, --all-twoway     Perform all local and remote (push) operations
-aaa, --all-full      Perform everything including
                      for the current working copy branch
-t, --temp-branch     Create a temporary branch to make
                      operations on the current working copy possible
-f, --fetch           Download all current changes
-l, --link            Link local und remote branches with the same name
-p, --pull            Merge fetched changes into local branches
-d, --delete-orpaned  Delete orphaned local branches
-p, --push            Push all local branches and tags to all remotes
-s, --summary         Show an summary after all other operations

Other options:
--force               Do not ask anything. Just do it.
-h, --help            Print this help and exit
```

### Perform all local operations (`-a`)

Alias for `git-clean-sync -f -l -p -d -s`.

But it leaves the current working copy alone.

### Perform all local and remote operations (`-aa`)

Alias for `git-clean-sync -f -l -p -d -p -s`.

But it leaves the current working copy alone.

### Perform everything, everywhere (`-aaa`)

Alias for `git-clean-sync -t -f -l -p -d -p -s`.

Creates an temporary branch and checks it out so that also the current working copy
can be updated or deleted (because the branch is orphaned).

### Create temporary branch (`-t`)

Some operations like deleting an orphaned branch can affect the current working copy.
So this option creates an temporary branch and checks it out. After all other operations
are done, the previous branch is checked out again and the temporary branch is deleted.

### Fetch changes from remote (`-f`)

This option fetches all new changes from all remotes but will **not** merge them
into the local branches.

### Link local and remote branches (`-l`)

This option will set an upstream branch on a local branch if an unlinked remote
branch with the same name exists.

### Integrate changes into local branches (`-p`)

This option merges all changes from the remote branch (`origin/*`) into the local
branches. This does not affect the currently checked out branch.

So no need to stop running development servers or whatever.

### Delete orphaned branches (`-d`)

This option deletes local branches which are tracking remote branches which does not
exists anymore (deleted after the pull request is merged for example).

This option helps to clean up your own local development repo.

Also it **will ask you** for each branch whether you are really sure.

### Push local changes (`-p`)

Pushes all local changes to the tracked remote branch.

### Show a summary (`-s`)

Shows the current status of all local and remote branches.

### Example output

`git-clean-sync -aaa --force`:

```
[i] Current directory: /home/christian/gitweb-repos/blog
[*] Create and checkout a temporary branch...
[>] git checkout -b tmp.a27yhjRcO1
[!] Switched to a new branch 'tmp.a27yhjRcO1'
[*] Fetch all changes from remote...
[>] git fetch --all --prune --tags
[<] Fetching origin
[<] Fetching github
[!] From git.brickburg.de:serverless.industries/blog
[!] - [deleted]         (none)     -> origin/foo
[*] Find unlinked local and remote branches with the same name and link them...
[>] git branch -vv
[*] Integrate changes into tracking branches...
[>] git branch -vv
[i] Found 1 tracked branches: master
[i] Skip branch 'master' because there are no incoming changes.
[*] Find orphaned branches...
[>] git branch -vv
[i] Found 1 orphaned branches.
[<]   foo            5918144 [origin/foo: gone] Merge branch 'php-sessions-suck' into 'master'
[*] Delete branch 'foo'...
[>] git branch -D foo
[<] Deleted branch foo (was 5918144).
[*] Push changes in tracking branches to the remotes...
[>] git branch -vv
[i] Found 1 tracked branches: master
[i] Skip branch 'master' because there are no outgoing changes.
[*] Checkout 'foo' and delete the temporary branch...
[>] git rev-parse --quiet --verify foo
[i] The branch foo doesn't exist anymore, use first branch in list.
[>] git branch -vv
[*] Checkout 'apple' as a replacement for 'foo'...
[>] git checkout apple
[!] Switched to branch 'apple'
[>] git branch -D tmp.a27yhjRcO1
[<] Deleted branch tmp.a27yhjRcO1 (was 5918144).
[*] Show the current state of all local branches...
[>] git branch -vv
[<] * apple      afd5fa8 text
[<]   master     5918144 [origin/master] Merge branch 'php-sessions-suck' into 'master'
[<]   netconsole 3bf5433 foo
[<]   pi4        6db2aae rename
[*] Show the current state of all remote branches...
[>] git branch -vv -r
[<]   github/master  5918144 Merge branch 'php-sessions-suck' into 'master'
[<]   origin/HEAD    -> origin/master
[<]   origin/master  5918144 Merge branch 'php-sessions-suck' into 'master'
[<]   origin/ulticon 3114d86 Merge branch 'master' into ulticon
```
