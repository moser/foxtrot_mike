require "net/http"
require "uri"

Net::HTTP.start("localhost", 3000) do |http|
  r = http.post("/account_sessions", "account_session[login]=admin&account_session[password]=admin")
  req = Net::HTTP::Get.new('/flights/day/2010-11-19', {'Cookie' => r['set-cookie']})
  5.times do 
    p http.request(req)
  end
end
