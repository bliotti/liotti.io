#!/bin/bash
GIT_SHA=$(git rev-parse --short HEAD)
sed -i "s/git_sha.*/git_sha=\"$GIT_SHA\"/g" ./config.toml