# Threeflow
A git branching model which is based on 3 branches: develop, candidate and main.

The original inspiration for this was the cactus model, and [this article](https://www.nomachetejuggling.com/2017/04/09/a-different-branching-strategy/)

## Installation

If you are on Linux/MacOS, you can do the following:

1. Clone the git repo 
```bash  
git clone git@github.com:patbeagan1/Threeflow.git
```

2. Add the repo directory to your path
```bash
cd Threeflow && export PATH="$PATH:`pwd`"
```

3. Rehash (so the script will be discovered, and you can use it right away)
```
hash -r
```

4. Try out `flow.sh`
```bash
flow.sh
```

5. Add the `export PATH="$PATH:XYZ"` statement to your `~/.bashrc` or `~/.zshrc` file. Make sure that you use the **absolute path name** for the Threeflow directory. To check and see if you did it correctly, open up a new terminal and type `echo $PATH`. You should see the Threeflow directory at the end.
6. Update as needed by performing `git pull` in your clone 

## Usage information

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
|feature_start|This will create the specified feature branch off of develop|
|feature_finish|This will merge the specified feature branch back into develop|
|patch_start|    This will create the specified patch branch off of candidate|
|patch_finish|    This will merge the specified patch branch back into candidate|
|release_start|    This will start a new release by merging the develop branch into candidate. It will tag the place where it diverges from develop.|
|release_finish |    This will tag the release, and merge the candidate branch into BOTH develop and main. The merge to develop will be a --no-ff, and the merge to main will be a fastforward.|
|hotfix_start|    This will start a hotfix branch off of the main branch. It will tag the place where it diverges from main.    Since hotfix branches are temporary, they do not have a static name.|
|hotfix_finish|    This will tag the hotfix, and merge it into main, candidate, and develop.|

## Testing

When testing this script, you should create a new git repo in another directory, then call this script via its absolute path. If you don't you may get unpredictable results in this repo. 
