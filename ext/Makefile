UNAME_M := $(shell uname -m)

ifeq ($(UNAME_M),arm64)
  ARCH_FLAGS = -arch arm64
else
  ARCH_FLAGS = -arch x86_64
endif

all: appkit_helper.o

appkit_helper.o: appkit_helper.m
	clang -c $(ARCH_FLAGS) -fobjc-arc -fPIC -o $@ $<

clean:
	rm -f appkit_helper.o

.PHONY: all clean
