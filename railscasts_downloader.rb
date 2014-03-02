#!/usr/bin/ruby
require 'rss'

# PUT in your subscription account's rss feed. You can find it at 
# Magaging Subscription/RSS Feeds after logging Railscasts.com
SUBSCRIBED_FEED = ENV['RAILSCASTS_SUB_RSS_FEED'] || nil

puts 'Downloading rss index'
rss_feed = SUBSCRIBED_FEED || 'http://feeds.feedburner.com/railscasts'
rss_string = open(rss_feed).read
rss = RSS::Parser.parse(rss_string, false)
videos_urls = rss.items.map { |it| it.enclosure.url }.reverse
videos_filenames = videos_urls.map {|url| url.split('/').last }
existing_filenames = Dir.glob('*.mp4')
missing_filenames = videos_filenames - existing_filenames
puts "Downloading #{missing_filenames.size} missing videos"

missing_videos_urls = videos_urls.select { |video_url| missing_filenames.any? { |filename| video_url.match filename } }

missing_videos_urls.each do |video_url|
  filename = video_url.split('/').last
  puts filename
  download_success = system("curl -C - #{video_url} -o #{filename}.tmp")
  rename_success = system("mv #{filename}.tmp #{filename}")
  if download_success && rename_success
    puts "Download #{filename} success!"
    puts
  else
    puts "Something went wrong..."
  end
end
puts 'Finished synchronization'