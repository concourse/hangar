#!/bin/sh

set -e

export GEM_HOME=$HOME/.gems

cd hangar

bundle install
bundle exec rspec