class Job < ActiveRecord::Base
  module JobArtifacts
    extend ActiveSupport::Concern

    def stdout
      begin
        Paperclip.io_adapters.for(stdout_log.asset).read if stdout_log.present?
      rescue => e
        "Couldn't load stdout file #{e.message}"
      end
    end
    
    def stderr
      begin
        Paperclip.io_adapters.for(stderr_log.asset).read if stderr_log.present?
      rescue => e
        "Couldn't load stderr output #{e.message}"
      end
    end
    
    def command
      begin
        Paperclip.io_adapters.for(command_log.asset).read if command_log.present?
      rescue
        "Couldn't load command file"
      end
    end
    
    def log_files
      all_logs.reduce({}) do |hash, log_artifact|
        hash[log_artifact.asset_file_name] = log_artifact.asset.expiring_url(10*60)
        hash
      end
    end

    # Returns a hash of filename/url pairs
    def images
      image_artifacts.reduce({}) do |hash, image_artifact|
        hash[image_artifact.asset_file_name] = image_artifact.asset.expiring_url(10*60)
        hash
      end
    end
    
    private

    def stdout_log
      find_asset("pretty.out") or find_asset("stdout.log")
    end

    def stderr_log
      find_asset("stderr.log")
    end

    def command_log
      find_asset("executed_script.sh") or find_asset("cmd.sh")
    end

    def all_logs
      artifacts.find_all do |artifact|
        artifact.asset_content_type !~ /^image\//
      end
    end

    def image_artifacts
      artifacts.find_all do |artifact|
        artifact.asset_content_type =~ /^image\// || artifact.asset_file_name.end_with?('.png', '.jpg', '.jpeg')
      end
    end
    
    def find_asset(file_name)
      artifacts.find do |artifact|
        artifact.asset_file_name == file_name
      end
    end
  end
end
