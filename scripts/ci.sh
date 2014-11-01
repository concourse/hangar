#!/bin/sh

set -e

export GEM_HOME=$HOME/.gems
export PATH=$GEM_HOME/bin:$PATH

cd hangar

gem install bundler --no-rdoc --no-ri

bundle install
bundle exec rspec