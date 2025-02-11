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
      <li><a href="#navigate-to-site-packages">
        Navigate to site-packages
      </a></li>
   </ol>

## Introduction

`venvman` is a  `python` virtual environment manager that is written entirely
in POSIX-compliant shell. It requires no installation of third-party software,
other than `pythonX.XX` and `pythonX.XX-venv`. `venvman` facilites the
creation, cloning, activation, and deletion of virtual enviornments and offers
tab-autocompletion for `bash` and `zsh`.

#### Pros

  1) No installation required - `venvman` itself requires no installation, you
  simply source `./src/main.sh`, set two enviornment variables and you are good
  to go.  The only software required is pythonX.XX, pythonX.XX-venv, and a
  POSIX shell binary, such as `bash` or `zsh`. If you often work in shell
  environments where installing software is difficult or outright prohibited,
  then `venvman` is an obvious choice.

  2) Simplicity and hackability – Due to its minimal design, `venvman` is easy
  to modify and being written in shell, it is accessible to pretty much anyone
  with UNIX/LINUX experience.

  5) Small and robust codebase – The `venvman` codebase should take only 10–15
  minutes to read and understand, while still being robust enough to handle the
  vast majority of user needs.

#### Cons
  
  1) It does not support multiple subversions of python, such as `python3.11.0`
  and `python3.11.1`. 


## Installation

#### Installing from `install.sh`
`venvman` uses two enviornment variables with the following default values: 
  1) `VENVMAN_ROOT_DIR=$HOME/.venvman`: where the repo will be cloned to, ie,
  ```
git clone https://github.com/nickeisenberg/venvman.git $VENVMAN_DIR_ROOT/venvman
  ```

  2) `VENVMAN_ENVS_DIR=$HOME/.venvman/envs`: This is where the virtual
  enviornments will be saved to. 

If you are ok with default values of the above variables, then to install run
the following:

```bash
curl -sSL https://raw.githubusercontent.com/nickeisenberg/venvman/master/install.sh -o install.sh 
bash install.sh
```

If you would like to change to values of the above variables, then run

```bash
curl -sSL https://raw.githubusercontent.com/nickeisenberg/venvman/master/install.sh -o install.sh 
VENVMAN_ROOT_DIR=<new_value_1>
VENVMAN_ENVS_DIR=<new_value_2>
bash install.sh $VENVMAN_ROOT_DIR $VENVMAN_ENVS_DIR
```

Then restart your shell and `venvman` will be available.


#### Manual Installation
If you want to manually go through the install steps, then do the following:

```bash
VENVMAN_ROOT_DIR=$HOME/.venvman
mkdir -p $VENVMAN_ROOT_DIR
git clone https://github.com/nickeisenberg/venvman.git "${venvman_root_dir}/venvman"
```

Then add the following to your `bashrc` or `zshrc` etc:
```bash
VENVMAN_ROOT_DIR=$HOME/.venvman
VENVMAN_ENVS_DIR=$HOME/.venvman/envs
source "${VENVMAN_ROOT_DIR}/.venvman/venvman/src/completion/completion.sh"
venvman() {
    unset -f venvman
    source "${VENVMAN_ROOT_DIR}/.venvman/venvman/src/main.sh"
    venvman
}
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
`VENVMAN_ENVS_DIR/X.XX/<venv_name>`, then
use the following:
```bash
venvman make --version X.XX --name <venv_name> 
```
For example,
```bash
venvman make --version 3.10 --name myenv
```
will create an enviornment named `myenv` with `python3.10 -m venv
VENVMAN_ENVS_DIR/X.XX/myenv`, thus saving it to `VENVMAN_ENVS_DIR/3.10/myenv`.

2. Suppose you want to save one-off virtual enviornment to a location other than
`VENVMAN_ENVS_DIR`, then you can specify that directory to save it to with the
`--path` option. For example,
For example,
```bash
venvman make --name myenv --version 3.10 --path <custom_path>
```
will create an enviornment named `myenv` with `python3.10 -m venv
<custom_path>/myenv` and it will save it to `<custom_path>/myenv`.


### Clone a Virtual Enviornment
To clone a virtual enviornment, you do the following:

```bash
venvman clone --version X.XX --parent <parent_venv_name> --clone-to <clone_venv_name>
```
This will create an enviornment named `<clone_venv_name>` that will be localed
at `VENVMAN_ENVS_DIR/X.XX/<clone_venv_name>` that will have the same packages
as `<parent_venv_name>`. Note that this requires that
`VENVMAN_ENVS_DIR/X.XX/<parent_venv_name>` exists and that 
`<parent_venv_name> != <clone_venv_name>`.


### Activate a Virtual Environment
There are a couple options with activating an enviornment.

1. The following will activate the enviornment saved at
   `VENVMAN_ENVS_DIR/X.XX/<venv_name>`
```bash
venvman activate --version X.XX --name <venv_name>
```
On the backend, it runs `source VENVMAN_ENVS_DIR/X.XX/<venv_name>/<path_to_activate>`.

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
specific `python` version, then you can use `venvman list --version X.XX`.

### Delete a Virtual Environment
To delete an enviornment that is saved at `VENVMAN_ENVS_DIR/X.XX/<venv_name>`,
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
`VENVMAN_ENVS_DIR/X.XX/<venv_name>/lib/pythonX.XX/site-packages`.
Moreover, running the following 
```bash
venvman site-packages --package <package_name>
```
will `cd` you into
`VENVMAN_ENVS_DIR/X.XX/<venv_name>/lib/pythonX.XX/site-packages/<package_name>`.

### Help

`venvman --help` will display a help message.
