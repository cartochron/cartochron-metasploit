MSF_DIR ?= $(HOME)/.msf4/modules
MODULE = $(MSF_DIR)/post/android/gather/cartochron.rb

check:
	ruby tests/test_cartochron.rb

install:
	install -Dm644 cartochron.rb "$(MODULE)"

uninstall:
	rm -f "$(MODULE)"

.PHONY: check install uninstall
