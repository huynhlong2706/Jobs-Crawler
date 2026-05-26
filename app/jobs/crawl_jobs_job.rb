class CrawlJobsJob < ApplicationJob
  queue_as :default

  def perform(pages = 5)
    puts "=> [Background Job] Bắt đầu tự động cào dữ liệu..."
    VietnamworksCrawler.new(pages: pages).perform
    puts "=> [Background Job] Đã cào xong!"
  end
end
