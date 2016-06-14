#!/bin/bash

set -e

# Configuration
DEPLOY_BRANCH=master

# Preconditions check
if [ ${TRAVIS_PULL_REQUEST} != false -o ${TRAVIS_BRANCH} != ${DEPLOY_BRANCH} ]; then
    echo "Skipping deploy..."
    exit 0
fi

# Repo setup
git config user.name "Cobalt Site Deployer"
git config user.email "cobalt@kstep.me"

# Cobalt setup
export PATH="$PATH:/home/travis/.cargo/bin"
cargo install --git https://github.com/kstep/cobalt.rs --branch liquid-date

# Cobalt build
cobalt build --trace
git add . && git commit -m "cobalt site import"

# Deploy key setup
ENC_KEY_VAR="encrypted_${ENC_LABEL}_key"
ENC_IV_VAR="encrypted_${ENC_LABEL}_iv"

eval $(ssh-agent -s)
openssl aes-256-cbc -K ${!ENC_KEY_VAR} -iv ${!ENC_IV_VAR} -in _deploy/deploy.key.enc -d | ssh-add -

# Push
git push git@github.com:${TRAVIS_REPO_SLUG} ${DEPLOY_BRANCH}

