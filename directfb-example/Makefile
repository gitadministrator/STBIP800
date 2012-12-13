# Makefile

### Compiler setup

ifndef VIP
  $(error VIP not set, check Makefile for alternatives.)
endif

ifndef HW
  $(error HW not set, check Makefile for alternatives.)
endif

# Architecture handling
ifeq ($(VIP),bcm45)
VIP_ARCH       = mipsel-motorola-linux-uclibc
endif
ifeq ($(VIP),st40)
VIP_ARCH       = sh4-motorola-linux-uclibc
endif

ifndef VIP_ARCH
  $(error "Invalid VIP set, check Makefile for alternatives")
endif

VIP_NAME       = $(VIP)
VIP_NAME_FULL  = $(VIP_NAME)_$(HW)

## Toolchain
DK_DIR        = $(shell echo $(EASL_SDK_ROOT))
DIST_DIR      = $(DK_DIR)/dist
VIP_DIR       = $(DIST_DIR)/$(VIP_NAME)
TOOLCHAIN_DIR = $(shell cat $(VIP_DIR)/toolchain_dir)
CC            = $(TOOLCHAIN_DIR)/bin/$(VIP_ARCH)-gcc
CXX           = $(TOOLCHAIN_DIR)/bin/$(VIP_ARCH)-c++

export PERLLIB = $(DIST_DIR)/bin

## GCC setup
CXXFLAGS += -Wall
CXXFLAGS += -c
CXXFLAGS += -Os

# Include files and libraries
CPPFLAGS += -I$(VIP_DIR)/include
CPPFLAGS += -I$(VIP_DIR)/3pp/include
CPPFLAGS += -I$(VIP_DIR)/3pp/include/directfb
ifeq ($(VIP),bcm45)
CPPFLAGS += -I$(TOOLCHAIN_PATH)/include/c++/4.2.0
CPPFLAGS += -I$(TOOLCHAIN_PATH)/include/c++/4.2.0/$(VIP_ARCH)
endif
ifeq ($(VIP),st40)
CPPFLAGS += -I$(TOOLCHAIN_PATH)/include/c++/4.2.1
CPPFLAGS += -I$(TOOLCHAIN_PATH)/include/c++/4.2.1/$(VIP_ARCH)
endif

# Include files and libraries
LDFLAGS += -L$(VIP_DIR)/lib
LDFLAGS += -L$(VIP_DIR)/3pp/lib
LDFLAGS += -Wl,-rpath-link,$(VIP_DIR)/lib
LDFLAGS += -Wl,-rpath-link,$(VIP_DIR)/3pp/lib
LDFLAGS += -lIpc
LDFLAGS += -ltoi
LDFLAGS += -lpthread
LDFLAGS += -ldirectfb
LDFLAGS += -ldirect
LDFLAGS += -lfusion


## Build dirs
build_dir = $(CURDIR)/.build


## Targets
bin_target = directfb-example
bin_srcs  += main.cpp
bin_srcs  += TApplication.cpp
bin_objs   = $(bin_srcs:.cpp=.o)


## IIP settings
name          = $(bin_target)
version       = DEV-opera-dfb
property_file = properties_$(name).xml

iip_name      = example-app-$(name)
iip_target    = $(CURDIR)/$(iip_name)_$(version)_$(VIP_NAME).iip
iip_data      = $(build_dir)/data


## Build rules
all: $(iip_target)

clean:
	rm -f *.o $(bin_target) $(iip_target)

$(bin_target): $(bin_objs)
	$(CXX) $(LDFLAGS) -o $@ $^

$(iip_data): $(bin_target) $(property_file)
	rm -rf $@
	mkdir -p $(iip_data)/usr/applications/$(bin_target)
	cp $^ $(iip_data)/usr/applications/$(bin_target)

$(iip_target): $(iip_data)
	$(DIST_DIR)/bin/iip_build \
	 --name $(iip_name) \
	 --version $(version) \
	 --processor $(VIP_NAME) \
	 --hw_comp $(HW) \
	 --data_dir $^ \
	 --depends kreatv-platform \
	 --depends kreatv-option-directfb-stack \
	 --install buildtime:$(DIST_DIR)/bin/install_app_in_rootdisk
	rm -rf $(build_dir)

setup:
	@$(DIST_DIR)/bin/install_toolchain $(DK_DIR)/products/toolchain_$(shell echo $(TOOLCHAIN_PATH) | sed 's|.*toolchain/||' | sed 's|/|_|' ).tar.bz2

TApplication.cpp: TApplication.h

main.cpp:

.PHONY: all host clean setup
