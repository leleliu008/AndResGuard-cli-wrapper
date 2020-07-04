version = 1.2.16
filename= AndResGuard-cli-$(version).tar.gz

dist: bin/andresguard lib/AndResGuard-cli-$(version).jar zsh-completion/_andresguard
	@(sed -i "" "s/VERSION=.*/VERSION='$(version)'/" bin/andresguard 2>/dev/null || \
	  sed -i    "s/VERSION=.*/VERSION='$(version)'/" bin/andresguard) && \
	tar zvcf $(filename) $^ && \
	command -v openssl > /dev/null && \
    openssl sha256 $(filename) && exit 0; \
    command -v sha256sum > /dev/null && \
    ha256sum $(filename)

clean:
	rm $(filename)

.PHONY: clean
