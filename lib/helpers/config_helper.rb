module ConfigHelper
  def upload(url, file, key, username, password)
    res = ''
    url = URI.parse(url)
    File.open(File.join(LIB_DIR,file)) do |conf|
      req = Net::HTTP::Post::Multipart.new(url.path,
        key => UploadIO.new(conf, "application/octet-stream", File.join(LIB_DIR,file)))
      req.basic_auth username, password
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
    end
    res.body
  end
end
