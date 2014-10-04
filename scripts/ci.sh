#!/bin/sh

cd hangar

gem install bundler --no-ri --no-rdoc

bundle install -j 4
bundle exec rspec