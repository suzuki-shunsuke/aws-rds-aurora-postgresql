#!/usr/bin/env bash

set -eux
set -o pipefail

git pull --tags
git tag > tags.txt
if ! grep -v -f tags.txt versions.txt; then
  echo "===> No update" >&2
  exit 0
fi

if git diff --exit-code versions.txt; then
  ghcp empty-commit -r "$GITHUB_REPOSITORY" -m "update"
else
  ghcp commit -r "$GITHUB_REPOSITORY" -m "update versions.txt" versions.txt
fi
git checkout -- versions.txt

# push tags
git pull
grep -v -f tags.txt versions.txt | while read -r version; do
  git tag "$version"
  git push origin "$version"
done
