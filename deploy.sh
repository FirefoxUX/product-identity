#!/bin/bash
set -e # exit with nonzero exit code if anything fails

# clear the dist directory
rm -rf dist || exit 0;

# get the existing gh-pages history, but clean out the files.
git clone --quiet --branch=gh-pages https://bwinton:${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git dist > /dev/null
cd dist
rm -rf *
cd ..

# run our compile script, discussed above
npm run build
echo "Ran build."

# inside the gh-pages repo we'll pretend to be a new user
cd dist
git config user.name "Travis CI"
git config user.email "firefox-ux-team@mozilla.com"

ls -al
echo "$(git status --porcelain)"
echo "${TRAVIS_PULL_REQUEST}"

if [ -n "$(git status --porcelain)" -a "${TRAVIS_PULL_REQUEST}" == "false" ]; then
  git add -Af .
  echo "Git adding ${TRAVIS_COMMIT_RANGE}"
  git commit -m "Deploy ${TRAVIS_COMMIT_RANGE} to GitHub Pages."

  # Force push from the current repo's master branch to the remote
  # repo's gh-pages branch. (All previous history on the gh-pages branch
  # will be lost, since we are overwriting it.) We redirect any output to
  # /dev/null to hide any sensitive credential data that might otherwise be exposed.
  git push --force --quiet "https://bwinton:${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" gh-pages
  echo "Pushing to ${TRAVIS_REPO_SLUG}"
fi
