

namespace :refinery_s3_assets do
  desc "download image and resource assets from s3"
  task :pull => :environment do
    Refinery::S3assets::Util.pull
  end

  desc "upload local image and resource assets to s3"
  task :push => :environment do
    Refinery::S3assets::Util.push
  end
end

# preserve old tasks
namespace :refinery do
  task :download_s3_assets => 'refinery_s3_assets:pull'
  task :upload_s3_assets => 'refinery_s3_assets:push' 
end
