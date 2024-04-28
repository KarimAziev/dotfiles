# Module: bash
BASH_DIR := $(HOME)

install-bash:
	ln -sfn $(CURDIR)/.bash_aliases $(BASH_DIR)/.bash_aliases
	ln -sfn $(CURDIR)/.bash_profile $(BASH_DIR)/.bash_profile
	ln -sfn $(CURDIR)/.bashrc $(BASH_DIR)/.bashrc

clean-bash:
	rm -f $(BASH_DIR)/.bash_aliases
	rm -f $(BASH_DIR)/.bash_profile
	rm -f $(BASH_DIR)/.bashrc