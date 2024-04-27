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
passing either `--non-interactive` or `-y` arguments:

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
- `init_pkgs`: Install necessary packages:
  | Package | Description |
  | ----------------- | ----------------------------------------------------------------- |
  | dconf-editor | Simple configuration storage system - graphical editor |
  | pass | Lightweight directory-based password manager |
  | gh | GitHub CLI, GitHub’s official command line tool |
  | tlp | Optimize laptop battery life |
  | bear | Generate compilation database for Clang tooling |
  | clangd | Language server that provides IDE-like features to editors |
  | bmon | Portable bandwidth monitor and rate estimator |
  | synapse | Semantic file launcher |
  | tree | Displays an indented directory tree, in color |
  | sysstat | System performance tools for Linux |
  | fonts-arphic-ukai | "AR PL UKai" Chinese Unicode TrueType font collection Kaiti style |
  | fonts-noto | metapackage to pull in all Noto fonts |
  | nmap | The Network Mapper |
  | command-not-found | Suggest installation of packages in interactive bash sessions |
  | htop | interactive processes viewer |
  | smartmontools | Control and monitor storage systems using S.M.A.R.T. |
  | indent | C language source code formatting program |
  | ditaa | convert ASCII diagrams into proper bitmap graphics |
  | net-tools | NET-3 networking toolkit |
  | wget | Retrieves files from the web |
  | curl | Command line tool for transferring data with URL syntax |
  | libtool-bin | Generic library support script (libtool binary) |
  | libtool | Generic library support script |
  | cmake | Cross-platform, open-source make system |
  | mpv | Video player based on MPlayer/mplayer2 |
  | w3m | WWW browsable pager with excellent tables/frames support |
  | hunspell | Spell checker and morphological analyzer (program) |
  | youtube-dl | Downloader of videos from YouTube and other sites |
  | vlc | Multimedia player and streamer |
  | viewnior | Simple, fast and elegant image viewer |
  | fd-find | Simple, fast and user-friendly alternative to find |
  | jq | Lightweight and flexible command-line JSON processor |
  | xclip | Command line interface to X selections |
  | pandoc | General markup converter |
  | silversearcher-ag | Very fast grep-like program, alternative to ack-grep |
  | rlwrap | Readline feature command line wrapper |
  | tmux | Terminal multiplexer |

- `init_nvm`: Install Node Version Manager if it's not installed.
- `init_pyenv`: Install Python Version Manager if it's not installed.
- `init_sdkman`: Install Java Version Manager if it's not installed.
- `init_google_chrome`: Download and install Google Chrome.
- `init_google_session_dump`: Install Google Session Dump.
- `init_mu4e_deps`: Install dependencies for mu4e.
- `remap_caps`: Remap the Caps Lock key to Control.
- `init_emacs`: Compile and install Emacs if it's not installed using this [script](https://github.com/KarimAziev/build-emacs).
- `init_emacs_gtk_theme`: Set Emacs as the GTK theme.
- `init_pass_extension`: Install Pass password manager extension.
- `init_avidemux`: Install avidemux video editing software.
- `init_flacon`: Install Flacon Audio File Encoder.
- `init_ghcup`: Install GHCup, the Haskell toolchain installer.
- `ensure_export_path`: Ensure the export PATH commands are moved to the end of `.bashrc`.

To see all the available commands and options, use:

```shell
./install.sh --help
```
