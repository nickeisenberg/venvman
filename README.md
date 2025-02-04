# VENV Manager

A simple Virtual Environment manager written in pure Bash to simplify
the creation, activation, listing, and deletion of Python virtual environments.

## Table of Contents
- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)

## Introduction
I am often working on machines where installing software is a pain. I needed a
quick way to manage some python vitural enviornments in a way that required no
installation of external tools like `conda`, `pyenv-virtualenv`, etc. For that
reason I wrote `venvman`. It is written entirely in `bash` and requires no
installation of third-party software, other than `pythonX.XX` and
`pythonX.XX-venv` of course. Because of the simplicity of `venvman`, it is
highly hackable into a version that satisfes the opinion of the user. It is
also simple enough to copy and paste into any online LLM so that the LLM can
guide you through any modifications that you seem fit.


## Installation

```bash
git clone 
cd
mkdir $HOME/.venvman
```

Copy the script into your Bash profile (~/.bashrc or ~/.bash_profile).

Source the profile:

source ~/.bashrc

The venv command will now be available in your shell.


## Features
* Create virtual environments for specific Python versions.

* Activate virtual environments by name and version.

* List all available virtual environments.

* Delete virtual environments safely.

* Navigate to the site-packages directory of installed packages.

* Tab-completion for commands and arguments.


## Usage

The venv command provides multiple subcommands for managing virtual environments.

### Create a Virtual Environment

venv make -n <venv_name> -v <python_version>

Example:

venv make -n myenv -v 3.10

Creates a virtual environment named myenv using Python 3.10 and stores it in ~/.venv/3.10/myenv/.

### Activate a Virtual Environment

venv activate -n <venv_name> -v <python_version>

Example:

venv activate -n myenv -v 3.10

Activates the virtual environment named myenv created with Python 3.10.

### List Available Virtual Environments

venv list

Lists all available virtual environments categorized by Python versions.

To list virtual environments for a specific Python version:

venv list -v <python_version>

Example:

venv list -v 3.10

### Delete a Virtual Environment

venv delete -n <venv_name> -v <python_version>

Example:

venv delete -n myenv -v 3.10

Deletes the virtual environment myenv created with Python 3.10 after confirmation.

### Navigate to site-packages

venv site-packages

Navigates to the site-packages directory of the currently activated virtual environment.

To navigate to a specific package:

venv site-packages --package <package_name>

Example:

venv site-packages --package numpy

Navigates to the installed numpy package directory.

### Help

To display the help message:

venv --help

## Completion

This script includes Bash tab-completion for easier command input. Press Tab to auto-complete commands and arguments.

## Directory Structure

Virtual environments are stored under ~/.venv/<python_version>/<venv_name>/. This ensures multiple Python versions are managed independently.
