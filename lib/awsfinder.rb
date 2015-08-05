require 'awsfinder/version'
require 'aws-sdk'
require 'thor'
require 'pp'

module AWSFinder
  class AWSFinder < Thor
    class_option :key,
      type: :string,
      default: ENV['AWS_ACCESS_KEY_ID'],
      desc: 'AWS access key ID to use, if required'
    class_option :secret,
      type: :string,
      default: ENV['AWS_SECRET_ACCESS_KEY'],
      desc: 'AWS access key secret to use, if required'
    class_option :region,
      type: :string,
      default: ENV['AWS_REGION'],
      desc: 'AWS region to use'
    def initialize(*args)
      super
      begin
        use_credentials if options[:key].length > 1
        @iam = Aws::IAM::Client.new(region: options[:region])
        Thread.abort_on_exception = true
        @logger = Logger.new(options[:log] || STDOUT)
        @failures = Array.new
        @stats = {
          :files  => 0,
          :puts   => 0,
          :copies => 0,
          :bytes  => 0,
        }
      rescue Aws::Errors::ServiceError => e
        print "AWS exception: #{e.message}\n"
      end
    end

    desc 'find_access_key_owner KEYID', 'attempt to find IAM user with access key KEYID'
    def find_access_key_owner(key)
      # is there a less-nesty way to do this?
      @iam.list_users.each do |uresp|
        uresp.users.map(&:user_name).each do |u|
          access_keys = @iam.list_access_keys({user_name: u }).each do |aresp|
            aresp.access_key_metadata.map(&:access_key_id).each do |akid|
              if akid == key then
                puts "#{u} owns access key ID #{key}"
                return 0
              end
            end
          end
        end
      end
      puts "could not find an owner for access key ID #{key}"
      return 1
    end

  private
    def use_credentials
      Aws.config.update({
        region: options[:region],
        credentials: Aws::Credentials.new(options[:key], options[:secret]),
      })
    end
  end
end
