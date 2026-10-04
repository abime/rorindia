namespace :serpapi do
  desc "Aggregate company-level details from cached job data (does not call SerpApi)"
  task fetch_companies: :environment do
    cache_dir = Rails.root.join("storage", "serpapi_cache", "companies")
    FileUtils.mkdir_p(cache_dir)

    companies = CompanyExtractorService.new.extract

    file = cache_dir.join("companies.json")
    File.write(file, JSON.pretty_generate(companies))

    puts "[serpapi:fetch_companies] #{companies.size} companies -> #{file}"
  end
end
