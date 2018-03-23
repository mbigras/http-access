# rfc2396 (1738, 1808, 2368)
# $Id: uri.rb,v 3.51 2000/05/07 17:05:09 rgt Exp $

=begin
  include URIModule
  home = URI.create('http://www.ruby-lang.org/?q#f')
  puts home.scheme
  puts home['scheme']
  home.each do |key, value|
    p [key, value]
  end
  puts = home.create_relative_uri('en/whos.html')
  uri_a = URI.create('http://www02.so-net.ne.jp/~greentea/')
  uri_b = URI.create('http://www02.so-net.ne.jp:80/%7egreentea/')
  p true if uri_a == uri_b
=end 

module URIModule
=begin
  URI is a abstract class. But it has common interface to instantiate
  an URI object.

  To instanciate an ALL kind of URI object, use URI.create. DO NOT use new() to
  instanciate HTTPURL or so on.

  To escape query string, use URI#escape. (Thanx to NaHi, Wakou)
=end
  class URI
    SCHEME   = 'scheme'.freeze
    PATH     = 'path'.freeze
    QUERY    = 'query'.freeze
    FRAGMENT = 'fragment'.freeze
    USERINFO = 'userinfo'.freeze
    HOST     = 'host'.freeze
    PORT     = 'port'.freeze
    USER     = 'user'.freeze
    PASSWORD = 'password'.freeze
    TYPECODE = 'type'.freeze

    URI_SCHEMES = {}

    ##pre absolute_uri and ((relative_uri.nil? and
    ##                       absolute_uri.is_a? String) or
    ##                      (relative_uri.is_a? String and 
    ##                       (absolute_uri.is_a? String or
    ##                        absolute_uri.is_a? URI)))
    ##post const absolute_uri, const relative_uri
    ##return aURI
    ##raise URIError if absolute_uri and/or relative_uri are a bad URI
    def URI.create(absolute_uri, relative_uri=nil)
      if absolute_uri.is_a? String
	if (uri_class = URI_SCHEMES[absolute_uri.sub(/:.*/p, '').downcase])
	  absolute_uri = uri_class.new(absolute_uri)
	else
	  raise URIError, 'unknown scheme: ' + absolute_uri
	end
      end
      if relative_uri
	absolute_uri.create_relative_uri(relative_uri)
      else
	absolute_uri
      end
    end

=begin
  escape str.
  default unsafe is ^uric. see URI::Escape.pm in perl5.
  if you want to escape str for CGI, use CGI::escape.
=end
    ##pre str.is_a? String and (unsafe.nil? or unsafe.is_a? String)
    def URI.escape(str, unsafe=nil)
      if not unsafe
	str.gsub(/[^;\/?:@&=+$,0-9A-Za-z\-_.!~*'()\[\]]/) do |match|  #'
	  sprintf('%%%02X', match.unpack('C')[0])
	end
      else
	str.gsub(/[#{unsafe}]/) do |match|
	  sprintf('%%%02X', match.unpack('C')[0])
	end
      end
    end

    def URI.unescape(str)
      result = str.dup
      while /%[0-9A-Fa-f][0-9A-Fa-f]/ =~ result
	char = $&[1,2].hex.chr
	result.sub!(/%[0-9A-Fa-f][0-9A-Fa-f]/, char)
      end
      result
    end

    def initialize(uri)
      @components = {}
      if not (@components[SCHEME] = URI::URI_SCHEMES.index(type))
	raise URIError, 'internal error: unknown scheme'
      end
    end

    def [](component_name)
      @components[component_name]
    end

    def each(&block)
      @components.each do |key, value|
	block.call key, value
      end
    end

    def scheme
      @components[SCHEME]
    end

    def ==(obj)
      if obj.is_a? String
	begin
	  obj = URI.create(obj)
	rescue URIError
	  return false
	end
      end
      if type != obj.type
	return false
      end
      @components[SCHEME] == obj[SCHEME]
    end

    def dup
      result = super
      result.init(@components)
      result
    end

    ##protected
    def init(hashed_components)
      @components = {}
      hashed_components.each do |key, value|
	@components[key] = value.dup
      end
    end
    protected :init

    # escape all chars except escaped
    ##private
    def escape_all(str)
      tmp = nil
      buff = ''
      arry = str.split(//)
      i = 0
      while i < arry.size
	if arry[i] == '%'
	  (tmp = arry[0, 3].join('')).upcase!
	  if /%[0-9A-Z][0-9A-Z]/ =~ tmp
	    buff << tmp
	    i += 3
	    next
	  else
	    buff << sprintf("%%%02X", ?%)
	  end
	else
	  buff << sprintf("%%%02X", arry[i][0])
	end
	i += 1
      end
      buff
    end
    private :escape_all
  end

=begin
  GenericURI is a abstract class. Its super class is URI. Its subclasses are
  FTPURL, HTTPURL and etc.

  A instance of subclass which are subclassed from GenericURI may 
  have scheme, userinfo, host, port, path, query, and fragment.

  create_relative_uri is a instance method to create another URI instance
  relative to the receiver.
=end
  class GenericURI <URI
    def GenericURI.well_known_port  # used in ==
      '0'
    end
    
    def initialize(uri)
      super(uri)
      userinfo = host = port = path = nil
      scheme, authority, path, query, fragment = parse_generic_uri(uri)

      if authority.nil?
	raise URIError, 'undefined authority'
      end
      userinfo, host, port = parse_server(authority)
      @components[USERINFO] = userinfo if userinfo
      @components[HOST] = host
      @components[PORT] = port if port
      if not path or path == ''
	@components[PATH] = '/'
      else
	@components[PATH] = resolve_path(path)
      end
      @components[QUERY] = query if query
      @components[FRAGMENT] = fragment if fragment
    end

=begin
  parses URI string into scheme, authority, path, query, and fragment.
  scheme is not checked.
=end
    ##pre uri and uri.is_a? String
    ##post const uri
    ##return [scheme, authority, path, query, fragment]
    ##raise URIError if uri is a bad URI
    ##private
    def parse_generic_uri(uri)
      x_QUERY_FRAGMENT =
	/\A(?:[0-9A-Za-z\-_.!~*'();\/?:@&=+$,]|%[0-9A-Fa-f][0-9A-Fa-f])*\z/  #'

      if %r{\A(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?\z} !~
	uri
	#     12            3  4          5       6  7        8 9
	# scheme = $2, authority = $4, path = $5, query = $7, fragment = $9
	raise URIError('bad URI: ' + uri)
      end
      scheme = $2
      authority = $4
      path = $5
      query = $7
      fragment = $9
      # check IPv6-authority in parse-server
      if authority and /\[.*\]/ !~ authority and
	  /\A(?:[0-9A-Za-z\-_.!~*'()$,;:@&=+]|%[0-9A-Fa-f][0-9A-Fa-f])+\z/ !~
	  authority  #'
	raise URIError, 'bad authority'
      end
      # if uri starts with rel_segment, make it '/rel_segment' temporarily.
      # since a bad rel_segment is contains ':', it does not reach here.
      # even if uri contains abs_path, '/abs_path' is valid abs_path.
      # see RFC's BNF
      if path and /\A(?:(?:\/)(?:(?:[0-9A-Za-z\-_.!~*'():@&=+$,]|%[0-9A-Fa-f][0-9A-Fa-f])*(?:;(?:[0-9A-Za-z\-_.!~*'():@&=+$,]|%[0-9A-Fa-f][0-9A-Fa-f])*)*))+\z/ !~ ('/' << path)
	raise URIError, 'bad path'
      end
      if query and x_QUERY_FRAGMENT !~ query
	raise URIError, 'bad query'
      end
      if fragment and x_QUERY_FRAGMENT !~ fragment
	raise URIError, 'bad fragment'
      end
      if path == '' and (query or fragment)
	path = nil
      end
      if query == '' and fragment
	query = nil
      end
      [scheme, authority, path, query, fragment]
    end
    private :parse_generic_uri

    # userinfo@host:port
    ##private
    def parse_server(authority)
      userinfo = host = port = nil

      if /\A(?:([^@]*)@)?(\[(.+)\])(?::(.*))?\z/ =~ authority
	userinfo = $1
	host = $2
	check_IPv6_addr($3)
	port = $4
      else
	userinfo, host, port =
	  authority.scan(/\A(?:([^@]*)@)?([^:]*)(?::(.*))?\z/)[0]
	if not host or
	    /\A(?:(?:(?:(?:(?:[0-9A-Za-z]|[0-9A-Za-z][0-9A-Za-z\-]*[0-9A-Za-z])(?:\.))*)(?:[A-Za-z]|[A-Za-z][0-9A-Za-z\-]*[0-9A-Za-z])(?:\.?))|(?:\d+\.\d+\.\d+\.\d+))\z/ !~ host
	  raise URIError, 'bad host'
	end
      end
      if userinfo and
	  /\A(?:[0-9A-Za-z\-_.!~*'();:&=+$,]|%[0-9A-Fa-f][0-9A-Fa-f])*\z/ !~
	  userinfo  #'
	raise URIError, 'bad userinfo'
      end
      if port and /\A\d*\z/ !~ port
	raise URIError, 'bad port'
      end
      [userinfo, host, port]
    end
    private :parse_server

    # see RFC-2373 and RFC-2732
    def check_IPv6_addr(addr)
      mESSAGE = 'bad IPv6 address'.freeze
      arry = nil

      if addr.size < 2 or (addr[0] == ?: and addr[1] != ?:) or
	  (addr[-1] == ?: and addr[-2] != ?:) or addr.index(':::')
	raise URIError, mESSAGE
      end

      found = addr.scan(/::/).size
      if found > 1
	raise URIError, mESSAGE
      elsif found == 1
	if (arry = addr.split(':')).size > 6
	  raise URIError, mESSAGE
	end
      elsif (arry = addr.split(':')).size != 8
	raise URIError, mESSAGE
      end

      if /\A\d+(?:\.\d+){3}\z/ =~ arry[-1]
	arry.pop
      end

      arry.each do |elt|
	if /\A[0-9A-Fa-f]{0,4}\z/ !~ elt
	  raise URIError, mESSAGE
	end
      end
    end

    # resolve absolute path
    # see RFC-2396, C.2. Abnormal Examples
    ##private
    def resolve_path(path)
      apath = path.dup
      sLASH = '/'.freeze
      files = nil

      if apath == '/./' or apath == '/.' or apath == '/../' or
	  apath == '/..'
	return apath
      end

      if %r|/\.\.?\z| =~ apath
	apath << sLASH
      end

      # remove current directories
      apath.gsub!(%r|/(\./)+|, sLASH)
      if path[0] == ?/ and path[1] == ?. and path[2] == ?/
	  apath = '/.' << apath
      end

      remove_parent_dir(apath)
    end
    private :resolve_path

    # remove parent dirs from absolute path
    ##private
    def remove_parent_dir(apath)
      dOT_DOT = '..'.freeze
      result = []
      apath.split(%r|/|, -1).each do |elt|
	if elt == dOT_DOT
	  if result.size == 1 or result[-1] == dOT_DOT
	    result.push elt
	  else
	    result.pop
	  end
	else
	  result.push elt
	end
      end
      result.join('/')
    end
    private :remove_parent_dir

    def create_relative_uri(relative_uri)
      buff = nil
      scheme, authority, path, query, fragment =
	parse_generic_uri(relative_uri)
      if scheme
	raise URIError, 'bad relative uri'
      end
      if authority
	return type.new(relative_uri)
      end
      buff = @components[SCHEME] + '://'
      buff << @components[USERINFO] << '@' if @components[USERINFO]
      buff << @components[HOST]
      buff << ':' << @components[PORT] if @components[PORT]
      if path
	if path[0] == (?/)
	  return type.new(buff << relative_uri)
	else
	  return type.new(buff << @components[PATH].sub(%r|[^/]*\z|,
							relative_uri))
	end
      end
      buff << @components[PATH]
      if query
	buff.sub!(%r|[^/]*\z|, relative_uri)
	return type.new(buff)
      end
      if @components[QUERY]
	buff << '?' << @components[QUERY]
      end
      if fragment
	return type.new(buff << relative_uri)
      end
      return type.new(buff)
    end

    def host
      @components[HOST]
    end
    def path
      @components[PATH]
    end
    def port
      if @components[PORT]
	@components[PORT]
      else
	type.well_known_port
      end
    end
    def query
      @components[QUERY]
    end
    def fragment
      @components[FRAGMENT]
    end
    def userinfo
      @components[USERINFO]
    end

    def ==(obj)
      m = y = nil  # mine, yours
      if obj.is_a? String
	begin
	  obj = URI.create(obj)
	rescue URIError
	  return false
	end
      end
      if not super(obj)
	return false
      end
      if @components[USERINFO] and obj.userinfo and
	  @components[USERINFO] != obj.userinfo
	return false
      elsif @components[USERINFO] or obj.userinfo
	return false
      end
      if (m = @components[HOST].downcase) != (y = obj.host.downcase) and
	  escape_all(m) != escape_all(y)
	return false
      end
      if @components[PORT] and obj.port
	return false if @components[PORT] != obj.port
      elsif (@components[PORT] and
	     @components[PORT] != type.well_known_port) or
	  (obj.port and type.well_known_port != obj.port)
	return false
      end
      if @components[PATH] != obj.path and
	  not equal_path?(@components[PATH], obj.path)
	return false
      end
      if @components[QUERY] and obj.query
	if @components[QUERY] != obj.query and
	    escape_all(@components[QUERY]) != escape_all(obj.query)
	  return false
	end
      elsif @components[QUERY] or obj.query
	return false
      end
      if @components[FRAGMENT] and obj.fragment
	if @components[FRAGMENT] != obj.fragment and
	    escape_all(@components[FRAGMENT]) != escape_all(obj.fragment)
	  return false
	end
      elsif @components[FRAGMENT] or obj.fragment
	return false
      end
      true
    end

    ##private
    def equal_path?(path_a, path_b)
      arry_a = path_a.split('/', -1)
      arry_b = path_b.split('/', -1)
      if arry_a.size != arry_b.size
	return false
      end
      arry_a.size.times do |i|
	if arry_a[i] != arry_b[i] and
	    escape_all(arry_a[i]) != escape_all(arry_b[i])
	  return false
	end
      end
      true
    end
    private :equal_path?

    def to_s
      tmp = nil
      buff = @components[SCHEME] + '://'
      if (tmp = @components[USERINFO])
	buff << tmp << '@'
      end
      buff << @components[HOST]
      if (tmp = @components[PORT])
	buff << ':' << tmp
      end
      buff << @components[PATH]
      if (tmp = @components[QUERY])
	buff << '?' << tmp
      end
      if (tmp = @components[FRAGMENT])
	buff << '#' << tmp
      end
      buff
    end
  end

=begin
  To instanciate a FTPURL object, use URI.create.
  A FTPURL object has scheme, userinfo (user, password), host, port, path, 
  and typecode.
=end
  class FTPURL <GenericURI
    URI::URI_SCHEMES['ftp'.freeze] = self

    WELL_KNOWN_PORT = '21'.freeze

    def FTPURL.well_known_port  # used in GenericURI#==
      FTPURL::WELL_KNOWN_PORT
    end

    def initialize(absolute_uri)
      super(absolute_uri)
      if @components[USERINFO]
	if @components[USERINFO].index(':').nil?
	  raise URIError, 'bad userinfo'
	end
	@components[USER], @components[PASSWORD] =
	  @components[USERINFO].split(':', 2)
      end
      path, typecode = @components[PATH].split(';')
      if typecode
	if /\Atype=([aid])\z/ !~ typecode
	  raise URIError, 'bad type'
	end
	@components[TYPECODE] = $1
      end
      if @components[QUERY] or @components[FRAGMENT]
	raise URIError, 'bad FTP URL'
      end
    end
    
    def user
      @components[USER]
    end
    def password
      @components[PASSWORD]
    end
    def typecode
      @components[TYPECODE]
    end
  end

=begin
  To instanciate a HTTPURL object, use URI.create.
  a HTTPURL object has scheme, host, port, path, query, and fragment.
=end
  class HTTPURL <GenericURI
    URI::URI_SCHEMES['http'.freeze] = self

    WELL_KNOWN_PORT = '80'.freeze

    def HTTPURL.well_known_port  # used in GenericURI#==
      HTTPURL::WELL_KNOWN_PORT
    end

    def initialize(absolute_uri)
      super(absolute_uri)
      if @components[USERINFO]
	raise URIError, 'bad authority'
      end
    end
  end

  class URIError < StandardError
  end
end

if $0 == __FILE__
  include URIModule
  p URI.escape('http://adb/#')
end
