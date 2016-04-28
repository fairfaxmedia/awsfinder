# Awsfinder

Quick CLI tool for various "quickly find X" and general ad-hoc audit/discovery tasks in AWS.

## Installation

    $ gem install awsfinder

## Usage

    $ awsfinder help
    Commands:
      awsfinder download_active_stack_templates REGEX  # download and save JSON templates for all active Cloudformation stacks
      awsfinder find_access_key_owner KEYID            # attempt to find IAM user with access key KEYID
      awsfinder find_active_stacks REGEX               # list CloudFormation stacks matching REGEX with no deletion time set
      awsfinder find_all_stack_amis REGEX              # like find_stack_amis but across all available CloudFormation stacks matching REGEX
      awsfinder find_stack_amis STACK                  # discover all AMIs referenced in a CloudFormation stack
      awsfinder help [COMMAND]                         # Describe available commands or one specific command

## Development

This is just a very basic commandline tool using the Thor framework, so adding new commands is pretty uncomplicated. PRs welcomed!

## Contributing

1. Fork it ( https://github.com/fairfaxmedia/awsfinder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
