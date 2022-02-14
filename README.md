# Threeflow
A git branching model which is based on 3 branches: develop, candidate and main.

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

### Testing

When testing this script, you should create a new git repo in another directory, then call this script via its absolute path. If you don't you may get unpredicatable results in this repo. 
