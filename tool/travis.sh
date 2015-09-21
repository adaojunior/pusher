#!/usr/bin/env bash

# Fast fail the script on failures.   
set -e

pub run test:test 	test/pusher_test.dart

# Install dart_coveralls; gather and send coverage data.
if [ "$COVERALLS_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "stable" ]; then

  echo "Running coverage..."
  pub global activate dart_coveralls

  n=0
  until [ $n -ge 5 ]
  do
    # Workaround when failed coverage script still has exit code
    exec 5>&1
    OUTPUT=$(pub run dart_coveralls report \
      --retry 2 \
      --exclude-test-files \
      --debug \
      test/pusher_test.dart|tee >(cat - >&5))
    
    set +e
    echo $OUTPUT | grep "JSON file not found or failed to parse." &>/dev/null
    
    if [[ $? -ne 0 ]]; then
      break
    fi
    
    set -e

    echo "Coverage failed. Retried "$n" time."

    n=$[$n+1]
    sleep 15

    echo "Rerunning coverage..."
  done

  echo "Coverage complete."
else
  if [ -z ${COVERALLS_TOKEN+x} ]; then echo "COVERALLS_TOKEN is unset"; fi
  if [ -z ${TRAVIS_DART_VERSION+x} ]; then
    echo "TRAVIS_DART_VERSION is unset";
  else
    echo "TRAVIS_DART_VERSION is $TRAVIS_DART_VERSION";
  fi

  echo "Skipping coverage for this configuration."
fi
