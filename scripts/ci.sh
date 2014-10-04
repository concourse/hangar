#!/bin/sh

set -e

cd hangar

bundle install
bundle exec rspec