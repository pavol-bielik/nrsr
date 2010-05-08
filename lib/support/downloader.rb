require 'net/http'
require 'net/https'
class URI2
  attr_accessor :port, :host, :query, :path
  def initialize(port, host, query, path)
    self.port = port
    self.host = host
    self.query = query
    self.path = path
  end
  
  def self.parse(urlstring)
    $port = 80
    $host = urlstring.scan(/http:\/\/([^\/]*)/)[0][0]
    $query = urlstring.scan(/\?(.*)/)[0][0]
    $path = urlstring.scan(/http:\/\/[^\/]*([^\?]*)/)[0][0]
    return URI2.new($port, $host, $query, $path)
  end
end

class Downloader
  private_class_method :new
  @@singleton = nil
  @@useragent = "Opera/9.80 (Windows NT 5.1; U; en) Presto/2.2.15 Version/10.10";   
 
  def self.getInstance
    @@singleton = new unless @@singleton
    return @@singleton
  end
  def parseUrl(urlstring)   
      begin
        uri = URI2.parse(urlstring)  
        return uri
      rescue
        puts $!
        puts "ERROR: Parse url #{urlstring}"
        return nil    
    end
  end
  def download(urlstring, postdata=nil) 
      url = parseUrl(urlstring)
      http = Net::HTTP.new(url.host, url.port)  
      http.open_timeout = 10
      http.read_timeout = 10
      begin   
        header = {'User-Agent' => @@useragent}
        if postdata
          response, data = http.post("#{url.path}?#{url.query}", postdata, header)   
        else
          response, data = http.get("#{url.path}?#{url.query}", header)     
        end
        case response
        when Net::HTTPSuccess then response
        when Net::HTTPRedirection then
          return download(response['location'])
        else
          #response.error!
        end     
      rescue Exception
        puts $!
        puts "while responding: #{url.host}#{url.path}"
        return nil, nil
      end
      return response, data
  end   
  
end