#!/bin/bash

. ./certgen/certgen/lib.sh

for size in 512 1024 2048 4096; do
    name="rsa${size}"
    tmp_file="$(mktemp)"
    if ! x509KeyGen -s $size $name &> "$tmp_file"; then
        echo "ERROR $size bit key generation failed" >&2
        cat "$tmp_file" >&2
        exit 1
    fi
    if ! x509SelfSign --basicKeyUsage keyEncipherment $name &> "$tmp_file"; then
        echo "ERROR: $size bit key self-signing failed" >&2
        cat "$tmp_file" >&2
        exit 1
    fi

    echo "RSA $size bit private key in old OpenSSL format is in" $(x509Key $name)
    echo "RSA $size bit private key in PKCS#8 PEM format is in" $(x509Key --pkcs8 $name)
    echo "RSA $size bit private key in PKCS#8 DER format is in" $(x509Key --der --pkcs8 $name)
    echo "RSA $size bit private key in PKCS#12 format is in" $(x509Key --with-cert --pkcs12 $name)
    echo "RSA $size bit self-signed certificate is in" $(x509Cert $name)
    echo
done
