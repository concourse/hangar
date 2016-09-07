# hangar

*continuously deliver ops manager products*

![Hangar](http://i.imgur.com/HoQHv2Q.jpg?2)

## about

Hangar is a tool for continuously delivering Pivotal Ops Manager products. It
consumes multiple releases and a metadata template and builds it
into the finished Ops Manager product. It can insert templated values into the
metadata based on the other resource inputs.

## usage

Using Hangar is simple. All of the options are required and you can specify
multiple release directories.

    Usage: hangar [options]
        -n, --product-name NAME          name of product to create
        -v, --product-version VERSION    version of product to create
        -r, --release-dir DIR            directory containing release
        -m, --metadata-template FILE     metadata template file
        -c, --content-migrations FILE    content migrations file
        -g  --migrations DIR'            directory containing javascript migrations

The metadata template can contain ERB that can be used to insert values such as the product version and any releases into the final metadata. For an example, see the [metadata template that the integration tests use](spec/assets/metadata/metadata.yml.erb).

## install

Add this line to your application's Gemfile:

    gem 'hangar', github: 'concourse/hangar'

And then execute:

    $ bundle

