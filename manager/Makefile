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
DBDIR=../db
MIGRATIONSDIR=../migrations
MEDIADIR=../media
DATASETS=../datasets
USERVIDEODIR=../videos
JSLIBDIR=src/static
CURL_FLAGS=--connect-timeout 5 --max-time 120 --retry 5 --retry-delay 0
FORCE_VAAPI ?= 0
THREEJS_VERSION=168
BASE_OS_IMAGE=ubuntu:22.04
BUILD_DIR=./build
LOG_FILE=$(BUILD_DIR)/$(IMAGE).log

define JSMEXAMPLES
fonts/helvetiker_regular.typeface.json \
jsm/controls/OrbitControls.js \
jsm/controls/TransformControls.js \
jsm/environments/RoomEnvironment.js \
jsm/webxr/XRControllerModelFactory.js \
jsm/geometries/TextGeometry.js \
jsm/helpers/VertexNormalsHelper.js \
jsm/helpers/ViewHelper.js \
jsm/interactive/HTMLMesh.js \
jsm/interactive/InteractiveGroup.js \
jsm/libs/draco/draco_encoder.js \
jsm/libs/fflate.module.js \
jsm/libs/ktx-parse.module.js \
jsm/libs/mikktspace.module.js \
jsm/libs/motion-controllers.module.js \
jsm/libs/lil-gui.module.min.js \
jsm/libs/stats.module.js \
jsm/libs/zstddec.module.js \
jsm/loaders/GLTFLoader.js \
jsm/loaders/FontLoader.js \
jsm/utils/BufferGeometryUtils.js \
jsm/utils/SkeletonUtils.js \
jsm/utils/WorkerPool.js \
jsm/webxr/VRButton.js
endef

JSMEXAMPLES := $(value JSMEXAMPLES)

define axios-asset-recipe =
	URL=https://cdn.jsdelivr.net/npm/axios/dist && PKG=$$(basename $@) \
	  && curl -f $(CURL_FLAGS) --location --create-dirs --output $@ $${URL}/$${PKG}
endef

default: jslibraries jsm-examples Dockerfile database-dirs user-dirs build-image

.PHONY: build-image
build-image: Dockerfile
	@echo "------- STARTING BUILD OF IMAGE: $(IMAGE):$(VERSION) -------"
	@mkdir -p $(BUILD_DIR)
	@-env BUILDKIT_PROGRESS=plain \
	  docker build $(REBUILDFLAGS) \
	    --build-arg http_proxy=$(http_proxy) \
	    --build-arg https_proxy=$(https_proxy) \
	    --build-arg no_proxy=$(no_proxy) \
	    --build-arg CERTDOMAIN=$(CERTDOMAIN) \
	    --build-arg USER_ID=$$UID \
	    --build-arg FORCE_VAAPI=$(FORCE_VAAPI) \
	    --rm -t $(IMAGE):$(VERSION) .. -f ./Dockerfile 2>&1 | tee $(LOG_FILE); \
	status=$${PIPESTATUS[0]}; \
	if [ $$status -eq 0 ]; then \
	    docker tag $(IMAGE):$(VERSION) $(IMAGE):latest; \
	    echo -e "\033[0;32m------- BUILD OF IMAGE $(IMAGE):$(VERSION) COMPLETED SUCCESSFULLY -------\033[0m"; \
	    echo "Log file created at $(LOG_FILE)"; \
	else \
	    echo -e "\033[0;31m------- BUILD OF IMAGE $(IMAGE):$(VERSION) FAILED. CHECK $(LOG_FILE) FOR DETAILS. -------\033[0m"; \
	    exit 1; \
	fi

.PHONY: rebuild
rebuild:
	$(MAKE) REBUILDFLAGS="--no-cache"

.PHONY: list-deps
list-deps:
	@mkdir -p $(BUILD_DIR)
	@docker run --rm --entrypoint pip $(IMAGE):$(VERSION) freeze --all > $(BUILD_DIR)/$(IMAGE)-pip-deps.txt
	@echo "Python dependencies listed in $(BUILD_DIR)/$(IMAGE)-pip-deps.txt"
	@docker run --rm $(BASE_OS_IMAGE) dpkg -l | awk '{ print $$2, $$3, $$4 }' > $(BUILD_DIR)/system-packages.txt
	@docker run --rm --entrypoint dpkg $(IMAGE):$(VERSION) -l | awk '{ print $$2, $$3, $$4 }' > $(BUILD_DIR)/controller-packages.txt
	@grep -Fxv -f $(BUILD_DIR)/system-packages.txt $(BUILD_DIR)/controller-packages.txt > $(BUILD_DIR)/$(IMAGE)-apt-deps.txt
	@rm -rf $(BUILD_DIR)/system-packages.txt $(BUILD_DIR)/controller-packages.txt
	@echo "OS dependencies listed in $(BUILD_DIR)/$(IMAGE)-apt-deps.txt"

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

$(JSMEXAMPLES):
	$(eval RELPATH=$@)
	if [ ! -f $(JSLIBDIR)/examples/$@ ] ; then \
	  curl -f $(CURL_FLAGS) --location --create-dirs --output $(JSLIBDIR)/examples/$@ \
	  https://cdn.jsdelivr.net/npm/three@0.$(THREEJS_VERSION).0/examples/$(RELPATH) \
	  && sed -i -e "s,'three','/static/assets/three.module.js'," $(JSLIBDIR)/examples/$@; \
	fi


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
