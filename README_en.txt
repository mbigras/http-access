Jun 9, 2000

    Added 'scheme' accessor to the class HTTPAccess according to private patch
    by Mr. TAKAHASHI Masayoshi.


Feb 20, 2000

    Add the method 'request_post' for sending the POST request.

    Use 'uri.rb' instead of 'url-parse.rb' for parsing URI string. 'uri.rb' in
    this package was packed after added the patch [ruby-dev:9258].

    I would like to thank Mr. Tomoyuki Koshimizu (greentea@fa2.so-net.ne.jp)
    who made and distribute uri.rb.


Feb 16, 2000

    Translator's note:

    Original version of 'http-access-0.0.4' was made and distributed by
    Mr. Takahiro Maehashi (maebashi@iij.ad.jp).  This package was packed by
    NaHi (nakahiro@sarion.co.jp) after added the patch [ruby-list:18558] and
    translated the Japanese document 'README' into 'README_en.txt'(this file)
    (Sorry for my poor English...). Original document 'README' was renamed to
    'README_ja.txt'.

    I would like to thank Mr. Takahiro Maehashi (maebashi@iij.ad.jp) who made
    and distribute http-access.

-*- indented-text -*-

http-access.rb
    Handles HTTP protocol.

url-parse.rb
    Handles URL.

wcat
    A sample program using http-access.rb to retrieve the specified page and
    output it to STDOUT (aka cat).
    Try '% wcat http://www.xxx.xx.jp/'.

wbrowser
    Another sample.  Simple text-base web browser using TkText of Ruby/Tk.
    Try '% wbrowser http://www.xxx.xx.jp/'.
    Requires 'html-parser' module in
    ftp://ftp.netlab.co.jp//pub/lang/ruby/contrib.

----------------------------------------------------------------------
HTTPaccess
    The class for accessing the Internet via HTTP.

SuperClass:
    Object

Class Methods:
    new(host[, port[, proxy]])
        Creates and returns a object to access the HTTP server on the 'port'
        of the 'host'.  The default value for the 'port' is 80.  If 'proxy' is
        passed, use 'proxy' as HTTP proxy.
        ex.: h = HTTPaccess.new('www.netlab.co.jp', 80)
             h = HTTPaccess.new('www.netlab.co.jp', 80,
                               'http://proxy.foo.xx.jp:8080/')

Methods:
    request_get(path)
        Sends the GET request to the 'path'.
        ex.: h.request_get('/')

    request_head(path)
        Sends the HEAD request to the 'path'.
        ex.: h.request_head('/')

    request_post(path, query)
        Sends the POST request to the 'path' with 'query'.  'query' is the
        array of Attribute Pair which is the array of Name and Value.
        ex.: h.request_post('/', [['value1', 'a'], ['value2', 'b']])

    get_response
        Receives Status-Line from the server and returns the array containing
        the HTTP-Version, Status-Code, and Reason-Phrase.
        ex.: h.get_response #=> ["HTTP/1.1", "200", "OK"]

    http_version
        Returns HTTP-Version which received by the last 'get_response'.

    code
        Returns Status-Code which received by the last 'get_response'.

    message
        Returns Reason-Phrase which received by the last 'get_response'.

    header
        Returns the array of Status-Line which received by the last
        'get_response'.

    get_header
        Returns the array of Status-Line which received by the last
        'get_response'.  If the method is called before 'get_response',
        execute it automatically.

    get_header {|line| ... }
        Iterates the block over each line of Response Header Fields which
        received by the last 'get_response'.  If the method is called before
        'get_response', execute it automatically.

    eof?
        Returns true if Message Body of the last 'getget_response' is read.

    get_data([maxbytes])
        Attempts to read 'maxbytes' of Message Body of the last 'get_response'.
        The default value of the 'maxbytes' is 512. Returns nil at the end of
        Message Body.
        ex.: until eof?; data << get_data; end

    get_data([maxbytes]) {|data| ... }
    get_data([maxbytes], callback)
        Iterates the block or the proc object 'callback' over each read data
        which is the part of Message Body.  If the method is called before
        'get_response', execute it automatically.

----------------------------------------------------------------------
URL
    The class to handle URL.

SuperClass:
    Object

Class Methods:
    new(str)
        Splits 'str' into 6 parts of URL.
        [scheme]://[netloc]/[path];[params]?[query]#[fragment]

Methods:
    scheme
    netloc
    path
    params
    query
    fragment
        Returns the part of the URL.
