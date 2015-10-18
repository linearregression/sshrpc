#!/bin/bash
echo on
echo "Start a ssh client"
TARGET_NODE_NAME=client_sshrpc@127.0.0.1
TEST_SYS_COOKIE=sshrpc

echo "Starting sshrpc CLIENT"
eval "erl \
    -name \"${TARGET_NODE_NAME}\" \
    -setcookie \"${TEST_SYS_COOKIE}\" \
    -pa deps/*/ebin -pa .sshrpc/_build/dev/lib/*/ebin  \
    -eval \"application:start(crypto)\" \
    -eval \"application:start(asn1)\" \
    -eval \"application:start(public_key)\" \
    -eval \"application:start(ssl)\" \
    -eval \"lager:start()\" \
    -eval \"application:start(sshrpc)\""
