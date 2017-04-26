Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }
if Rails.env.production?
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)
end
