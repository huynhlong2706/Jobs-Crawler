class VietnamworksCrawler
  include HTTParty
  
  API_URL = 'https://ms.vietnamworks.com/job-search/v1.0/search'

  def initialize(pages: 5)
    @pages = pages
  end

  def perform
    results = { saved: 0, skipped: 0, errors: [] }

    (1..@pages).each do |page|
      puts "=> Đang cào dữ liệu trang #{page}..."
      jobs_data = fetch_page(page)
      
      break if jobs_data.empty?

      jobs_data.each { |data| save_job(data, results) }
      sleep(1) 
    end
    
    puts "=> Hoàn tất! Kết quả: #{results}"
    results
  end

  private

  def fetch_page(page)
    body = {
      userId: 0,
      query: "",
      filter: [],
      ranges: [],
      order: [],
      hitsPerPage: 50, 
      page: page - 1,
      summaryVersion: ""
    }.to_json

    headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      'Origin' => 'https://www.vietnamworks.com',
      'Referer' => 'https://www.vietnamworks.com/'
    }

    response = self.class.post(API_URL, headers: headers, body: body)
    
    unless response.success?
      puts "=> Bị server từ chối! Mã lỗi: #{response.code} - Body: #{response.body}"
      return []
    end
    
    JSON.parse(response.body)['data'] || []
  rescue StandardError => e
    puts "Lỗi fetch trang #{page}: #{e.message}"
    []
  end

  def save_job(data, results)
    url = data['alias'] ? "https://www.vietnamworks.com/#{data['alias']}" : nil
    return unless url

    job = Job.find_or_initialize_by(job_url: url)
    is_new = job.new_record?

    job.assign_attributes(
      title: data['jobTitle'],
      company_name: data['companyName'] || 'Chưa cập nhật',
      salary: format_salary(data['salaryMin'], data['salaryMax']),
      location: data.dig('workingLocations', 0, 'cityName') || 'Việt Nam',
      posted_at: data['approvedOn'] ? Time.parse(data['approvedOn']) : Time.current,
      source: 'vietnamworks'
    )
    
    if job.save
      is_new ? results[:saved] += 1 : results[:skipped] += 1
    else
      results[:errors] << "#{url}: #{job.errors.full_messages.join(', ')}"
    end
  rescue ActiveRecord::RecordNotUnique
    results[:skipped] += 1
  end

  def format_salary(min, max)
    min_val = min.to_i
    max_val = max.to_i

    return "Thỏa thuận" if min_val == 0 && max_val == 0

    currency = max_val > 10000 ? "VNĐ" : "USD"

    min_str = min_val.to_fs(:delimited)
    max_str = max_val.to_fs(:delimited)

    if min_val == 0
      "Lên đến #{max_str} #{currency}"
    elsif max_val == 0
      "Từ #{min_str} #{currency}"
    else
      "#{min_str} - #{max_str} #{currency}"
    end
  end
end
