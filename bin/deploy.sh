#!/bin/bash

export APP_NAME=suspicious-petty-phoenix
unset SSL_CERT_FILE
echo "hey"

cd assets
npm install
node_modules/brunch/bin/brunch build --production
cd ..
mix phoenix.digest

MIX_ENV=prod mix release --env=prod
git push gigalixir master
