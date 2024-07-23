# About

This repository contains configurations and scripts to automate the setup of a new machine or environment on `Ubuntu 22.04`. It includes dotfiles for bash, mpv, viewnior, and several other configurations, alongside an installation script for automating the installation of necessary tools, applications, and utilities.

The setup is divided into two main parts:

1. **Environment Setup Script (`install.sh`)**: Automates the process of installing necessary software and tools, configuring settings, and performing initial system setups like git initialization, command-line utilities, and development tools installation.
2. **Dotfiles Configuration**: Utilizes Makefiles for modular management of configuration files, allowing for easy application, removal, and updating of dotfiles across the system.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->

**Table of Contents**

> - [About](#about)
>   - [Usage](#usage)
>     - [Automated Setup with `install.sh`](#automated-setup-with-installsh)
>     - [Configuring Dotfiles with Make](#configuring-dotfiles-with-make)
> - [Commands](#commands)
> - [Packages to install](#packages-to-install)

<!-- markdown-toc end -->

## Usage

### Automated Setup with `install.sh`

The `install.sh` script simplifies the installation process, managing tasks like tool and utility installations. It supports both interactive and non-interactive modes, and you can execute specific configuration steps selectively.

To start the setup, you can directly execute the script using the following command:

```shell
bash -c "$(wget -qO- https://raw.githubusercontent.com/KarimAziev/dotfiles/main/install.sh)"
```

For a manually downloaded repository, ensure `install.sh` is executable:

```shell
chmod +x install.sh
./install.sh
```

To run in non-interactive mode, bypassing all prompts:

```shell
./install.sh --non-interactive
```

To execute specific steps only, such as `init_git` and `init_nvm`:

```shell
./install.sh init_git init_nvm
```

### Configuring Dotfiles with Make

After setting up the environment, configure your dotfiles using the root `Makefile` to symlink configurations for bash, mpv, viewnior, etc., into their respective locations:

```shell
make install
```

This command links configuration files like `.bashrc`, `mpv.conf`, and others to your `$HOME` directory, ensuring your settings are applied. You can manage configurations individually by specifying the module name, for example:

```shell
make install-bash
make install-mpv
```

To clean up (remove) the configurations, use:

```shell
make clean
```

Or for a specific module:

```shell
make clean-bash
```

# Commands

Here are some commands that the script can execute:

- `init_git`: Install git and configure the default branch.
- `init_pkgs`: Install necessary packages. See [below](#packages-to-install).
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
- `init_rust`: Install the Rust toolchain.
- `install_emacs_lsp_booster`: Install [Emacs LSP performance booster](https://github.com/blahgeek/emacs-lsp-booster).

To see all the available commands and options, use:

```shell
./install.sh --help
```

# Packages to install

The following packages will be installed by the `init_pkgs` step:

| Package           | Description                                                                            |
| ----------------- | -------------------------------------------------------------------------------------- |
| tmux              | Terminal multiplexer                                                                   |
| rlwrap            | Readline feature command line wrapper                                                  |
| silversearcher-ag | Very fast grep-like program, alternative to ack-grep                                   |
| pandoc            | General markup converter                                                               |
| xclip             | Command line interface to X selections                                                 |
| jq                | Lightweight and flexible command-line JSON processor                                   |
| fd-find           | Simple, fast and user-friendly alternative to find                                     |
| viewnior          | Simple, fast and elegant image viewer                                                  |
| vlc               | Multimedia player and streamer                                                         |
| yt-dlp            | Downloader of videos from YouTube and other sites                                      |
| hunspell          | Spell checker and morphological analyzer (program)                                     |
| w3m               | WWW browsable pager with excellent tables/frames support                               |
| mpv               | Video player based on MPlayer/mplayer2                                                 |
| cmake             | Cross-platform, open-source make system                                                |
| libtool           | Generic library support script                                                         |
| libtool-bin       | Generic library support script (libtool binary)                                        |
| curl              | Command line tool for transferring data with URL syntax                                |
| wget              | Retrieves files from the web                                                           |
| net-tools         | NET-3 networking toolkit                                                               |
| ditaa             | Convert ASCII diagrams into proper bitmap graphics                                     |
| indent            | C language source code formatting program                                              |
| smartmontools     | Control and monitor storage systems using S.M.A.R.T.                                   |
| htop              | Interactive processes viewer                                                           |
| command-not-found | Suggest installation of packages in interactive bash sessions                          |
| nmap              | The Network Mapper                                                                     |
| fonts-noto        | Metapackage to pull in all Noto fonts                                                  |
| fonts-arphic-ukai | "AR PL UKai" Chinese Unicode TrueType font collection Kaiti style                      |
| sysstat           | System performance tools for Linux                                                     |
| tree              | Displays an indented directory tree, in color                                          |
| synapse           | Semantic file launcher                                                                 |
| bmon              | Portable bandwidth monitor and rate estimator                                          |
| clangd            | Language server that provides IDE-like features to editors                             |
| bear              | Generate compilation database for Clang tooling                                        |
| tlp               | Optimize laptop battery life                                                           |
| gh                | GitHub CLI, GitHub’s official command line tool                                        |
| pass              | Lightweight directory-based password manager                                           |
| dconf-editor      | Simple configuration storage system - graphical editor                                 |
| ffmpeg            | Multimedia framework to decode, encode, transcode, mux, demux, stream, filter and play |
| zip               | A compression and file packaging utility                                               |
| make              | Build utility for managing and executing build processes                               |
