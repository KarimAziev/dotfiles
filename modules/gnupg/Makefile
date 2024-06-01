# Module: gnupg
# Use GNUPGHOME if set, otherwise default to $(HOME)/.gnupg/
GNUPGDIR := $(if $(GNUPGHOME),$(GNUPGHOME),$(HOME)/.gnupg/)

install-gnupg:
	mkdir -p $(GNUPGDIR)
	chmod 700 $(GNUPGDIR)
	ln -sfn $(CURDIR)/gpg-agent.conf $(GNUPGDIR)/gpg-agent.conf
	@echo "gpg-agent.conf has been linked in $(GNUPGDIR)"

clean-gnupg:
	rm -f $(GNUPGDIR)/gpg-agent.conf
	@echo "gpg-agent.conf has been removed from $(GNUPGDIR)"