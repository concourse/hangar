# hangar

*continuously deliver ops manager products*

## about

Hangar is a tool for continuously delivering Pivotal Ops Manager products. It
consumes a stemcell, multiple releases, and a metadata template and builds it
into the finished Ops Manager product. It can insert templated values into the
metadata based on the other resource inputs.

## usage

Using Hangar is simple. All of the options are required and you can specify
multiple release directories.

    Usage: hangar [options]
        -n, --product-name NAME          name of product to create
        -v, --product-version VERSION    version of product to create
        -s, --stemcell-dir DIR           directory containing stemcell
        -r, --release-dir DIR            directory containing release
        -m, --metadata-template FILE     metadata template file

## install

Add this line to your application's Gemfile:

    gem 'hangar', github: 'concourse/hangar'

And then execute:

    $ bundle

