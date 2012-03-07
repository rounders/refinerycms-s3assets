require 'aws-sdk'
require 'heroku/command/base'
require 'progress_bar'

module Refinery
  module S3assets
    class MyRailtie < Rails::Railtie
      rake_tasks do
        Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
      end
    end

    class Util

      def self.pull
        verify_s3_configuration
        base_path = "public/system/refinery"
        copy_from_s3_bucket(Image, :image_uid, s3_config[:bucket], File.join(base_path, "images"))
        copy_from_s3_bucket(Resource, :file_uid, s3_config[:bucket], File.join(base_path, "resources"))
      end

      def self.push
        verify_s3_configuration
        base_path = "public/system/refinery"
        copy_to_s3_bucket(Image, :image_uid, s3_config[:bucket], File.join(base_path, "images"))
        copy_to_s3_bucket(Resource, :file_uid, s3_config[:bucket], File.join(base_path, "resources"))
      end

      private

      def self.verify_s3_configuration
        { :key => 'S3_KEY', :secret => 'S3_SECRET', :bucket => 'S3_BUCKET' }.each do |key, val|
          raise(StandardError, "no #{val} config var or environment variable found") if s3_config[key].nil?
        end
      end

      def self.copy_to_s3_bucket(klass, uid, bucket, source_path)
        puts "Uploading #{klass.count} #{klass.to_s.pluralize} to #{bucket} bucket"
        bar = ProgressBar.new(klass.count, :bar, :counter, :percentage)
        klass.all.each do |object|
          s3_object = s3.buckets[bucket].objects[object.send(uid)]
          path = File.join(source_path, object.send(uid))
          s3_object.write(:file => path, :acl => :public_read)
          bar.increment!
        end
      end

      def self.copy_from_s3_bucket(klass, uid, bucket, output_path)
        puts "Downloading #{klass.count} #{klass.to_s.pluralize} from #{bucket} bucket"
        bar = ProgressBar.new(klass.count, :bar, :counter, :percentage)
        skipped_files = []
        klass.all.each do |object|
          begin
            s3_object = s3.buckets[bucket].objects[object.send(uid)]
            dest = File.join(output_path, s3_object.key)
            copy_s3_object(s3_object, dest)
            bar.increment!
          rescue AWS::S3::Errors::NoSuchKey
            skipped_files << object.send(uid)
          end
        end
        skipped_files.each {|f| puts "could not find #{f}"}
      end

      def self.copy_s3_object(s3_object, to)
        FileUtils::mkdir_p File.dirname(to), :verbose => false
        open(to, 'wb') do |f|
          f.write s3_object.read
        end
      end

      def self.s3
        @s3 ||= AWS::S3.new(:access_key_id => s3_config[:key], :secret_access_key => s3_config[:secret])
      end

      def self.s3_config
        return @s3_config unless @s3_config.nil?
        is_heroku_app = false

        begin
          base = Heroku::Command::BaseWithApp.new
          app = base.app
          is_heroku_app = true
        rescue
        end

        config_vars = is_heroku_app ? base.heroku.config_vars(app) : {}

        @s3_config = {
          :key => ENV['S3_KEY'] || config_vars['S3_KEY'],
          :secret => ENV['S3_SECRET'] || config_vars['S3_SECRET'],
          :bucket => ENV['S3_BUCKET'] || config_vars['S3_BUCKET']
        }

        unless [:key, :secret, :bucket].all?{|s3| @s3_config[s3].present?}
          puts "Could not get complete s3 configuration."
          puts "This application is not a Heroku application." unless is_heroku_app
          exit 1
        end

        @s3_config
      end

    end
  end
end

