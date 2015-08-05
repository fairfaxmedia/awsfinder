# Awsfinder

Quick CLI tool for various "quickly find X" ad-hoc tasks in AWS.

## Installation

    $ gem install awsfinder

## Usage

    $ awsfinder find_access_key_id AKIAoiuhewfiuhwefhuiwefh

## Development

This is just a very basic commandline tool using the Thor framework, so adding new commands is pretty uncomplicated. PRs welcomed!

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/awsfinder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
