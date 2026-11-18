<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/scorphus/scorphiles@master/logo.png" height="300"/>
</p>

<details>
<summary>$ init</summary>

Install Homebrew:
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Put it on the PATH:
```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Install the GitHub CLI:
```sh
brew install gh
```

Log in to GitHub, choosing SSH so it uploads a new key:
```sh
gh auth login
```

Clone this repo and the private prompts into the workspace:
```sh
mkdir -p ~/workspace && cd ~/workspace
gh repo clone scorphus/scorphiles
gh repo clone scorphus/agent-prompts
```

Set everything up:
```sh
./scorphiles/setup.sh
```

</details>

<details>
<summary>$ gitify  # optional</summary>

If the repos came as zips, turn them into repos in place:
```sh
cd ~/workspace/scorphiles
git init -q -b master
git remote add origin git@github.com:scorphus/scorphiles.git
git fetch -q origin
git reset origin/master
git branch -u origin/master
```

```sh
cd ~/workspace/agent-prompts
git init -q -b main
git remote add origin git@github.com:scorphus/agent-prompts.git
git fetch -q origin
git reset origin/main
git branch -u origin/main
```

</details>
