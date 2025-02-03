# VENV Manager

A simple Virtual Environment (VENV) manager written in pure Bash to simplify the creation, activation, listing, and deletion of Python virtual environments.

## Features
* Create virtual environments for specific Python versions.

* Activate virtual environments by name and version.

* List all available virtual environments.

* Delete virtual environments safely.

* Navigate to the site-packages directory of installed packages.

* Tab-completion for commands and arguments.

## Installation

Copy the script into your Bash profile (~/.bashrc or ~/.bash_profile).

Source the profile:

source ~/.bashrc

The venv command will now be available in your shell.

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
