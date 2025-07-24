# setup

This repo contains a number of scripts, theme files etc.

The goal is to easily and reliably recreate environments across different machines, or if something breaks.

You can set up SSH auth for GitHub most easily through the `gh` CLI.

If you want to do it manually - [docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-authentication-to-github#ssh).

```shell
sudo apt install gh

gh auth login

git clone git@github.com:kamilprz/setup.git
```

Switching remote from HTTPS to SSH - [docs](https://docs.github.com/en/get-started/git-basics/managing-remote-repositories#switching-remote-urls-from-https-to-ssh).

## Overview

### Scripts

Contains a number of different scripts, mainly for configuring environments and installing dependencies etc.

#### Linux

```shell
# To set up a new environment from scratch
make new

# To list available options
make help
```

#### Windows

```powershell
.\setup.ps1
```

### Themes

#### Oh-My-Posh

`.config/oh-my-posh/kamp.omp.yaml`

### Settings

Contains some personalized settings for the Windows Terminal.

In the future it would be nice to symlink this file with the settings file, but for now a good old copy paste job is required.

### Windows Cursor

Contains `cyan` cursor files because could not find a programmable way to change the colour of the cursor through Powershell. By storing them here at least it is possible to copy them over and set the cursor that way.
