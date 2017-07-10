PACKAGE_NAME = odlbt
PACKAGE_VERS = 1.0.0

INSTALL = install -c

PREFIX = /usr/local/share

# Source directories
SRC_DIR = ./src
BIN_DIR = $(SRC_DIR)
LIB_DIR = ./lib
BINS = $(wildcard $(BIN_DIR)/*.sh)
LIBS = $(wildcard $(LIB_DIR)/*.sh)
LIBSPY = $(wildcard $(LIB_DIR)/*.py)
#OBJS=$(addprefix $(PREFIX)/,$(notdir $(SRCS:.cpp=.o)))

SCE_DIR = ./scenarios
SCE_SUB = $(notdir $(wildcard $(SCE_DIR)/*))
SCES = $(wildcard $(SCE_DIR)/*/*)

# Destination directories
INSTALL_DIR = $(PREFIX)/$(PACKAGE_NAME)-$(PACKAGE_VERS)
ACCESS_DIR = $(PREFIX)/$(PACKAGE_NAME)

BIND = $(addprefix $(INSTALL_DIR)/bin/,$(notdir $(BINS)))
LIBD = $(addprefix $(INSTALL_DIR)/lib/,$(notdir $(LIBS)))
LIBDPY = $(addprefix $(INSTALL_DIR)/lib/,$(notdir $(LIBSPY)))
EXED = $(addprefix /usr/local/bin/,$(notdir $(BIND:.sh=)))
JQD = /usr/local/bin/jq

SCE_SUBD = $(addprefix $(INSTALL_DIR)/scenarios/,$(SCE_SUB))
SCED = $(addprefix $(INSTALL_DIR)/scenarios/,$(notdir $(SCES)))



.PHONY: install
install: $(INSTALL_DIR) $(ACCESS_DIR) $(BIND) $(LIBD) $(EXED) $(LIBDPY) scenarios $(JQD)

$(INSTALL_DIR): $(SCE_SUBD)
	-mkdir -p $(INSTALL_DIR)
	-mkdir -p $(INSTALL_DIR)/bin
	-mkdir -p $(INSTALL_DIR)/lib

$(INSTALL_DIR)/scenarios/%:
	-mkdir -p $@

$(ACCESS_DIR):
	-ln -s $(PACKAGE_NAME)-$(PACKAGE_VERS) $(ACCESS_DIR)

$(INSTALL_DIR)/bin/%.sh: src/%.sh
	$(INSTALL) $< $@

$(INSTALL_DIR)/lib/%: lib/%
	$(INSTALL) $< $@

.PHONY: scenarios
scenarios:
	-rsync -a $(SCE_DIR)/* $(INSTALL_DIR)/scenarios/

/usr/local/bin/jq:
	$(INSTALL) $(SRC_DIR)/jq $@

/usr/local/bin/%: $(INSTALL_DIR)/bin/%.sh
	ln -s $< $@

.PHONY: echo
echo:
	@echo SRCS
	@echo $(SRCS)
	@echo OBJS
	@echo $(OBJS)
	@echo EXED
	@echo $(EXED)
	@echo SCE_SUB
	@echo $(SCE_SUB)
	@echo SCES
	@echo $(SCES)
	@echo SCED
	@echo $(SCED)
	@echo SCE_SUBD
	@echo $(SCE_SUBD)
