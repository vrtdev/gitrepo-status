# Gitrepo::Status

## Idea

 - Check current status/commit of a repo
 - compare with remotes and extra urls
 - get source url from metadata.json for puppet modules
 - get puppetforge version for puppet modules


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gitrepo-status'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gitrepo-status

## Usage

TODO: Write usage instructions here

## Development

A 'vagrant/Vagrantfile' is provided to ease development on Debian Stretch.

The vagrant setup installs the required package ruby-rugged.
This is because installing/building the rugged gem is a pain in ...

The current repo will be available in '/build' in the VM.


After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gitrepo-status.
