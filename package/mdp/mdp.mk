#############################################################
#
# MDP
#
#############################################################
MDP_VERSION = 441b424160ccf92f27828c5f4c42b9276f65f076
MDP_SITE = git://github.com/visit1985/mdp

MDP_INSTALL_STAGING = YES
MDP_INSTALL_TARGET = YES
MDP_DEPENDENCIES = ncurses

define MDP_BUILD_CMDS
	$(MAKE)  $(TARGET_CONFIGURE_OPTS) -C $(@D) CFLAGS=-I$(@D)/include 
endef

define MDP_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/mdp $(TARGET_DIR)/usr/bin/mdp
endef

$(eval $(generic-package))
