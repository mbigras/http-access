# Parse URLs.
class URL
  attr_reader :urlstr, :scheme, :netloc, :path, :params, :query, :fragment
  attr_reader :user, :passwd, :host, :port

  Uses_netloc = ['ftp', 'http', 'gopher', 'nntp', 'telnet', 'wais',
    'https', 'shttp', 'snews', 'prospero', '']

  Uses_login = ['ftp','http','gopher','nntp','telnet','wais',
    'prospero']

  def initialize(urlstr, scheme=nil)
    @urlstr = urlstr
    parse(urlstr, scheme)
  end

  # Parse a URL into 6 components:
  # [scheme]://[netloc]/[path];[params]?[query]#[fragment]
  def parse(url, scheme = nil, allow_fragments = true)
    @scheme = scheme
    @netloc = @params = @query = @fragment = nil
    @host = @port = nil

    if url =~ /^([-+\.\w]+):/
      @scheme, url = $1, $' #'
    end

    if url =~ /^(\/\/)?([^\/]+)/ && Uses_netloc.include?(@scheme)
      # //[netloc]
      @netloc, url = $2, $' #'
    elsif url =~ /^(\/|~)/
      @scheme = 'file'
    else
      @scheme = 'file'
    end

    # parse netloc into userinfo and hostinfo
    # for more detail, see RFC 2396 3.2.2 and Appendix A.
    if /(([^:@]*)(:([^@]*))?@)?([^:]*)(:(\d*))?/ =~ @netloc  &&
	Uses_login.include?(@scheme)
      @user, @passwd, @host, @port = $2, $4, $5, $7
    end

    if @scheme == 'http'
      i = url.rindex("#")
      if i
	url, @fragment = url[0, i], url[i+1..-1]
      end
      i = url.rindex("?")
      if i
	url, @query = url[0, i], url[i+1..-1]
      end
      i = url.rindex(";")
      if i
	url, @params = url[0, i], url[i+1..-1]
      end
    end

    @path = url
    @path = '/' if @path == ''
  end

end

if $0 == __FILE__
  u = URL.new('http://foo:var@www.hogehoge.jp:8080/hoge/fu;ni?ha#un')

  ['urlstr', 'scheme', 'netloc', 'host', 'port', 'user',
    'passwd', 'path', 'params', 'query', 'fragment'].each{|m|
    print m,": ",eval("u." + m),"\n"
  }
end
