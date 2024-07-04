#!/usr/bin/env bash

sudo apt update && sudo apt upgrade -y

sudo DEBIAN_FRONTEND=noninteractive apt install -y libmagic-dev jq p7zip-full msitools curl git wget python3.11 python3.11-pip python3.11-setuptools python3.11-build python3.11-wheel build-essential libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev

# # update python pip
# python3 -m pip install --upgrade pip

# # update python basics
# python3 -m pip install --upgrade setuptools wheel build

# This may solve a weird issue:
# python3 -m pip install -U 'pyasn1<0.5.0'
# python3 -m pip install -U pyasn1-modules<0.5.0 --ignore-installed pyasn1-modules

# if autopkg does not exist
if [ ! -f  ../autopkg ] ; then
git clone https://github.com/autopkg/autopkg.git ../autopkg
bash -c "cd ../autopkg && git checkout dev"
fi

# create virtual environment
python3 -m venv ../autopkg/.venv

# install autopkg requirements
./../autopkg/.venv/bin/python3 -m pip install --requirement ../autopkg/gh_actions_requirements.txt

mkdir -p ~/.config/Autopkg

# if config file does not exist, create it:
if [ ! -f  ~/.config/Autopkg/config.json ] ; then
echo {} > ~/.config/Autopkg/config.json
fi

# add required recipe repos for jgstew-recipes
for line in $(cat .autopkg_repos.txt); do python3 ../autopkg/Code/autopkg repo-add $line; done

# install jgstew-recipes requirements:
./../autopkg/.venv/bin/python3 -m pip install --requirement requirements.txt

# test:
./../autopkg/.venv/bin/python3 ../autopkg/Code/autopkg run -v Test-Recipes/AutopkgCore.test.recipe.yaml
./../autopkg/.venv/bin/python3 ../autopkg/Code/autopkg run -v com.github.jgstew.test.AutopkgBuildRecipeListTest

# get autopkg version
./../autopkg/.venv/bin/python3 ../autopkg/Code/autopkg version

# further test: python3 ../autopkg/Code/autopkg run -vv --recipe-list Test-Recipes/Test-Recipes.recipelist.txt
