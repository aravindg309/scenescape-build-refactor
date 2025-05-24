# Copyright (C) 2021-2025 Intel Corporation
#
# This software and the related documents are Intel copyrighted materials,
# and your use of them is governed by the express license under which they
# were provided to you ("License"). Unless the License provides otherwise,
# you may not use, modify, copy, publish, distribute, disclose or transmit
# this software or the related documents without Intel's prior written permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the License.

SHELL=/bin/bash
IMAGE=scenescape-manager
VERSION:=$(shell cat ../version.txt)
CERTDOMAIN=scenescape.intel.com
DBDIR=../../db
MIGRATIONSDIR=../../migrations
MEDIADIR=../../media
DATASETS=../../datasets
USERVIDEODIR=../../videos
JSLIBDIR=../static
CURL_FLAGS=--connect-timeout 5 --max-time 120 --retry 5 --retry-delay 0
FORCE_VAAPI ?= 0
THREEJS_VERSION=168

define axios-asset-recipe =
	URL=https://cdn.jsdelivr.net/npm/axios/dist && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}
endef

-include Makefile.uifiles Makefile.editorfiles Makefile.jsmexamples Makefile.scenecommonfiles

default: Makefile.uifiles jslibraries jsm-examples gen-extrafiles scene_common.tar scene_ui.tar Dockerfile \
	scenescape-init database-dirs user-dirs
	env BUILDKIT_PROGRESS=plain \
	  docker build $(REBUILDFLAGS) \
	    --build-arg http_proxy=$(http_proxy) \
	    --build-arg https_proxy=$(https_proxy) \
	    --build-arg no_proxy=$(no_proxy) \
	    --build-arg CERTDOMAIN=$(CERTDOMAIN) \
	    --build-arg USER_ID=$$UID \
	    --build-arg FORCE_VAAPI=$(FORCE_VAAPI) \
	    --rm -t $(IMAGE):$(VERSION) . \
	&& docker tag $(IMAGE):$(VERSION) $(IMAGE):latest

$(DBDIR):
	mkdir -p $@

$(MIGRATIONSDIR):
	mkdir -p $@

$(MEDIADIR):
	mkdir -p $@

$(DATASETS):
	mkdir -p $@

$(USERVIDEODIR):
	mkdir -p $@

user-dirs: $(USERVIDEODIR)

jsm-examples: $(JSMEXAMPLES)

database-dirs: $(DBDIR) $(MIGRATIONSDIR) $(MEDIADIR) $(DATASETS)

$(EDITORFILES):
	if [ ! -f $@ ] ; then \
	  curl -f $(CURL_FLAGS) --location --create-dirs --output $@ \
	  https://raw.githubusercontent.com/mrdoob/three.js/r$(THREEJS_VERSION)/$@; \
	fi

$(JSMEXAMPLES):
	$(eval RELPATH=$@)
	if [ ! -f $(JSLIBDIR)/examples/$@ ] ; then \
	  curl -f $(CURL_FLAGS) --location --create-dirs --output $(JSLIBDIR)/examples/$@ \
	  https://cdn.jsdelivr.net/npm/three@0.$(THREEJS_VERSION).0/examples/$(RELPATH) \
	  && sed -i -e "s,'three','/static/assets/three.module.js'," $(JSLIBDIR)/examples/$@; \
	fi

ASSET_DIRS := ../static/assets ../static/examples ../static/bootstrap
EXTRA_UIFILES := $(shell find $(ASSET_DIRS) -type f)

.PHONY: gen-extrafiles

gen-extrafiles:
	@find $(ASSET_DIRS) -type f > /dev/null

Makefile.uifiles:
	echo 'define UIFILES' > $@
	( IFS="$$(printf '\n+')" \
	  ; git ls-tree --full-tree -r --name-only --full-name HEAD manager \
	) | grep -Ev '/(tools|docker)/' | sed 's|^manager/||' | sort \
	| sed -e 's/$$/ \\/ ; $$s/ .$$//' >> $@
	echo endef >> $@

FPUIFILES= $(addprefix ../,$(UIFILES))
scene_ui.tar: Makefile.uifiles $(FPUIFILES)
	@echo $(EXTRA_UIFILES)
	tar -chf $@ $(FPUIFILES) $(EXTRA_UIFILES)

scene_common.tar:
	tar -chf $@ ../scene_common

# Download Javascript libraries
jslibraries: \
  $(JSLIBDIR)/assets/jquery-3.6.0.min.js                     \
  $(JSLIBDIR)/assets/snap.svg-min.js                         \
  $(JSLIBDIR)/assets/tether.min.js                           \
  $(JSLIBDIR)/assets/imagesloaded.pkgd.min.js                \
  $(JSLIBDIR)/assets/mqtt.min.js                             \
  $(JSLIBDIR)/bootstrap/css/bootstrap-icons.css              \
  $(JSLIBDIR)/assets/glfx.min.js                             \
  $(JSLIBDIR)/bootstrap/js/bootstrap.js                      \
  $(JSLIBDIR)/bootstrap/css/fonts/bootstrap-icons.woff       \
  $(JSLIBDIR)/assets/three.module.js                         \
  $(JSLIBDIR)/assets/ProjectedMaterial.module.js             \
  $(JSLIBDIR)/assets/opencv.js                               \
  $(JSLIBDIR)/assets/axios.min.js                            \
  $(JSLIBDIR)/assets/axios.min.js.map                        \
  $(JSLIBDIR)/assets/doxygen-awesome.css                     \

$(JSLIBDIR)/assets/jquery-3.6.0.min.js:
	URL=https://code.jquery.com && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/assets/snap.svg-min.js:
	URL=https://raw.githubusercontent.com/adobe-webplatform/Snap.svg/master/dist && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/assets/tether.min.js:
	URL=https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.7/js && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/assets/imagesloaded.pkgd.min.js:
	URL=https://cdnjs.cloudflare.com/ajax/libs/jquery.imagesloaded/4.1.4 \
	  && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/assets/mqtt.min.js:
	URL=https://cdnjs.cloudflare.com/ajax/libs/mqtt/4.3.5 && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/assets/axios.min.js:
	$(call axios-asset-recipe)

$(JSLIBDIR)/assets/axios.min.js.map:
	$(call axios-asset-recipe)

$(JSLIBDIR)/assets/glfx.min.js:
	URL=https://cdn.jsdelivr.net/npm/glfx@0.0.4 && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/bootstrap-4.6.1-dist.zip:
	VERSION=$$(echo $@ | sed -E -e 's/.*bootstrap-([0-9]+[.][0-9]+[.][0-9]+)-.*/\1/') \
	  URL=https://github.com/twbs/bootstrap/releases/download/v$${VERSION} \
	  PKG=$$(basename $@) \
	  ; curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/bootstrap-icons-1.3.0.zip:
	URL=https://github.com/twbs/icons/releases/download/v1.3.0 && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/bootstrap/css/bootstrap-icons.css: $(JSLIBDIR)/bootstrap/css
	URL=https://cdn.jsdelivr.net/npm/bootstrap-icons@1.3.0/font && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/bootstrap/js/bootstrap.js: $(JSLIBDIR)/bootstrap-4.6.1-dist.zip
	BOOTSTRAPDIR=$$(dirname $(dir $@)) \
	  DISTROOT=$$(basename $< .zip) \
	  ; mkdir -p $${BOOTSTRAPDIR} \
	    && unzip -u -d $${BOOTSTRAPDIR} $< \
	    && rsync -aP --remove-source-files $${BOOTSTRAPDIR}/$${DISTROOT}/* $${BOOTSTRAPDIR}/. \
	    && rmdir $${BOOTSTRAPDIR}/$${DISTROOT}/* $${BOOTSTRAPDIR}/$${DISTROOT}
	touch $@

$(JSLIBDIR)/bootstrap/css/fonts/bootstrap-icons.woff: $(JSLIBDIR)/bootstrap-icons-1.3.0.zip
	FONTDIR=$(dir $@) \
	 ; mkdir -p $${FONTDIR} \
	   && unzip -u -d $${FONTDIR} -j $< \
	        bootstrap-icons-1.3.0/fonts/\*
	touch $@

$(JSLIBDIR)/bootstrap/css: $(JSLIBDIR)/bootstrap/css/fonts/bootstrap-icons.woff

$(JSLIBDIR)/assets/three.module.js:
	URL=https://cdn.jsdelivr.net/npm/three@0.$(THREEJS_VERSION).0/build && PKG=$$(basename $@) \
	  && curl $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/assets/ProjectedMaterial.module.js:
	URL=https://unpkg.com/three-projected-material/build && PKG=$$(basename $@) \
	  && curl $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG} \
	  &&  sed "s,'three','/static/assets/three.module.js'," $@ > temp.js && mv temp.js $@

$(JSLIBDIR)/assets/opencv.js:
	URL=https://docs.opencv.org/4.10.0 && PKG=$$(basename $@) \
	  && curl $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}

$(JSLIBDIR)/assets/doxygen-awesome.css:
	URL=https://raw.githubusercontent.com/jothepro/doxygen-awesome-css/main && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}
