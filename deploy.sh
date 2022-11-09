#!/bin/bash

rm md/md-private
mkdir md/md-private
npm run deploy
rm -r md/md-private
ln -s ~/Dropbox\ \(Personal\)/md-private md/md-private
