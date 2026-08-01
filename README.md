# About

This repository contains configurations and scripts to automate developer-machine setup on Ubuntu or macOS.

**Table of Contents**

> - [About](#about)
>   - [Ubuntu](#ubuntu)
>     - [Automated Setup with `install.sh`](#automated-setup-with-installsh)
>     - [Configuring Dotfiles with Make](#configuring-dotfiles-with-make)
>     - [Commands](#commands)
>     - [Packages to install](#packages-to-install)
>   - [macOS](#macos)
>     - [Homebrew safety policy](#homebrew-safety-policy)
>     - [macOS package groups](#macos-package-groups)
>     - [Managed files and conflicts](#managed-files-and-conflicts)
>     - [macOS continuous integration](#macos-continuous-integration)

## Ubuntu

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

### Commands

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
- `init_docker`: Install docker.

To see all the available commands and options, use:

```shell
./install.sh --help
```

### Packages to install

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
| direnv            | Unloads and reloads environment variables based on directory-level configuration files |

## macOS

Clone the repository before running the macOS installer. The script uses the Brewfiles and managed configuration files beside it, so it is intentionally not a standalone `curl | bash` installer.

```shell
git clone https://github.com/KarimAziev/dotfiles.git "$HOME/src/dotfiles"
cd "$HOME/src/dotfiles"
./install-macos.sh --dry-run
./install-macos.sh
```

The default `developer` profile installs the core CLI/build environment, Docker Desktop, Google Chrome, Karabiner Elements, latest Node LTS, uv, a Python selected through pyenv, and the GnuPG/password-store stack. Optional application groups are disabled. The installer proceeds without its own confirmation prompt by default; use `--ask` when you want to approve the printed plan interactively.

The `personal` profile additionally enables Emacs master, Dropbox, media tools, CAD tools, local AI tools, desktop applications, and the local AltTab archive. Full Xcode remains opt-in in every profile.

```shell
# Minimal developer setup for someone who uses macOS Keychain and ordinary SSH,
# not GnuPG/pass. Emacs and Dropbox are already disabled in this profile.
./install-macos.sh --profile developer --skip-gpg

# Personal setup, but without Emacs or Dropbox.
./install-macos.sh --profile personal --skip-emacs --skip-dropbox --skip-gpg

# Core setup plus FFmpeg and the mpv CLI/libmpv.
./install-macos.sh --with-media

# Let uv manage Python versions instead of pyenv.
./install-macos.sh --python-manager uv --python-version 3.12

# Print the plan and ask before applying only managed configuration files.
./install-macos.sh --only dotfiles --ask
```

Run `./install-macos.sh --help` for all group, archive, phase, and conflict-handling options.

### Homebrew safety policy

The installer exports the following variables before its first Homebrew invocation:

```shell
HOMEBREW_NO_ASK=1
HOMEBREW_NO_AUTO_UPDATE=1
HOMEBREW_NO_INSTALL_UPGRADE=1
HOMEBREW_NO_INSTALL_CLEANUP=1
HOMEBREW_NO_AUTOREMOVE=1
HOMEBREW_NO_ENV_HINTS=1
HOMEBREW_BUNDLE_NO_UPGRADE=1
```

Package installation uses `brew bundle install --no-upgrade`. The installer never runs `brew cleanup`, `brew autoremove`, or `brew bundle cleanup`. It runs `brew update` only when explicitly invoked with `--brew-update`.

Emacs is intentionally not present in any Brewfile. Its dedicated phase installs `emacs-plus@master` only when missing and otherwise leaves it untouched. Reinstallation requires `--force-emacs-reinstall`.

### macOS package groups

- [Brewfile](Brewfile) contains the mandatory developer core.
- [Brewfile.gnupg](Brewfile.gnupg) contains GnuPG, `pass`, `pass-otp`, `pinentry-mac`, and QR-code support. It is enabled by default in both profiles and can be excluded with `--skip-gpg`.
- [Brewfile.media](Brewfile.media) contains FFmpeg, the mpv formula, and media utilities. The mpv formula does not provide `mpv.app`; supply a known application archive with `--mpv-app-archive PATH` if an app bundle is required.
- [Brewfile.cad](Brewfile.cad) contains OpenSCAD/Bambu Studio and related build tools.
- [Brewfile.ai](Brewfile.ai) contains Ollama and llama.cpp.
- [Brewfile.desktop](Brewfile.desktop) contains optional desktop developer applications.
- [Brewfile.dropbox](Brewfile.dropbox) keeps Dropbox independently skippable.
- [Brewfile.xcode](Brewfile.xcode) installs full Xcode through `mas` only when `--with-xcode` is explicitly used and the App Store is already signed in.

The deprecated `stolendata-mpv` cask is not used. The media profile installs the supported Homebrew formula, which supplies the `mpv` CLI and `libmpv` but no application bundle.

AltTab is not installed from Homebrew. The personal profile expects `$HOME/Dropbox/AltTab-10.4.0.zip`, verifies its pinned SHA-256, and installs the contained app. A different archive can be provided with `--alttab-archive` and `--alttab-sha256`.

### Managed files and conflicts

The installer manages Zsh, NVM default packages, Emacs Plus build configuration, an optional platform-correct GPG agent configuration, and a portable Karabiner baseline. With `--skip-gpg`, it neither installs the GPG/password-store packages nor creates or replaces `~/.gnupg/gpg-agent.conf`. Unknown existing Zsh/GPG files that are in enabled groups are moved to timestamped backups below:

```text
~/.local/state/dotfiles/backups/YYYYMMDD-HHMMSS/
```

Use `--fail-on-conflict` to stop instead of backing up and replacing a managed file.

Karabiner is treated more conservatively because the application rewrites its JSON and personal profiles can be large. A fresh machine receives the repository baseline (Caps Lock to Control). A different existing Karabiner configuration is left untouched unless `--force-karabiner-config` is explicitly supplied; replacement still creates a backup.

Sleepwatcher is installed but is not enabled and no LaunchAgent is created. Karabiner privacy permissions, Docker's first launch, Chrome's default-browser confirmation, and App Store authentication may still require macOS UI interaction.

### macOS continuous integration

The [macOS Installer CI](.github/workflows/macos.yml) workflow validates the installer on Apple Silicon and Intel GitHub-hosted macOS runners. It checks system Bash 3.2 and Zsh syntax, ShellCheck, Karabiner JSON, every Brewfile, command-line error handling, complete isolated-home dry-runs, and the Homebrew no-update/no-upgrade/no-cleanup policy. CI does not perform a real machine bootstrap or apply macOS defaults; its only package mutation is explicitly installing ShellCheck on the disposable runner when the image does not already provide it.

The Ubuntu setup below remains divided into two main parts:

1. **Environment Setup Script (`install.sh`)**: Automates the process of installing necessary software and tools, configuring settings, and performing initial system setups like git initialization, command-line utilities, and development tools installation.
2. **Dotfiles Configuration**: Utilizes Makefiles for modular management of configuration files, allowing for easy application, removal, and updating of dotfiles across the system.
