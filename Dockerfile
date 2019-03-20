FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

ENV DATABASE_URL https://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip

ENV OUTPUT_DIRECTORY /etc/nginx/geoip
ENV OUTPUT_FILE GeoLite2-City.dat

ENV BUILD_PACKAGES python py-pip curl
ENV PYTHON_PACKAGES ipaddr pygeoip

ENV GEOLITE2LEGACY_BRANCH master
ENV GEOLITE2LEGACY_ENCODING utf-8

ENV BUILD_DIR /tmp/build

RUN mkdir $BUILD_DIR \
  && cd $BUILD_DIR \
  && apk --no-cache --update add $BUILD_PACKAGES \
  && pip --no-cache-dir install $PYTHON_PACKAGES \
  && curl -L -o geolite2legacy.zip https://github.com/sherpya/geolite2legacy/archive/$GEOLITE2LEGACY_BRANCH.zip \
  && unzip geolite2legacy.zip \
  && curl -o GeoLite2-City.zip $DATABASE_URL \
  && echo "$(curl $DATABASE_URL.md5)  GeoLite2-City.zip" | md5sum -c - \
  && python geolite2legacy-$GEOLITE2LEGACY_BRANCH/geolite2legacy.py -i GeoLite2-City.zip -f geolite2legacy-$GEOLITE2LEGACY_BRANCH/geoname2fips.csv -o $OUTPUT_FILE -e $GEOLITE2LEGACY_ENCODING \
  && rm -rf geolite2legacy-$GEOLITE2LEGACY_BRANCH \
  && rm -rf /usr/lib/python2.7 \
  && apk del $BUILD_PACKAGES \
  && rm -rf /var/cache/apk/* \
  && mkdir -p $OUTPUT_DIRECTORY \
  && mv $OUTPUT_FILE $OUTPUT_DIRECTORY/$OUTPUT_FILE \
  && rm -rf $BUILD_DIR

EXPOSE 80