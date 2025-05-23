
#!/usr/bin/env bash
set -euo pipefail

JSLIBDIR="static"
THREEJS_VERSION=168
CURL_FLAGS="--connect-timeout 5 --max-time 120 --retry 5 --retry-delay 0"
BOOTSTRAP_VERSION=4.6.1
BOOTSTRAP_ZIP="$JSLIBDIR/bootstrap-${BOOTSTRAP_VERSION}-dist.zip"
BOOTSTRAP_URL="https://github.com/twbs/bootstrap/releases/download/v${BOOTSTRAP_VERSION}/bootstrap-${BOOTSTRAP_VERSION}-dist.zip"

JSM_EXAMPLES=(
"fonts/helvetiker_regular.typeface.json"
"jsm/controls/OrbitControls.js"
"jsm/controls/TransformControls.js"
"jsm/environments/RoomEnvironment.js"
"jsm/webxr/XRControllerModelFactory.js"
"jsm/geometries/TextGeometry.js"
"jsm/helpers/VertexNormalsHelper.js"
"jsm/helpers/ViewHelper.js"
"jsm/interactive/HTMLMesh.js"
"jsm/interactive/InteractiveGroup.js"
"jsm/libs/draco/draco_encoder.js"
"jsm/libs/fflate.module.js"
"jsm/libs/ktx-parse.module.js"
"jsm/libs/mikktspace.module.js"
"jsm/libs/motion-controllers.module.js"
"jsm/libs/lil-gui.module.min.js"
"jsm/libs/stats.module.js"
"jsm/libs/zstddec.module.js"
"jsm/loaders/GLTFLoader.js"
"jsm/loaders/FontLoader.js"
"jsm/utils/BufferGeometryUtils.js"
"jsm/utils/SkeletonUtils.js"
"jsm/utils/WorkerPool.js"
"jsm/webxr/VRButton.js"
)

download_jsm_examples() {
  for example in "${JSM_EXAMPLES[@]}"; do
    dest="$JSLIBDIR/examples/$example"
    url="https://cdn.jsdelivr.net/npm/three@0.${THREEJS_VERSION}.0/examples/$example"
    if [[ -f "$dest" ]]; then
      continue
    fi
    mkdir -p "$(dirname "$dest")"
    curl -f $CURL_FLAGS --location --output "$dest" "$url"
    sed -i -e "s,'three','/static/assets/three.module.js'," "$dest"
  done
}

download_asset() {
    local url="$1"
    local dest="$2"
    if [[ -f "$dest" ]]; then
      return
    fi
    curl -f $CURL_FLAGS --location --create-dirs --output "$dest" "$url"
}

download_jsm_examples
download_asset "https://code.jquery.com/jquery-3.6.0.min.js" "$JSLIBDIR/assets/jquery-3.6.0.min.js"
download_asset "https://raw.githubusercontent.com/adobe-webplatform/Snap.svg/master/dist/snap.svg-min.js" "$JSLIBDIR/assets/snap.svg-min.js"
download_asset "https://cdn.jsdelivr.net/npm/glfx@0.0.4/glfx.min.js" "$JSLIBDIR/assets/glfx.min.js"
download_asset "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.3.0/font/bootstrap-icons.css" "$JSLIBDIR/bootstrap/css/bootstrap-icons.css"

download_asset "https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.7/js/tether.min.js" "$JSLIBDIR/assets/tether.min.js"
download_asset "https://cdnjs.cloudflare.com/ajax/libs/jquery.imagesloaded/4.1.4/imagesloaded.pkgd.min.js" "$JSLIBDIR/assets/imagesloaded.pkgd.min.js"
download_asset "https://cdnjs.cloudflare.com/ajax/libs/mqtt/4.3.5/mqtt.min.js" "$JSLIBDIR/assets/mqtt.min.js"
download_asset "https://cdn.jsdelivr.net/npm/three@0.${THREEJS_VERSION}.0/build/three.module.js" "$JSLIBDIR/assets/three.module.js"
download_asset "https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js" "$JSLIBDIR/assets/axios.min.js"
download_asset "https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js.map" "$JSLIBDIR/assets/axios.min.js.map"
download_asset "https://docs.opencv.org/4.10.0/opencv.js" "$JSLIBDIR/assets/opencv.js"
download_asset "https://raw.githubusercontent.com/jothepro/doxygen-awesome-css/main/doxygen-awesome.css" "$JSLIBDIR/assets/doxygen-awesome.css"
download_asset "https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.bundle.min.js" "$JSLIBDIR/bootstrap/js/bootstrap.bundle.min.js"
download_asset "https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css" "$JSLIBDIR/bootstrap/css/bootstrap.min.css"
download_asset "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.3.0/font/bootstrap-icons.css" "$JSLIBDIR/bootstrap/css/bootstrap-icons.css"
download_asset "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.3.0/font/fonts/bootstrap-icons.woff" "$JSLIBDIR/bootstrap/css/fonts/bootstrap-icons.woff"
download_asset "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.3.0/font/fonts/bootstrap-icons.woff2" "$JSLIBDIR/bootstrap/css/fonts/bootstrap-icons.woff2"

URL_PM="https://unpkg.com/three-projected-material/build/ProjectedMaterial.module.js"
TMPFILE=$(mktemp)
download_asset "$URL_PM" "$TMPFILE"
sed "s,'three','/static/assets/three.module.js'," "$TMPFILE" > "$JSLIBDIR/assets/ProjectedMaterial.module.js"
rm "$TMPFILE"

if [ ! -f "$BOOTSTRAP_ZIP" ]; then
  curl -f $CURL_FLAGS --location --create-dirs --output "$BOOTSTRAP_ZIP" "$BOOTSTRAP_URL"
fi

if [ ! -f "$JSLIBDIR/bootstrap/js/bootstrap.js" ]; then
  echo "Extracting bootstrap JS files..."
  unzip -j -o "$BOOTSTRAP_ZIP" "bootstrap-${BOOTSTRAP_VERSION}-dist/js/*" -d "$JSLIBDIR/bootstrap/js"
fi

if [ ! -f "$JSLIBDIR/bootstrap/css/bootstrap.css" ]; then
  echo "Extracting bootstrap CSS and fonts..."
  unzip -u -o "$BOOTSTRAP_ZIP" -d "$JSLIBDIR/bootstrap/"
  rsync -aP --remove-source-files "$JSLIBDIR/bootstrap/bootstrap-${BOOTSTRAP_VERSION}-dist/" "$JSLIBDIR/bootstrap/"
  rm -rf "$JSLIBDIR/bootstrap/bootstrap-${BOOTSTRAP_VERSION}-dist"
fi
