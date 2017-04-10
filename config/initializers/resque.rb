Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }
