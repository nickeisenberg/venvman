## Table of Contents
1. [Introduction](#introduction)
2. [Installation](#installation)
   <ol>
      <li><a href="#installing-from-install.sh">
        Installing from install.sh
     </a></li>
      <li><a href="#manual-installation">
        Manual installation
      </a></li>
    </ol>
4. [Usage](#usage)
   <ol>
      <li><a href="#make-a-virtual-environment">
        Make a virtual environment
      </a></li>
      <li><a href="#clone-a-virtual-enviornment">
        Clone a existing enviornment
      </a></li>
      <li><a href="#activate-a-virtual-environment">
        Activate a virtual environment
      </a></li>
      <li><a href="#list-available-virtual-environments">
        List available virtual enviornments
      </a></li>
      <li><a href="#delete-a-virtual-environment">
        Delete a virtual environment
      </a></li>
      <li><a href="#update-venvman">
        Update `venvman`
      </a></li>
      <li><a href="#navigate-to-site-packages">
        Navigate to site-packages
      </a></li>
   </ol>

## Introduction

**`venvman`** is a `python` version and virtual environment manager written
entirely in shell. It acts as a lightweight wrapper around `python -m venv` and
the [**CPython**](https://github.com/python/cpython) GitHub repository.  

To use `venvman` for virtual environment management, all you need is an
installed version of `python` along with its `venv` module.
For version management, you must have `make` and either
`gcc` or `clang` installed. This allows `venvman` to build and install
any specific Python version that isn’t already available on your system using
the [**CPython**](https://github.com/python/cpython) source repository.

#### Pros

  1) Tab-autocompletion for `bash` and `zsh`.

  2) No installation required - `venvman` itself requires no installation, you
  simply source `./src/main.sh`, set one enviornment variable and you are good
  to go.

  3) Simplicity and hackability – Due to its minimal design, `venvman` is easy
  to modify and being written in shell, it is accessible to pretty much anyone
  with UNIX/LINUX experience.

  4) Small and robust codebase – The `venvman` codebase is pretty small and
  would not take long to read and understand, while still being robust enough
  to handle the vast majority of user needs.

## Installation

#### Installing from `install.sh`
`venvman` requires that `VENVMAN_ROOT_DIR` be set as a enviornment variable. By
default, this variable will be set as `VENVMAN_ROOT_DIR="${HOME}/.venvman"`. If you
are ok with this, then to install run the following:

```bash
curl -sSL https://raw.githubusercontent.com/nickeisenberg/venvman/master/install.sh -o install.sh 
sh install.sh
```

Moreover, upon installation the following enviornment variables will be set
for convience:

  1) `VENVMAN_ENVS_DIR="${VENVMAN_ROOT_DIR}/envs"`, which is the virtual
  enviornments will be saved.
  2) `VENVMAN_PYTHON_BUILDS_DIR="${VENVMAN_ROOT_DIR}/builds"`, which is where
  versions of python built with `venvman` will be saved.

If you would like install to a location other than `"${HOME}/.venvman"`, then run

```bash
curl -sSL https://raw.githubusercontent.com/nickeisenberg/venvman/master/install.sh -o install.sh 
VENVMAN_ROOT_DIR="<location to install venvman>"
sh install.sh --prefix $VENVMAN_ROOT_DIR
```

Then restart your shell and `venvman` will be available.


#### Manual Installation
If you want to manually go through the install steps instead of blindly running
`install.sh`, then do the following:

```bash
VENVMAN_ROOT_DIR=$HOME/.venvman
mkdir -p $VENVMAN_ROOT_DIR
git clone https://github.com/nickeisenberg/venvman.git "${VENVMAN_ROOT_DIR}/venvman"
```

Then add the following to your shell's `rc` file:
```bash
source "${VENVMAN_ROOT_DIR}/.venvman/venvman/src/main.sh"
```

## Usage
The following are the available commands of `venvman`.
```bash
venvman make 
venvman clone 
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

1. If you want to the virtual enviornment to save to 
`$VENVMAN_ENVS_DIR/<version>/<venv_name>` , then use the following:

```bash
venvman make --version <version> --name <venv_name> 
```

For example,
```bash
venvman make --version 3.10 --name myenv
```

will create an enviornment named `myenv` with `python3.10 -m venv
VENVMAN_ENVS_DIR/3.10/myenv`.

2. Suppose you want to save one-off virtual enviornment to a location other than
`VENVMAN_ENVS_DIR`, then you can specify that directory to save it to with the
`--path` option. For example,
For example,
```bash
venvman make --name myenv --version 3.10 --path <custom_path>
```
will create an enviornment named `myenv` with `python3.10 -m venv
<custom_path>/myenv` and it will save it to `<custom_path>/myenv`.

#### A note about `--version`
`venvman` will first look to your system in order to find the binary for the
specified version by using `$(which python<version>)`. If a binary cannot be
found using this method, it will then search for it in
`VENVMAN_PYTHON_BUILDS_DIR`. Lastly, if it cannot be found there, then it will
build the specifed version using the
[**CPython**](https://github.com/python/cpython) repo and will save the
corresponding build in `VENVMAN_PYTHON_BUILDS_DIR`.

There are two conventions here to keep in mind:
  1) If the version is of form `MAJOR.MINOR` (ie. `3.11`) and the corresponding
  binary is nowhere to be found, and thus must be built using the
  [**CPython**](https://github.com/python/cpython) repo, then it will use the
  latest patch for this `MAJOR.MINOR` that can found on the
  [**CPython**](https://github.com/python/cpython) repo which corresponds to
  the `MAJOR.MINOR` branch.

  2) If the version is of form `MAJOR.MINOR.PATCH` (ie. `3.11.3`) and the
  corresponding binary is nowhere to be found, and thus must be built using the
  [**CPython**](https://github.com/python/cpython) repo, then `venvman` will
  checkout the corresponding tag of
  [**CPython**](https://github.com/python/cpython) and build this version.

### Clone a Virtual Enviornment
To clone a virtual enviornment, you do the following:

```bash
venvman clone --version <version> --parent <parent_venv_name> --clone-to <clone_venv_name>
```
This will create an enviornment named `<clone_venv_name>` that will be localed
at `VENVMAN_ENVS_DIR/<version>/<clone_venv_name>` that will have the same packages
as `<parent_venv_name>`. Note that this requires that
`VENVMAN_ENVS_DIR/<version>/<parent_venv_name>` exists and that 
`<parent_venv_name> != <clone_venv_name>`.


### Activate a Virtual Environment
There are a couple options with activating an enviornment.

1. The following will activate the enviornment saved at
   `VENVMAN_ENVS_DIR/<version>/<venv_name>`
```bash
venvman activate --version <version> --name <venv_name>
```
On the backend, it runs `source VENVMAN_ENVS_DIR/<version>/<venv_name>/<path_to_activate>`.

2. Now suppose we want to quickly activate an enviornment that is saved in a location
other than `VENVMAN_ENVS_DIR`. For example, maybe we have an enviornment saved
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
`source .venv/<path_to_activate>` but the option is there if you want it.

### List Available Virtual Environments
To list all the enviornments saved in `VENVMAN_ENVS_DIR`, use `venvman list`.
If you want to list all of the saved enviornments in `VENVMAN_ENVS_DIR` for a 
specific `python` version, then you can use `venvman list --version <version>`.

### Delete a Virtual Environment
To delete an enviornment that is saved at `VENVMAN_ENVS_DIR/<version>/<venv_name>`,
do the following:
```bash
venvman delete --version <version> --name <venv_name> 
```

### Update `venvman`
To update `venvman`, just run `venvman update`. This will run 
`git pull origin master` inside `VENVMAN_SRC_DIR`.

### Navigate to site-packages
Some may find this feature useful. Suppose a virtual enviornment is activated.
Then running 
```bash
venvman site-packages
``` 
will `cd` you into the directory that contains 
this vitrual enviornment's site-packages, for example 
`VENVMAN_ENVS_DIR/<version>/<venv_name>/lib/python<version>/site-packages`.
Moreover, running the following 
```bash
venvman site-packages --package <package_name>
```
will `cd` you into
`VENVMAN_ENVS_DIR/<version>/<venv_name>/lib/python<version>/site-packages/<package_name>`.

### Help

`venvman --help` will display a help message.
