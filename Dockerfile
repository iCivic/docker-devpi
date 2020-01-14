#
FROM python:3.6-slim-stretch
LABEL maintainer="https://github.com/muccg/"

ARG ARG_DEVPI_SERVER_VERSION=5.3.1
ARG ARG_DEVPI_WEB_VERSION=4.0.1
ARG ARG_DEVPI_CLIENT_VERSION=5.1.1

ENV DEVPI_SERVER_VERSION $ARG_DEVPI_SERVER_VERSION
ENV DEVPI_WEB_VERSION $ARG_DEVPI_WEB_VERSION
ENV DEVPI_CLIENT_VERSION $ARG_DEVPI_CLIENT_VERSION
ENV PIP_NO_CACHE_DIR="off"
ENV PIP_INDEX_URL="https://pypi.python.org/simple"
ENV PIP_TRUSTED_HOST="127.0.0.1"
ENV VIRTUAL_ENV /env

COPY ./conf/sources.list /etc/apt/sources.list
COPY ./conf/pip.conf /etc/pip.conf

RUN apt-get update && \
	dpkg-reconfigure -f noninteractive tzdata && \
	rm -rf /etc/localtime && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	echo "Asia/Shanghai" > /etc/timezone && \
	apt-get install -y --no-install-recommends
	
# devpi user
RUN addgroup --system --gid 1000 devpi \
    && adduser --disabled-password --system --uid 1000 --home /data --shell /sbin/nologin --gid 1000 devpi

# create a virtual env in $VIRTUAL_ENV, ensure it respects pip version
RUN pip install virtualenv -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && virtualenv $VIRTUAL_ENV \
    && $VIRTUAL_ENV/bin/pip install pip==$PYTHON_PIP_VERSION -i https://pypi.tuna.tsinghua.edu.cn/simple
ENV PATH $VIRTUAL_ENV/bin:$PATH

# https://devpi.net/docs/devpi/devpi
# https://github.com/devpi/devpi
# PyPI 私有仓库指北 http://www.alonefire.cn/uncategorized/PyPI-私有仓库指北/

RUN pip install \
    "devpi-client==${DEVPI_CLIENT_VERSION}" \
    "devpi-web==${DEVPI_WEB_VERSION}" \
    "devpi-server==${DEVPI_SERVER_VERSION}" \
	-i https://pypi.tuna.tsinghua.edu.cn/simple

EXPOSE 3141
VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER devpi
ENV HOME /data
WORKDIR /data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["devpi"]
