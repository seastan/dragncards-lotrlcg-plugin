#!/bin/bash

# Clone or update the repository
REPO_DIR="/var/www/dragncards.com/dragncards-lotrlcg-plugin/"
MERGE_DIR_JSON="/var/www/dragncards.com/dragncards-lotrlcg-plugin/jsons_merged"
MERGE_DIR_TSV="/var/www/dragncards.com/dragncards-lotrlcg-plugin/tsvs_merged"

# Ensure repo is updated
cd "$REPO_DIR"
git fetch

# Merge JSONs from both branches
mkdir -p "$MERGE_DIR_JSON"
mkdir -p "$MERGE_DIR_TSV"

git checkout main
cp -r jsons/* "$MERGE_DIR_JSON/"
cp -r tsvs/* "$MERGE_DIR_TSV/"

git checkout alep
git fetch
cp -r -n jsons/* "$MERGE_DIR_JSON/"
cp -r -n tsvs/* "$MERGE_DIR_TSV/"

git checkout main
