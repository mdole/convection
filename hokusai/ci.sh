#!/bin/bash

set -ex
set -o errexit
set -o nounset
set -o pipefail

retry() {
  max_attempts="${1}"; shift
  retry_delay_seconds="${1}"; shift
  cmd="${@}"
  attempt_num=1

  until ${cmd}; do
    (( attempt_num >= max_attempts )) && {
      echo "Attempt ${attempt_num} failed and there are no more attempts left!"
      return 1
    }
    echo "Attempt ${attempt_num} failed! Trying again in ${retry_delay_seconds} seconds..."
    attempt_num=$[ attempt_num + 1 ]
    sleep ${retry_delay_seconds}
  done

  bundle exec rake db:schema:load
}

retry 1>&2 ${MAX_ATTEMPTS:-5} ${RETRY_DELAY_SECONDS:-1} psql ${DATABASE_URL} -c '\l'

bundle exec rake
