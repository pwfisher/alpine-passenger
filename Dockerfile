FROM mhart/alpine-node:5.11.1

ENV \
    PASSENGER_VERSION="5.0.22" \
    PATH="/opt/passenger/bin:/opt/nginx/sbin:$PATH"

RUN \
    PACKAGES="ca-certificates procps curl pcre libstdc++ libexecinfo" && \
    BUILD_PACKAGES="build-base ruby ruby-rake ruby-rack ruby-dev linux-headers curl-dev pcre-dev libexecinfo-dev" && \
    echo 'http://alpine.gliderlabs.com/alpine/v3.3/main' > /etc/apk/repositories && \
    echo 'http://alpine.gliderlabs.com/alpine/edge/testing' >> /etc/apk/repositories && \
    apk add --update $PACKAGES $BUILD_PACKAGES && \
# download and extract
    mkdir -p /opt && \
    curl -L https://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz | tar -xzf - -C /opt && \
    mv /opt/passenger-$PASSENGER_VERSION /opt/passenger && \
    export EXTRA_PRE_CFLAGS='-O' EXTRA_PRE_CXXFLAGS='-O' EXTRA_LDFLAGS='-lexecinfo' && \
# compile nginx with passenger
    passenger-config compile-agent --auto --optimize && \
    passenger-install-nginx-module --auto --languages nodejs && \
# app directory
    mkdir -p /usr/src/app && \
#
# 197.7M	/opt/passenger
#   161.9M	/opt/passenger/buildout
#   2.9M	/opt/passenger/doc
#   31.6M	/opt/passenger/src
# 252.0K	/tmp
# 1.8M	/usr/share/doc
# 4.2M	/usr/share/man
# 15.8M	/usr/lib/ruby
# 69.1M	/usr/share/ri
# 1.1M	/var/cache/apk
#
# Cleanup passenger buildout directory
    rm -rf /tmp/* && \
    mv /opt/passenger/buildout/support-binaries /tmp && \
    rm -rf /opt/passenger/buildout/* && \
    mv /tmp/* /opt/passenger/buildout/ && \
# Cleanup passenger src directory
    rm -rf /tmp/* && \
    mv /opt/passenger/src/ruby_supportlib /tmp && \
    mv /opt/passenger/src/nodejs_supportlib /tmp && \
    mv /opt/passenger/src/helper-scripts /tmp && \
    rm -rf /opt/passenger/src/* && \
    mv /tmp/* /opt/passenger/src/ && \
# Cleanup
    passenger-config validate-install --auto && \
    apk del $BUILD_PACKAGES && \
    rm -rf \
        /tmp/* \
        /opt/passenger/doc \
        /usr/lib/ruby \
        /usr/share/doc \
        /usr/share/man \
        /var/cache/apk/*
# 0  /usr/share/ri
# 12.4M	/usr/lib/ruby
# 108.3M	/opt/passenger/buildout/support-binaries
#   2.2M	/opt/passenger/buildout/support-binaries/AgentBase.o
#   20.0K	/opt/passenger/buildout/support-binaries/AgentMain.o
#   12.7M	/opt/passenger/buildout/support-binaries/CoreApplicationPool.o
#   9.4M	/opt/passenger/buildout/support-binaries/CoreController.o
#   17.4M	/opt/passenger/buildout/support-binaries/CoreMain.o
#   37.8M	/opt/passenger/buildout/support-binaries/PassengerAgent
#   1.4M	/opt/passenger/buildout/support-binaries/SpawnPreparerMain.o
#   1.7M	/opt/passenger/buildout/support-binaries/SystemMetricsMain.o
#   44.0K	/opt/passenger/buildout/support-binaries/TempDirToucherMain.o
#   15.1M	/opt/passenger/buildout/support-binaries/UstRouterMain.o
#   10.5M	/opt/passenger/buildout/support-binaries/WatchdogMain.o

WORKDIR /usr/src/app
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
