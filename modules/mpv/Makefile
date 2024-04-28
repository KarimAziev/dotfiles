MPV_DIR := $(HOME)/.config/mpv

install-mpv:
        mkdir -p $(MPV_DIR)
	ln -sfn $(CURDIR)/input.conf $(MPV_DIR)/input.conf
	ln -sfn $(CURDIR)/mpv.conf $(MPV_DIR)/mpv.conf

clean-mpv:
	rm -f $(MPV_DIR)/input.conf
	rm -f $(MPV_DIR)/mpv.conf