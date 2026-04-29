# setup

This repo contains a number of scripts, theme files etc.

The goal is to easily and reliably recreate environments across different machines, or if something breaks.

You can set up SSH auth for GitHub most easily through the `gh` CLI.

If you want to do it manually - [docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-authentication-to-github#ssh).

```shell
brew install gh #mac
sudo apt install gh #linux

gh auth login

git clone git@github.com:kamilprz/setup.git
```

Switching remote from HTTPS to SSH - [docs](https://docs.github.com/en/get-started/git-basics/managing-remote-repositories#switching-remote-urls-from-https-to-ssh).

## Overview

### Scripts

Contains a number of different scripts, mainly for configuring environments and installing dependencies etc.

#### Mac / Linux

```shell
make new
```

#### Windows

```powershell
.\setup.ps1
```

### Themes

#### Oh-My-Posh

`.config/oh-my-posh/kamp.omp.yaml`