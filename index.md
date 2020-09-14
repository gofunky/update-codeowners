---
title: Overview
---
# update code owners action

[![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/gofunky/update-codeowners/build/master?style=for-the-badge)](https://github.com/gofunky/update-codeowners/actions)
[![Renovate Status](https://img.shields.io/badge/renovate-enabled-green?style=for-the-badge&logo=renovatebot&color=1a1f6c)](https://app.renovatebot.com/dashboard#github/gofunky/update-codeowners)
[![CodeFactor](https://www.codefactor.io/repository/github/gofunky/update-codeowners/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/gofunky/update-codeowners)
[![GitHub License](https://img.shields.io/github/license/gofunky/update-codeowners.svg?style=for-the-badge)](https://github.com/gofunky/update-codeowners/blob/master/LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/gofunky/update-codeowners.svg?style=for-the-badge&color=9cf)](https://github.com/gofunky/update-codeowners/commits/master)

This is a [GitHub Action](https://github.com/features/actions) that uses [git-fame](https://pypi.org/project/git-fame) to generate and update GitHub's CODEOWNERS file based on the git fame of files.

## What does it do?

GitHub's [CODEOWNERS](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners)
feature doesn't provide any method for keeping the code owners list updated automatically.
This action solves this by determining code owners based on the git fame of each file.
Authors don't have to be asked for their addition based on subjective criteria anymore.

## Inputs

### distribution

The distribution input defines the minimum percentage of code lines that are required for a contributor to being 
considered a code owner.
The default uses 20% of ownership. Set it to any integer without the percent character to override the default.

### path

The path defines the path to the CODEOWNERS file.
The default uses the path to the `.github` directory.

### granular

By default, this action checks all files in the root, but groups recursive files into their parent directories.
Set this input to any non-zero value (e.g. `true`) to enable full coverage of all recursive files.

## Example

This is a typical example for a pull request workflow.
It should suffice to trigger it on few event types of pull request events only.
That also gives the author the possibility to remove themselves from the owners list optionally.
Make sure to use `fetch-depth: 0` because otherwise, no git fame will be detected due to the lack of history.

<!-- add-file: ./.github/workflows/example.yml -->
``` yml 
name: codeowners

on:
  pull_request_target:
    branches:
      - master
    types:
      - ready_for_review
      - review_request_removed
      - reopened
      - labeled

jobs:
  update:
    runs-on: ubuntu-latest
    # only apply on unmerged pull requests
    if: github.event.pull_request.merged_by == ''
    steps:
    - name: checkout code
      uses: actions/checkout@v2.3.2
      with:
        # this only makes sure that forks are built as well
        repository: ${{ github.event.pull_request.head.repo.full_name }}
        ref: ${{ github.head_ref }}
        # the fetch depth 0 (=all) is important
        fetch-depth: 0
        # the token is necessary for checks to rerun after auto commit
        token: ${{ secrets.PAT }}
    - name: update code owners
      uses: gofunky/update-codeowners@v0.2.0
      with:
        distribution: 25
    - name: commit changed files
      id: committed
      uses: stefanzweifel/git-auto-commit-action@v4.5.1
      with:
        commit_message: 'chore(meta): update code owners'
        file_pattern: .github/CODEOWNERS
    - uses: christianvuerings/add-labels@v1.1
      if: ${{ steps.committed.outputs.changes_detected == 'true' }}
      with:
        labels: owned
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

```
