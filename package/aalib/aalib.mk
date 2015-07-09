#############################################################
#
# aalib
#
#############################################################
AALIB_VERSION = 1.4rc5
AALIB_SOURCE = aalib-$(AALIB_VERSION).tar.gz
AALIB_SITE = http://sourceforge.net/projects/aa-project/files/aa-lib/1.4rc5/
AALIB_INSTALL_STAGING = YES
AALIB_INSTALL_TARGET = YES
AALIB_CONF_OPTS = --enable-shared --enable--static --with-x11-driver=no
AALIB_DEPENDENCIES = slang

$(eval $(autotools-package))
