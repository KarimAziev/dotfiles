# About

Installation script automates the initialization of a new machine on `Ubuntu 22.04`
by installing necessary tools, utilities, and configuring settings.

It supports a wide range of tasks such as initializing git, installing
NVM, Google Chrome, building and compiling Emacs, etc.

# install.sh

> - [About](#about)
> - [Usage](#usage)
> - [Commands](#commands)

# Usage

You can use the convenience script to install the dotfiles on any
machine with a single command. Simply run the following command in your
terminal:

```shell
bash -c "$(wget -qO- https://raw.githubusercontent.com/KarimAziev/dotfiles/main/install.sh)"
```

If you want to clone or download repository manually, remember to make
the script executable (`chmod +x install.sh`) if it isn't already so you
can run it using `./install.sh`.

```shell
./install.sh
```

The script will prompt you before executing each step. If you want to
bypass these prompts, run the script in the non-interactive mode by
passing either `--non-interactive` or `-n` arguments:

```shell
bash -c "$(wget -qO- https://raw.githubusercontent.com/KarimAziev/dotfiles/main/install.sh) --non-interactive"
```

Or if you downloaded repo manully,

```shell
./install.sh --non-interactive
```

You can also specify a subset of [steps](#commands) to run. For
instance, to initialize git and install NVM, use:

```shell
bash -c "$(wget -qO- https://raw.githubusercontent.com/KarimAziev/dotfiles/main/install.sh) init_git init_nvm"
```

Or if you downloaded repo manully,

```shell
./install.sh init_git init_nvm
```

# Commands

Here are some commands that the script can execute:

- `init_git`: Install git and configure the default branch.
- `init_nvm`: Install Node Version Manager if it's not installed.
- `init_google_chrome`: Download and install Google Chrome.
- `init_google_session_dump`: Install Google Session Dump.
- `init_mu4e_deps`: Install dependencies for mu4e.
- `remap_caps`: Remap the Caps Lock key to Control.
- `init_emacs`: Install Emacs if it's not installed.
- `init_emacs_gtk_theme`: Set Emacs as the GTK theme.
- `init_pass_extension`: Install Pass password manager extension.
- `init_pass`: Install Pass password manager.
- `init_gh`: Install GitHub CLI.
- `init_avidemux`: Install avidemux video editing software.
- `init_dconf_editor`: Install dconf Editor.
- `init_flacon`: Install Flacon Audio File Encoder.
- `init_silversearch`: Install the Silver Searcher.

To see all the available commands and options, use:

```shell
bash -c "$(wget -qO- https://raw.githubusercontent.com/KarimAziev/dotfiles/main/install.sh) --help"
```

Or if you downloaded repo manully:

```shell
./install.sh --help
```
