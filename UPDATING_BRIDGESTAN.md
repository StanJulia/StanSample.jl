# Updating BridgeStan

_This page is meant for maintainers of the package._

[BridgeStan](https://gitlab.com/roualdes/bridgestan) was included in this repo using [git subtree](https://www.atlassian.com/git/tutorials/git-subtree) with the following command:

```bash
git subtree add --prefix deps/data/bridgestan https://github.com/roualdes/bridgestan.git main --squash
```

When the BridgeStan repo is updated, the version in this repo should also be updated using

```bash
git subtree pull --prefix deps/data/bridgestan https://github.com/roualdes/bridgestan.git main --squash
```
