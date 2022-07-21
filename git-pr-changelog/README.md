# git-pr-changelog.sh

Generates a changelog from pull request commit messages.

Presets for Azure Devops and GitLab included.

[Prebuild Download in ../dist](../dist/git-pr-changelog.sh)

## Example Output

```txt
Changelog based on completed Merge Reuqests

Project: /c/sources/prv/blog

Current Branch: master
Remote: https://git.brickburg.de/serverless.industries/blog.git
Start Ref: 2615a34
End Ref: HEAD

28a588a - 1 year, 3 months ago - Update jekyll and new Post  See merge request serverless.industries/blog!31
ecd33e6 - 1 year, 6 months ago - Smart Bell & Translations  See merge request serverless.industries/blog!30
693ef35 - 1 year, 11 months ago - New Post: YouLoop  See merge request serverless.industries/blog!29
7c59c1c - 2 years ago - New Post: Docker & NAT  See merge request serverless.industries/blog!28
f6caac9 - 2 years, 1 month ago - Custom Cards, Guenther  See merge request serverless.industries/blog!27
43866b0 - 2 years, 1 month ago - PWA + Service Worker  See merge request serverless.industries/blog!26
5fbbabd - 2 years, 2 months ago - New Posts + More English  See merge request serverless.industries/blog!25
07b61f6 - 2 years, 2 months ago - Add Table of contents  See merge request serverless.industries/blog!24
5918144 - 2 years, 4 months ago - Code Highlighting, More Infos about YayNay, PHP Session Posts  See merge request serverless.industries/blog!23
7153eb7 - 2 years, 4 months ago - Small Typos  See merge request serverless.industries/blog!22
2bd3e7b - 2 years, 4 months ago - sort tags, invoke-webrequests, windows runas system, bash cache refresh  See merge request serverless.industries/blog!21
cb46771 - 2 years, 5 months ago - Add Yay-Nay  See merge request serverless.industries/blog!20
53fd089 - 2 years, 7 months ago - Terraria+Docker  See merge request serverless.industries/blog!19
4eb552c - 2 years, 10 months ago - Multiple new Posts  See merge request serverless.industries/blog!18
ece5691 - 2 years, 11 months ago - Multiple posts  See merge request serverless.industries/blog!17

Generated at Thu Jul 21 21:23:27     2022
```