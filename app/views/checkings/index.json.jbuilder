json.array!(@checkings) do |checking|
  json.extract! checking, :id
  json.url checking_url(checking, format: :json)
end
