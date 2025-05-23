FROM scenescape-base AS builder

USER root
SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

ARG CERTDOMAIN=scenescape.intel.com

ENV DEBIAN_FRONTEND=noninteractive

ARG USER_ID
ARG CERTDOMAIN=scenescape.intel.com

ENV DEBIAN_FRONTEND=noninteractive
ENV WSUSER=scenescape
ENV SCENESCAPE_HOME=/home/$WSUSER/SceneScape

COPY docker/requirements-runtime.txt /tmp

# Runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2 \
        bindfs \
        bzip2 \
        curl \
        libegl1 \
        libgl1 \
        libglib2.0 \
        libapache2-mod-wsgi-py3 \
        libapache2-mod-qos \
        mosquitto-clients \
        netcat \
        postgresql \
        python-is-python3 \
        python3-pip \
        python3-scipy \
        sudo \
    && pip3 install --upgrade --no-cache-dir \
        --extra-index-url https://download.pytorch.org/whl/cpu \
        -r /tmp/requirements-runtime.txt

RUN : \
    ; PSQLVER=$(ls /etc/postgresql) \
    ; echo "host all  all    0.0.0.0/0  md5" >> "/etc/postgresql/${PSQLVER}/main/pg_hba.conf" \
    ; echo "listen_addresses='*'" >> "/etc/postgresql/${PSQLVER}/main/postgresql.conf" \
    ;

RUN : \
    ; a2dismod -f \
          auth_basic \
          authn_core \
          authn_file \
          authz_host \
          authz_user \
          autoindex \
          status \
    ; a2enmod \
        allowmethods \
        headers \
        proxy \
        proxy_wstunnel \
        ssl \
    ; a2ensite default-ssl \
    ;

# mod_qos configuration
RUN cat > /etc/apache2/mods-available/qos.conf <<EOF
<IfModule qos_module>
   QS_ClientEntries 100000
   QS_SrvMaxConnPerIP 50
   MaxClients 256
   QS_SrvMaxConnClose 180
   QS_SrvMinDataRate 150 1200
</IfModule>
EOF

#Apache configuration
COPY docker/000-default.conf docker/default-ssl.conf /etc/apache2/sites-available/
COPY docker/apache2.conf /etc/apache2/
RUN : \
    ; sed -i "s/scenescape.intel.com/$CERTDOMAIN/g" /etc/apache2/sites-available/default-ssl.conf \
    ; chmod og-w /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf

# Add application user
RUN useradd -r -m -s /bin/bash $WSUSER && \
    usermod -a -G video,users $WSUSER && \
    chmod a+rX /home/$WSUSER

# Copy files needed by django
COPY django $SCENESCAPE_HOME/manager
COPY setup.py $SCENESCAPE_HOME/manager/
COPY django/manage.py $SCENESCAPE_HOME/
COPY version.txt $SCENESCAPE_HOME/manager/
COPY management $SCENESCAPE_HOME/manager/management
COPY static $SCENESCAPE_HOME/manager/static
COPY templates $SCENESCAPE_HOME/manager/templates
COPY templatetags $SCENESCAPE_HOME/manager/templatetags

#Install SceneScape
RUN : \
    ; eval WSHOME=~$WSUSER \
    ; chown -R "$WSUSER" "$WSHOME/SceneScape" \
    ; touch "$WSHOME/SceneScape/manager/settings_local.py" \
    ; chown "$WSUSER.$WSUSER" "$WSHOME/SceneScape/manager/settings_local.py" \
    ; pip3 install --no-cache-dir "$SCENESCAPE_HOME/manager/" \
    ;

RUN chown -R ${USER_ID} \
    $SCENESCAPE_HOME/manager/static/assets \
    $SCENESCAPE_HOME/manager/static/examples \
    $SCENESCAPE_HOME/manager/static/bootstrap

RUN chmod -R u=rwX,go=rX $SCENESCAPE_HOME/manager/static/examples/ && \
    OPENCV_SHA=$(openssl dgst -sha256 -binary $SCENESCAPE_HOME/manager/static/assets/opencv.js | openssl base64) && \
    sed -i "s|sha256-opencv|sha256-$OPENCV_SHA|g" /etc/apache2/sites-available/000-default.conf

# Copy init scripts
COPY docker/scenescape-init docker/database-init docker/webserver-init /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/scenescape-init"]
