#!/usr/bin/env bash

set -o xtrace

pub run test:test 	test/pusher_test.dart

if [ "$COVERALLS_TOKEN" ]; then
  echo "Running coverage..."
  pub global activate dart_coveralls
  pub global run dart_coveralls report --token "$COVERALLS_TOKEN" --debug test/pusher_test.dart
  echo "Coverage complete..."
else
  echo "COVERALLS_TOKEN is unset. Skipping Coverage..."
fi
