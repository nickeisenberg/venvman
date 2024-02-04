An easy way to store and manage python virtual enviornments. Inside of `./venv`
are `bash` scripts titled `venv3x.sh` where `3x` is the version of python you
want to use.

# Instructions
The following uses `./venv/venv310.sh` for reference but the same instructions
apply for any of the versions of python.

1. Place `./venv/venv310.sh` anywhere on your computer and source 
   it from your ~/.bashrc`.

2. Create the folder `~/.venv310`. If by coincidence you already are using a
   folder with that same name, then edit the top line of `./venv/venv310.sh`
   that says `VENV_DIR="$HOME/.venv310` and point the `VENV_DIR` elsewhere.
   This is where all the virtual enviornments will be saved.

# Functionality

The following are the options for `venv3x`.

1. Create a new virtual environment.
   ```bash
   -m, --make <venv_name>"
   ```

2. Activate the specified virtual environment.
   ```bash
   -a, --activate <venv_name>
   ```

3. Deactivate the currently active virtual environment.
   ```bash
   -da, --deactivate
   ```

4. List all available virtual environments in `VENV_DIR`.
   ```bash
   -ls, --list-all-environments
   ```

5. Delete the specified venv.
   ```bash
   -del, --delete-venv
   ```

6. If a `[package]` is entered, then you will be navigated to that 
   package within the site-package directory. If `[package]` is not specified,
   then you will be navigated to the site-packages folder.
   ```bash
   -sp, --site-packages [package]:
   ```

7. Display this help message.
   ```bash
   -h, --help
   ```
