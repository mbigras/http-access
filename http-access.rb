require 'socket'
require 'uri'

class HTTPError < StandardError; end
class HTTPInvalidState < HTTPError; end
class HTTPBadResponse < HTTPError; end

class HTTPSocket < TCPsocket
  HTTP_Version = 'HTTP/1.1'

  def putrequest(method, path='/', version=HTTP_Version)
    path = '/' if path == ''
    write format("%s %s %s\r\n", method, path, version)
  end

  def putheader(header, *args)
    write format("%s: %s\r\n", header, args.join("\r\n\t"))
  end

  def endheaders
    write "\r\n"
  end

  def putbody(body)
    write format("%s\r\n", body)
  end
end

#----------------------------------------------------------------------
class HTTPAccess
  include URIModule

  HTTP_Port = 80
  attr_reader :http_version, :code, :message, :headers
  attr_reader :proxy
  attr_accessor :scheme

  def initialize(host, port=HTTP_Port, proxy=nil)
    @scheme = 'http'
    @host = host
    @port = port || HTTP_Port
    @state = :INIT
    @requests = []
    @uagent = format("HTTPAccess/0.0.4 (%s; %s)",
		    File.basename($0), 'ruby ' + VERSION)
    @proxy = if proxy then URI.create(proxy) else nil end
  end

  # connect to the server
  def connect
    if @proxy == nil
      @socket = HTTPSocket.new(@host, @port)
    else
      @socket = HTTPSocket.new(@proxy.host, @proxy.port)
    end
    @state = :WAIT
    @readbuf = ''
  end
  private :connect

  # send a request to the server
  def request(method, path=nil, header=nil, query=nil)
    connect if @state == :INIT

    # for http proxy
    if @proxy
      if @port
	path = "#{@scheme}://#{@host}:#{@port}#{path}"
      else
	path = "#{@scheme}://#{@host}#{path}"
      end
    end

    # send a request line
    @socket.putrequest(method, path)

    # send request header lines
    header = {} unless header.kind_of? Hash
    header['Host'] = @host unless header['Host']
    header['User-Agent'] = @uagent unless header['User-Agent']
    header['Connection'] = 'Keep-Alive' unless header['Connection']
    header['Accept'] = '*/*' unless header['Accept']
    header['Content-Length'] = query.size.to_s if query and !header['Content-Length']
    header.each {|k, v|
      @socket.putheader(k, v)
    }
    @socket.endheaders

    if query
      @socket.putbody(query)
    end

    @requests.push [method, path]
    @state = :META if @state == :WAIT
    @next_connection = false # XXX
  end
  private :request

  def request_get(path, header=nil, maxbytes=nil, &block)
    request('GET', path, header)
    if block
      get_response
      get_data(maxbytes, &block)
    end
  end

  def request_head(path, header=nil)
    request('HEAD', path, header)
  end

  def request_post(path, query, header=nil, maxbytes=nil, &block)
    queryStr = escape_query(query)
    request('POST', path, header, queryStr)
    if block
      get_response
      get_data(maxbytes, &block)
    end
  end

  def escape_query(query)
    data = ''
    query.each do |attr, value|
      data << '&' if !data.empty?
      data << URI.escape( attr.to_s ) << '=' << URI.escape( value.to_s )
    end
    data
  end

  # close the connection
  def close
    unless @socket.nil?
      @socket.close unless @socket.closed?
    end
    @state = :INIT
  end

  def get_response
    if @state == :DATA
      get_data {}
      check_state
    end
    raise HTTPInvalidState, 'state != :META' unless @state == :META

    req = @requests.shift

    @status_line = @socket.gets
    unless /^(HTTP(?:\/1\.\d+)?)\s+(\d\d\d)\s+(.*?)\r?$/ =~ @status_line
      raise HTTPBadResponse
    end
    @http_version = $1
    @code = $2
    @message = $3
    @next_connection = true if @http_version == 'HTTP/1.1'

    @headers = []
    until (line = @socket.gets) =~ /^\r?$/
      if line == /^\s/
	@headers[-1] << line
      else
	@headers.push line
      end
    end

    @content_length = nil
    @chunked = false
    @next_connection = false
    @headers.each {|line|
      case line
      when /^Content-Length:\s+(\d+)/i
	@content_length = Integer($1)
      when /^Transfer-Encoding:\s+chunked/i
	@chunked = true
	@content_length = 1 #XXX
	@chunk_length = 0
      when /^Connection:\s+([-\w]+)/i
	case $1
	when /^Keep-Alive$/i
	  @next_connection = true
	when /^close$/i
	  @next_connection = false
	end
      else
	#
      end
    }
    @state = :DATA
    if req[0] == 'HEAD'
      @content_length = 0
      if @next_connection
      	@state = :WAIT
      else
     	close
      end
    end

    @next_connection = false unless @content_length

    return [@http_version, @code, @message]
  end

  def get_header(&block)
    get_response if @state == :META
    # @state might be :INIT now
    #	because the session could be closed in get_response when HTTP/1.0.
    #raise HTTPInvalidState, 'state != DATA' unless @state == :DATA
    if block
      @headers.each {|line|
	block.call(line)
      }
    else
      @headers
    end
  end

  # end of file?
  def eof?
    if @content_length == 0
      true
    elsif @readbuf.length > 0
      false
    else
      @socket.closed? or @socket.eof?
    end
  end

  def get_data(maxbytes=nil, &block)
    get_response if @state == :META
    return nil if @state != :DATA
    raise HTTPInvalidState, 'state != DATA' unless @state == :DATA
    data = nil
    if block
      until eof?
	block.call(read_body(maxbytes))
      end
      data = nil	# calling with block returns nil.
    else
      data = read_body(maxbytes)
    end
    if eof?
      if @next_connection
      	@state = :WAIT
      else
      	close
      end
    end
    data
  end

  def read_body(maxbytes=nil)
    maxbytes = 512 unless maxbytes
    if @chunked
      if @chunk_length == 0
	@readbuf << @socket.gets("\r\n") until i = @readbuf.index("\r\n")
	i += 2
	if @readbuf[0, i] == "0\r\n"
	  @content_length = 0
	  @readbuf << @socket.gets("\n") unless @readbuf[0, 5] == "0\r\n\r\n"
	  @readbuf[0, 5] = ''
	  return nil
	end
	@chunk_length = @readbuf[0, i].hex
	@readbuf[0, i] = ''
      end
      while @readbuf.length < @chunk_length + 2
	@readbuf << @socket.read(@chunk_length + 2 - @readbuf.length)
      end
      data = @readbuf[0, @chunk_length]
      @readbuf[0, @chunk_length + 2] = ''
      @chunk_length = 0
      return data
    elsif @content_length == 0
      return nil
    elsif @content_length
      if @readbuf.length > 0
	data = @readbuf[0, @content_length]
	@readbuf[0, @content_length] = ''
	@content_length -= data.length
	return data
      end
      maxbytes = @content_length if maxbytes > @content_length
      data = @socket.read(maxbytes)
      if data
	@content_length -= data.length
      else
	@content_length = 0
      end
      return data
    else
      if @readbuf.length > 0
	data = @readbuf
	@readbuf = ''
	return data
      end
      data = @socket.read(maxbytes)
      return data
    end
  end
  private :read_body

  def check_state
    if @state == :DATA
      if eof?
	if @next_connection
	  if @requests.empty?
	    @state = :WAIT
	  else
	    @state = :META
	  end
	end
      end
    end
  end
  private :check_state

end

#======================================================================
if $0 == __FILE__
  urlstr = ARGV.shift or raise ArgumentError.new( 'URL was not given' )
  url = URIModule::URI.create(urlstr)
  proxy = ARGV.shift

  h = HTTPAccess.new(url.host, url.port, proxy)
  #
  puts "! get_header with block"
  h.request_head(url.path)
  h.get_response
  h.get_header {|line| print line}
  #
  puts "! get_header without block"
  h.request_head(url.path)
  h.get_response
  print h.get_header
  #
  puts "! get_data with block"
  h.request_get(url.path, 'User-Agent'=>'FooBar/1.0')
  h.get_response
  h.get_header {|line| print line}
  h.get_data(8192) {|data| print data}
  #
  puts "! get_data without block"
  h.request_get(url.path, 'User-Agent'=>'FooBar/1.0')
  h.get_response
  h.get_header {|line| print line}
  str = ""
  while ( str = h.get_data( 1024 ))
    print str
  end
  #
  puts "! post_data with block"
  query = [].push(['command', 'get'] ).push(['number', 30])
  h.request_post(url.path, query, {'User-Agent'=>'FooBar/1.0'})
  h.get_response
  h.get_header {|line| print line}
  h.get_data(8192) {|data| print data}
  #
  puts "! post_data without block"
  query = [].push(['text', '~|+_)(*&^%$#@!'] ).push(['text', nil])
  h.request_post(url.path, query, {'User-Agent'=>'FooBar/1.0'})
  h.get_response
  h.get_header {|line| print line}
  str = ""
  while ( str = h.get_data( 1024 ))
    print str
  end
  #
  h.close
end
