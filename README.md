# setup

This repo contains a number of scripts, and settings and theme files.

The goal is to easily and reliably recreate environments across different machines, or if something breaks.

## Prerequisites

There should be none. The point of the scripts in this repo is to be self-sufficient and reproducable.

## Overview

### Scripts

Contains a number of different scripts, mainly for configuring environments and installing dependencies etc.

Bash scripts are run with `bash script.sh`.

Powershell scripts are run with `.\script.ps1`

- `configure_ghcr` signs into GitHub Container Registry for use in Docker.
- `configure_gpg` sets a gpg key which can be used to sign commits.
- `az/aks/create` creates an AKS cluster on Azure - idempotent.
- `az/aks/recreate` deletes and creates an AKS cluster on Azure.
- `omp` sets up Oh-My-Posh.
- `retina` installs dependencies required to build the repo and sets up git/gpg.
- `windows` disables a bunch of Windows settings and sets some favourable defaults.
- `zsh` is a WIP, but will set up a zsh environment.

### Settings

Contains some personalized settings for the Windows Terminal.

In the future it would be nice to symlink this file with the settings file, but for now a good old copy paste job is required.

### Themes

Contains my custom theme for `Oh-My-Posh`.

There is also one for `Oh-My-Zsh` which is not actively being used.

### Windows Cursor

Contains `cyan` cursor files because could not find a programmable way to change the colour of the cursor through Powershell. By storing them here at least it is possible to copy them over and set the cursor that way.
