MODULES := bash mpv viewnior

.PHONY: $(MODULES) install clean

install: $(MODULES)

$(MODULES):
	$(MAKE) -C modules/$@ install-$@

clean:
	for module in $(MODULES); do \
		$(MAKE) -C modules/$$module clean-$$module; \
	done