# Module: gnupg
GNUPGDIR := $(HOME)/.gnupg/

install-gnupg:
	mkdir -p $(GNUPGDIR)
	ln -sfn $(CURDIR)/gpg-agent.conf $(GNUPGDIR)/gpg-agent.conf

clean-gnupg:
	rm -f $(GNUPGDIR)/gpg-agent.conf