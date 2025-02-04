## Table of Contents
- [Introduction](#introduction)
- [Installation](#installation)
- [Setup](#setup)
- [Usage](#usage)
  - [Make a Virtual Environment](#make-a-virtual-environment)
  - [Activate a Virtual Environment](#activate-a-virtual-environment)
  - [List Available Virtual Enviornments](#list-available-virtual-environments)
  - [Delete a Virtual Environment](#delete-a-virtual-environment)
  - [Navigate to site-packages](#navigate-to-site-packages)


## Introduction

`venvman` is a minimal virtual environment manager that supports the creating,
activation, and deletion of `python` virtual enviornments as well as
command-line tab-autocompletion. It and is written entirely `bash` and requires
no installation of third-party software, other than `pythonX.XX` and
`pythonX.XX-venv`. Because its simplicity, `venvman` is easily hackable.

## Installation
To install `venvman`, simply
```bash
git clone https://github.com/nickeisenberg/venvman.git
source venvman/src/venvman.sh
```
or to make this persistent, add the following to your `bashrc` or `bash_profile`
```bash
source <path_to_venvman>/src/venvman.sh
```
`venvman` will now be available to use.

## Setup

`venvman` will save all `pythonX.XX` virtual enviornments to
`$HOME/.venvman/X.XX`. For example, `venvman make --version 3.11 --name base`
will save this enviornment to `$HOME/.venvman/3.11/base`. Moreover, if
`$HOME/.venvman/X.XX` does not exist then `venvman` will create this directory.
If you do not want `$HOME/.venvman` as the location to save the virtual
enviornments, then overwrite the variable `VENVMAN_SAVE_DIR` in your `bashrc`
or `bash_profile` after sourcing `<path_to_venvman>/src/venvman.sh`.

## Usage

`venvman` does not offer much, but from my experience it seems to get the job
done. The following are the available commands of `venvman`.
```bash
venvman make 
venvman activate
venvman delete 
venvman list
venvman site-packages
venvman --help
```
Each command of `venvman` has a `--help` option as well that gives the basic
usage along with an example or two. For example,
```bash
>>> venvman make --help
Usage:
  venvman make [options]

Options:
  -n, --name <venv_name>                       : Specify the name of the virtual environment to create.
  -v, --version <python_version>               : Specify the Python version to use for the virtual environment.
  -p, --path <venv_path>                       : Manually specify the directory where the virtual environment should be created.
  -h, --help                                   : Display this help message.

Examples:
  venvman make -n project_env -v 3.10             : Create a virtual environment named 'project_env' using Python 3.10.
  venvman make -n myenv -v 3.9 -p /custom/path    : Create 'myenv' using Python 3.9 at '/custom/path'.
```

### Make a Virtual Environment
There are a couple options for making a virtual enviornment.

1. If you want to the virtual enviornment to save to `VENVMAN_SAVE_DIR/X.XX`, then
use the following:
```bash
venvman make --name <venv_name> --version <python_version>
```
For example,
```bash
venvman make --name myenv --version 3.10
```
will create an enviornment named `myenv` with `python3.10 -m venv
VENVMAN_SAVE_DIR/myenv`, thus saving it to `VENVMAN_SAVE_DIR/3.10/myenv`.

2. Suppose you want to save one-off virtual enviornment to a location other than
`VENVMAN_SAVE_DIR`, then you can specify that directory to save it to with the
`--path` option. For example,
For example,
```bash
venvman make --name myenv --version 3.10 --path <custom_path>
```
will create an enviornment named `myenv` with `python3.10 -m venv
<custom_path>/myenv` and it will save it to `<custom_path>/myenv`.


### Activate a Virtual Environment
There are a couple options with activating an enviornment.

1. The following will activate the enviornment saved at
   `VENVMAN_SAVE_DIR/X.XX/<venv_name>`
```bash
venvman activate --version X.XX --name <venv_name>
```
On the backend, it runs `source VENVMAN_SAVE_DIR/X.XX/<venv_name>/bin/activate`.

2. Now suppose we want to quickly activate an enviornment that is saved in a location
other than `VENVMAN_SAVE_DIR`. For example, maybe we have an enviornment saved
in a projects root directoy such as `<path_to_project>/.venv`. We can quickly source
with enviornment with 
```bash
venvman activate --path <path_to_project>/.venv
```
and if we are already `cd` into the project's root, then
```bash
venvman activate --path .venv
```
will activate `.venv`. Doing this is not much easier than straight up running
`source .venv/bin/activate` but the option is there if you want it.

### List Available Virtual Environments
To list all the enviornments saved in `VENVMAN_SAVE_DIR`, use `venvman list`.
If you want to list all of the saved enviornments in `VENVMAN_SAVE_DIR` for a 
specific `python` version, then you can use `venvman list --version X.XX`.

### Delete a Virtual Environment
To delete an enviornment that is saved at `VENVMAN_SAVE_DIR/X.XX/<venv_name>`,
do the following:
```bash
venvman delete --version X.XX --name <venv_name> 
```

### Navigate to site-packages
Some may find this feature useful. Suppose a virtual enviornment is activated.
Then running 
```bash
venvman site-packages
``` 
will `cd` you into the directory that contains 
this vitrual enviornment's site-packages, for example 
`VENVMAN_SAVE_DIR/X.XX/<venv_name>/lib/pythonX.XX/site-packages`.
Moreover, running the following 
```bash
venvman site-packages --package <package_name>
```
will `cd` you into
`VENVMAN_SAVE_DIR/X.XX/<venv_name>/lib/pythonX.XX/site-packages/<package_name>`.

### Help

`venvman --help` will display a help message.
