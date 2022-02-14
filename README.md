# Threeflow
A git branching model which is based on 3 branches: develop, candidate and main.

The original inspiration for this was the cactus model, and [this article](https://www.nomachetejuggling.com/2017/04/09/a-different-branching-strategy/)

### Installation

To use this script you'll first have to clone the repo, then add it to your PATH. 

If you are on Linux/MacOS, you can do the following:

1. Clone the git repo
```bash 
git clone git@github.com:patbeagan1/Threeflow.git
```

2. Add the repo directory to your path
```bash
cd Threeflow && export PATH="$PATH:`pwd`
```

3. Rehash (so the script will be discovered, and you can use it right away)
```
hash -r
```

4. Try out `flow.sh`
```bash
flow.sh
```

5. Add the export PATH statement to your "~/.bashrc" or "~/.zshrc" file

### Usage information

```
Usage: flow (feature_start|feature_finish
            |patch_start|patch_finish
            |release_start|release_finish
            |hotfix_start|hotfix_finish) [branchname]
```

|SubCommand|Description|
|-|-|
|init|Creates the original 3 branches: develop, candidate and main|
|view|Shows the current state of git, within the terminal.|
|fs/feature_start [branchname]|This will create the specified feature branch off of develop|
|ff/feature_finish [branchname]|This will merge the specified feature branch back into develop|
|ps/patch_start [branchname]|    This will create the specified patch branch off of candidate|
|pf/patch_finish/ [branchname]|    This will merge the specified patch branch back into candidate|
|rs/release_start|    This will start a new release by merging the develop branch into candidate. It will tag the place where it diverges from develop.|
|rf/release_finish |    This will tag the release, and merge the candidate branch into BOTH develop and main. The merge to develop will be a --no-ff, and the merge to main will be a fastforward.|
|hs/hotfix_start [branchname]|    This will start a hotfix branch off of the main branch. It will tag the place where it diverges from main.    Since hotfix branches are temporary, they do not have a static name.|
|hf/hotfix_finish [branchname]|    This will tag the hotfix, and merge it into main, candidate, and develop.|
>>>>>>> 04a97cf2d666f91f54060708e3ef5cda5ce64bb0

### Testing

When testing this script, you should create a new git repo in another directory, then call this script via its absolute path. If you don't you may get unpredicatable results in this repo. 
