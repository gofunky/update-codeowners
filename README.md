# update code owners action
A [GitHub Action](https://github.com/features/actions) that uses [git-fame](https://pypi.org/project/git-fame) to generate and update GitHub's CODEOWNERS file based on the git fame of files.

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

## Example

This is a typical example for a pull request workflow.
It should suffice to trigger it on few event types of pull request event only.
That also gives the author the possibility to remove themselves from the owners list optionally.

```yaml
name: codeowners

on:
  pull_request_target:
    branches:
      - master
    types:
      - ready_for_review
      - review_request_removed

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
    - name: checkout code
      uses: actions/checkout@v2.3.2
      with:
        repository: ${{ github.event.pull_request.head.repo.full_name }}
        ref: ${{ github.head_ref }}
    - name: update code owners
      uses: gofunky/update-codeowners@master
      with:
        distribution: 25
    - name: commit changed files
      id: committed
      uses: stefanzweifel/git-auto-commit-action@v4.5.1
      with:
        commit_message: 'chore(meta): update code owners'
        branch: ${{ github.head_ref }}
        file_pattern: 'CODEOWNERS'
    - uses: christianvuerings/add-labels@v1.1
      if: ${{ steps.committed.outputs.changes_detected == 'true' }}
      with:
        labels: |
          owned
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
