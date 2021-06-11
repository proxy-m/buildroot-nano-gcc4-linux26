#############################################################
#
# concierge 1.0.0
#
#############################################################
CONCIERGE_VERSION = 1.0.0
CONCIERGE_SOURCE = concierge-$(CONCIERGE_VERSION).jar
CONCIERGE_SITE = http://ovh.dl.sourceforge.net/sourceforge/concierge/
CONCIERGE_DIR=$(BUILD_DIR)/concierge-$(CONCIERGE_VERSION)
CONCIERGE_SITE_BUNDLES = http://concierge.sourceforge.net/bundles/

CONCIERGE_LIBS = $(DL_DIR)/concierge-$(CONCIERGE_VERSION).jar $(DL_DIR)/shell-$(CONCIERGE_VERSION).jar \
	$(DL_DIR)/service-tracker-$(CONCIERGE_VERSION).jar $(DL_DIR)/event-admin-$(CONCIERGE_VERSION).jar

$(DL_DIR)/concierge-$(CONCIERGE_VERSION).jar:
	 $(call DOWNLOAD,$(CONCIERGE_SITE),concierge-$(CONCIERGE_VERSION).jar)

$(DL_DIR)/shell-$(CONCIERGE_VERSION).jar:
	 $(call DOWNLOAD,$(CONCIERGE_SITE_BUNDLES),shell-$(CONCIERGE_VERSION).jar)

$(DL_DIR)/service-tracker-$(CONCIERGE_VERSION).jar:
	 $(call DOWNLOAD,$(CONCIERGE_SITE_BUNDLES),service-tracker-$(CONCIERGE_VERSION).jar)

$(DL_DIR)/event-admin-$(CONCIERGE_VERSION).jar:
	 $(call DOWNLOAD,$(CONCIERGE_SITE_BUNDLES),event-admin-$(CONCIERGE_VERSION).jar)

$(TARGET_DIR)/usr/lib/concierge/: $(CONCIERGE_LIBS)
	mkdir -p $(TARGET_DIR)/usr/lib
	mkdir -p $(TARGET_DIR)/usr/lib/concierge
	cp -dpf $(DL_DIR)/concierge-$(CONCIERGE_VERSION).jar $(TARGET_DIR)/usr/lib/concierge/
	cp -dpf $(DL_DIR)/shell-$(CONCIERGE_VERSION).jar $(TARGET_DIR)/usr/lib/concierge/
	cp -dpf $(DL_DIR)/service-tracker-$(CONCIERGE_VERSION).jar $(TARGET_DIR)/usr/lib/concierge/
	cp -dpf $(DL_DIR)/event-admin-$(CONCIERGE_VERSION).jar $(TARGET_DIR)/usr/lib/concierge/
	cp -dpf package/java/concierge/files/init.xargs $(TARGET_DIR)/usr/lib/concierge/
	touch -c $@

$(TARGET_DIR)/usr/bin/concierge:
	cp -dpf package/java/concierge/files/concierge $(TARGET_DIR)/usr/bin/
	chmod +x $(TARGET_DIR)/usr/bin/concierge
	touch -c $@

concierge: $(TARGET_DIR)/usr/lib/concierge $(TARGET_DIR)/usr/bin/concierge

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_CONCIERGE),y)
TARGETS+=concierge
endif
