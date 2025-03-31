#!/bin/bash

# Log into GitHub Container Registry (GHCR) for use in Docker

echo ""
echo "##### Configuring GHCR Credentials #####"
echo "Go to https://github.com/settings/tokens/new and create a token with the following scopes:"
echo "- repo"
echo "- workflows"
echo "- write:packages"
echo "- delete:packages"
echo "- read:org"
echo ""
read -p "Enter your GHCR token: " USER_INPUT
export CR_PAT=$USER_INPUT
echo "##### Running docker login... #####"
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin