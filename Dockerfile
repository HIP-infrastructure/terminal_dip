ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="florian.sipp@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl unzip cmake build-essential \
    #plink2 \
    bzip2 \
    #bcftools \
    libbz2-dev zlib1g-dev liblzma-dev libcurl4-openssl-dev && \
    #install plink2 \
    mkdir plink2 && \
    cd plink2 && \
    curl -sSOL https://s3.amazonaws.com/plink2-assets/alpha4/plink2_linux_x86_64_20230829.zip && \
    unzip plink2_linux_x86_64_20230829.zip && \
    rm plink2_linux_x86_64_20230829.zip && \
    cd ../ && \
    #install bcftools \
    mkdir bcftools && \
    curl -sSOL https://github.com/samtools/bcftools/releases/download/1.18/bcftools-1.18.tar.bz2 && \
    tar jxvf bcftools-1.18.tar.bz2 && \
    rm bcftools-1.18.tar.bz2 && \
    cd bcftools-1.18 && \
    ./configure --prefix=/apps/terminal_dip/bcftools && \
    make -j7 && \
    make install && \
    cd ../ && \
    rm -rf bcftools-1.18 && \
    #install shapeit5 \
    mkdir shapeit5 && \
    cd shapeit5 && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/ligate_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/phase_common_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/phase_rare_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/simulate_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/switch_static && \
    curl -sSOL https://github.com/odelaneau/shapeit5/releases/download/v5.1.1/xcftools_static && \
    chmod 755 ligate_static && \
    chmod 755 phase_common_static && \
    chmod 755 phase_rare_static && \
    chmod 755 simulate_static && \
    chmod 755 switch_static && \
    chmod 755 xcftools_static && \
    cd ../ && \
    #install impute5 \
    curl -sSOL https://www.dropbox.com/sh/mwnceyhir8yze2j/AABKBCgZsQqz8TlZGo7yXwx6a/impute5_v1.2.0.zip && \
    unzip -q -d . impute5_v1.2.0.zip && \
    mv impute5_v1.2.0 impute5 && \
    rm impute5_v1.2.0.zip && \
    rm -rf __MACOSX && \
    rm -rf impute5/test && \
    chmod -R 755 impute5 && \
    #cleanup
    apt-get remove -y --purge curl unzip cmake build-essential bzip2 && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="terminal"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""
ENV CONFIG_ARRAY=".bash_profile"

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/
COPY ./apps/${APP_NAME}/config config/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
