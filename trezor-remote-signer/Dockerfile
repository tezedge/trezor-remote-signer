FROM python:3.6.8-alpine

RUN \
    apk add --no-cache \
        python3-dev \
        py3-setuptools \ 
        cython \
        eudev-dev \
        libusb-dev \
        curl \
        unzip \
        git \
        libffi-dev \
        build-base \
        openssl-dev \
        zlib-dev \
        jpeg \
        py3-pillow \
        protobuf \
        protobuf-dev

# install required python modules for remote signer 
COPY requirements.txt /
RUN pip3 install -r requirements.txt


# get repositories for trezorctl & trezorlib
RUN git clone https://github.com/simplestaking/trezor-common.git --branch staking_message
RUN git clone https://github.com/simplestaking/python-trezor.git --branch staking 
# copy trezor-common with trezor proto messages  for staking 
RUN cp -r trezor-common python-trezor/vendor/

# setup python trezor
RUN cd python-trezor && python setup.py develop 

# get remote signer repository
RUN git clone https://bitbucket.org/jurajselep/remote-signer.git --branch tezos-trezor_signer #4


# CMD ["gunicorn", "-b", "0.0.0.0:5000", "-w", "4", "signer:app"]
