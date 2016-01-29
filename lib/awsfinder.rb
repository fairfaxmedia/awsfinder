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
      use_credentials if options[:key].length > 1
    end

    desc 'find_access_key_owner KEYID', 'attempt to find IAM user with access key KEYID'
    def find_access_key_owner(key)
      # is there a less-nesty way to do this?
      iam = Aws::IAM::Client.new(region: options[:region])
      iam.list_users.each do |uresp|
        uresp.users.map(&:user_name).each do |u|
          access_keys = iam.list_access_keys({user_name: u }).each do |aresp|
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

    desc 'find_active_stacks REGEX', 'list CloudFormation stacks matching REGEX with no deletion time set'
    def find_active_stacks(regex)
      stacks = _find_active_stacks(regex)
      if stacks.length > 0
        puts stacks.map(&:stack_name).sort
        return 0
      end
      return 1
    end

    desc 'download_active_stack_templates REGEX', 'download and save JSON templates for all active Cloudformation stacks'
    def download_active_stack_templates(regex)
      stacks = _find_active_stacks(regex)
      stacks.each do |summary|
        response = _cloudformation.get_template({stack_name: summary.stack_name})
        body = response.template_body
        filename = "#{summary.stack_name}.json"
        File.open(filename,"w") { |fd| fd.write(body) }
        puts "wrote #{filename}"
      end
    end

    desc 'find_stack_amis STACK', 'discover all AMIs referenced in a CloudFormation stack'
    def find_stack_amis(stack)
      resources = _cloudformation.describe_stack_resources({stack_name: stack})
      resources.stack_resources.each do |r|
        begin
          if r.resource_type == "AWS::AutoScaling::LaunchConfiguration"
            launchconfig = _autoscaling.describe_launch_configurations({
              launch_configuration_names: [ r.physical_resource_id ],
              max_records: 1
            })
            image_id = launchconfig[0][0].image_id
            puts "#{stack}: found active launchconfig #{r.physical_resource_id} with AMI #{_format_ami(image_id)}"
          elsif r.resource_type == "AWS::EC2::Instance"
            instances = _ec2.describe_instances({instance_ids: [r.physical_resource_id]})
            image_id = instances.reservations.first.instances.first.image_id
            puts "#{stack}: found active non-autoscale instance #{r.physical_resource_id} with AMI #{_format_ami(image_id)}"
          end
        rescue Exception => e
          puts "#{stack}: error interrogating #{r.resource_type} #{r.physical_resource_id}: #{e}"
        end
      end
    end

    desc 'find_all_stack_amis REGEX', 'like find_stack_amis but across all available CloudFormation stacks matching REGEX'
    def find_all_stack_amis(regex)
      stacks = _find_active_stacks(regex)
      stacks.each do |summary|
        find_stack_amis(summary.stack_name)
        # be cautious to avoid rate limiting
      end
    end

  private
    def _cloudformation
      @_cfn ||= Aws::CloudFormation::Client.new({region: options[:region], retry_limit: 8})
      @_cfn
    end

    def _autoscaling
      @_autoscaling ||= Aws::AutoScaling::Client.new({region: options[:region], retry_limit: 8})
      @_autoscaling
    end

    def _ec2
      @_ec2 ||= Aws::EC2::Client.new({region: options[:region], retry_limit: 8})
      @_ec2
    end

    def _ami(image_id)
      unless @ami_cache[image_id]
        amis = _ec2.describe_images({image_ids: [ image_id ]})
        @ami_cache[image_id] = amis.first.images.first
      end
      @ami_cache[image_id]
    end

    def _format_ami(image_id)
      ami = _ami(image_id)
      "#{image_id} created #{_ami_age(image_id)} days ago (#{ami.name})"
    end

    def _ami_age(image_id)
      (DateTime.now - DateTime.parse(_ami(image_id).creation_date)).to_i
    end

    def _find_active_stacks(regex)
      stacks = Array.new
      _cloudformation.list_stacks.each do |response|
        response.stack_summaries.each do |x|
          stacks << x if x.stack_name =~ /#{regex}/ && x.deletion_time == nil
        end
      end
      stacks
    end

    def initialize(*args)
      super
      @ami_cache = Hash.new
    end

    def use_credentials
      Aws.config.update({
        region: options[:region],
        credentials: Aws::Credentials.new(options[:key], options[:secret]),
      })
    end
  end
end
