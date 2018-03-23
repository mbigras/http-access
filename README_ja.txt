Jun 9, 2000

    HTTPAccess$B%/%i%9$K!$(B 'scheme' $B$H$$$&(B accessor $B$rDI2C$7$^$7$?!%(B
    $B9b66@,5A$5$s$KD:$$$?(B patch $B$K(B$B46<U$7$^$9!%(B


Feb 20, 2000

    POST$B%a%=%C%I$rH/9T$9$k$?$a$N(B request_post $B$rDI2C$7$^$7$?!%(B
    $B$^$?$3$l$^$G$O(B url-parse.rb $B$r;H$C$F(BURL$B$N2r@O$r9T$J$C$F$$$^$7$?$,!$(B
    $B1[?e$5$s$K$h$k(B uri.rb $B$rMxMQ$9$k$h$&$KJQ99$7$^$7$?!%(B
    $B%Q%C%1!<%8$K4^$^$l$F$$$k(B uri.rb $B$O!$(Buri.rb (Revision ID: 3.39) $B$KBP$7$F!$(B
    [ruby-dev:9258]$B$N(BPatch$B$rE,MQ$7$?$b$N$G$9!%(B

    uri.rb $B$r:n@.$7!$$^$?2w$/:FG[I[$N5v2D$r$/$@$5$C$?1[?e$5$s$K46<U$7$^$9!%(B


Feb 16, 2000

    $B%Q%C%1!<%8:n@.<T$K$h$kDI5-(B:

    http-access-0.0.4$B$N%*%j%8%J%k%P!<%8%g%s$O!$(B
    $BA066$5$s(B(maebashi@iij.ad.jp)$B$K$h$C$F:n@.(B&$BG[I[$5$l$^$7$?!%K\%Q%C%1!<%8$O(B
    $B$=$l$r$J$R(B(nakahiro@sarion.co.jp)$B$,:FG[I[$7$F$$$k$b$N$G$9!%(B
    $B6qBNE*$K$O!$(Bhttp-access-0.0.4$B$KBP$7!$(B[ruby-list:18558]$B$N(Bpatch$B$rEv$F!$(B
    $B$^$?F|K\8l%I%-%e%a%s%H$N(BREADME$B$r1QLu$7$^$7$?!J(BREADME_en.txt$B$G$9!%(B
    $B@[$$1Q8l$G$9$$$^$;$s!%!%!%!K!%5l(BREADME$B%U%!%$%k$O(BREADME_ja.txt
    $B!J$3$N%U%!%$%k!K$H(Brename$B$7$^$7$?!%(B

    $BK\%Q%C%1!<%8$O!$$7$P$i$/%"%C%W%G!<%H$5$l$J$+$C$?(Bhttp-access$B$r8+$F!$(B
    $B$3$NAG@2$i$7$$@.2L$r$h$jB?$/$N?M$H6&M-$7$h$&$H!$$J$R$,>!<j$K:n@.$7!$(B
    $B:FG[I[$9$k$b$N$G$9!%A066$5$s$,(BRuby$B3&$KI|5"$5$l<!Bh!$$^$?A066$5$s$K$h$C$F(B
    $B%a%s%F%J%s%9$,0Y$5$l$k$3$H$H;W$$$^$9!%$=$l$^$G$N!V$D$J$.!W$G$9!%(B^^;

    http-access$B$r:n@.!$G[I[$7$F$/$@$5$C$?A066$5$s$K46<U$7$^$9!%(B

-*- indented-text -*-

http-access.rb
    HTTP $B%W%m%H%3%k$r<h$j07$&%/%i%9!#>\:Y$O2<5-;2>H!#(B

url-parse.rb
    URL $B$r<h$j07$&$?$a$N%/%i%9!#(B

wcat
    $B%5%s%W%k%W%m%0%i%`!#0z?t$K(B URL $B$r;XDj(B($BNc(B: wcat http://www.xxx.xx.jp/) 
    $B$7$F5/F0$9$k$H!"$=$NFbMF$r$=$N$^$^I8=`=PNO$K=PNO$7$^$9!#(B

wbrowser
    $B%5%s%W%k%W%m%0%i%`!#D60B0W(B Web $B%V%i%&%6!#0z?t$K(B URL $B$r;XDj$7$F5/F0$9(B
    $B$k$H!"$=$N(B HTML $B$NFbMF$r(B Ruby/Tk $B$N(B TkText $B$r;H$C$FI=<($7$^$9!#(B
    ($BMW(B: html-parser)

----------------------------------------------------------------------
HTTPaccess
    HTTP $B%W%m%H%3%k$K$h$k%"%/%;%95!G=$rDs6!$7$^$9!#(B

$B%9!<%Q!<%/%i%9(B:
    Object

$B%/%i%9%a%=%C%I(B:
    new(host[, port[, proxy]])
        host $B$G;XDj$7$?%[%9%H$N(B port $B$G;XDj$7$?%]!<%H$H@\B3$9$k(B HTTP$B%"%/(B
        $B%;%9%*%V%8%'%/%H$rJV$7$^$9!#(Bport $B$N>JN,CM$O(B 80 $B$G$9!#(B
        proxy $B%5!<%P$r7PM3$7$?$$>l9g$O!"(Bproxy $B$r(B URL $B7A<0$NJ8;zNs$G;XDj(B
        $B$7$^$9!#(B
        $BNc(B: h = HTTPaccess.new('www.netlab.co.jp', 80)
            h = HTTPaccess.new('www.netlab.co.jp', 80,
                               'http://proxy.foo.xx.jp:8080/')

$B%a%=%C%I(B:
    request_get(path)
        path $B$KBP$9$k(B GET $B%a%=%C%I$rH/9T$7$^$9!#(B
        $BNc(B: h.request_get('/')
    request_head(path)
        path $B$KBP$9$k(B HEAD $B%a%=%C%I$rH/9T$7$^$9!#(B
        $BNc(B: h.request_head('/')
    request_post(path, query)
        path $B$KBP$9$k(B POST $B%a%=%C%I$rH/9T$7$^$9!#(Bquery$B$K$O!"(B
        $BB0@-%Z%"$NG[Ns$r;XDj$7$^$9!#B0@-%Z%"$O!"B0@-L>$HB0@-CM$NG[Ns$G$9!#(B
        $BNc(B: h.request_post('/', [['value1', 'a'], ['value2', 'b']])
    get_response
        $B%5!<%P$+$i$N%l%9%]%s%99T$r<hF@$7!"%P!<%8%g%s!"%l%9%]%s%9%3!<%I!"(B
        $B%l%9%]%s%9%U%l!<%:$N(B 3$B$D$NJ8;zNs$+$i$J$kG[Ns$rJV$7$^$9!#(B
        $BNc(B: h.get_response #=> ["HTTP/1.1", "200", "OK"]
    http_version
        $B:G8e$K<B9T$7$?(B get_response $B$GJV$C$F$-$?(B HTTP $B%P!<%8%g%s$rJV$7$^(B
        $B$9!#(B
    code
        $B:G8e$K<B9T$7$?(B get_response $B$GJV$C$F$-$?%l%9%]%s%9%3!<%I$rJV$7$^(B
        $B$9!#(B
    message
        $B:G8e$K<B9T$7$?(B get_response $B$GJV$C$F$-$?%l%9%]%s%9%U%l!<%:$rJV$7(B
        $B$^$9!#(B
    header
        $B:G8e$K<B9T$7$?(B get_response $B$GJV$C$F$-$?%l%9%]%s%9$K4^$^$l$k%X%C(B
        $B%@9T$NG[Ns$rJV$7$^$9!#(B
    get_header
        get_response $B$r<B9T$7$F$$$J$1$l$P<B9T$7!"$=$l$KBP1~$9$k%5!<%P%l(B
        $B%9%]%s%9$K4^$^$l$k%X%C%@9T$NG[Ns$rJV$7$^$9!#(B
    get_header {|line| ... }
        get_response $B$r<B9T$7$F$$$J$1$l$P<B9T$7!"$=$l$KBP1~$9$k%5!<%P%l(B
        $B%9%]%s%9$K4^$^$l$k%X%C%@9T$r(B 1$B9T$E$D%V%m%C%/$KEO$7$^$9!#(B
    eof?
        $B:G8e$K<B9T$7$?(B get_response $B$KBP1~$9$k%(%s%F%#%F%#%\%G%#$rA4ItFI(B
        $B$_9~$_=*$o$C$F$$$k>l9g$O(B true $B$rJV$7$^$9!#(B
    get_data([maxbytes])
        $B:G8e$K<B9T$7$?(B get_response $B$KBP1~$9$k%(%s%F%#%F%#%\%G%#$r!":GBg(B
        maxbytes $BC10L$GFI$_9~$_$^$9!#%(%s%F%#%F%#%\%G%#$r:G8e$^$GFI$_9~(B
        $B$s$G$5$i$KFI$_9~$b$&$H$9$k$H(B nil $B$rJV$7$^$9!#(Bmaxbytes $B$N%G%U%)%k(B
        $B%HCM$O(B 512 $B$G$9!#(B
        $BNc(B: until eof?; data << get_data; end
    get_data([maxbytes]) {|data| ... }
    get_data([maxbytes], callback)
        get_response $B$r<B9T$7$F$$$J$1$l$P<B9T$7!"$=$l$KBP1~$9$k%(%s%F%#(B
        $B%F%#%\%G%#$r!":GBg(B maxbytes $BC10L$GFI$_9~$_!"(Bcallback $B$G<($5$l$k(B
        Proc $B%*%V%8%'%/%H$"$k$$$O%V%m%C%/$KEO$7$^$9!#(B

----------------------------------------------------------------------
URL
    URL $B$r<h$j07$&(B

$B%9!<%Q!<%/%i%9(B:
    Object

$B%/%i%9%a%=%C%I(B:
    new(str)
        $BJ8;zNs(B str $B$r(B URL $B$H$_$J$7!"0J2<$N(B 6$B$D$NMWAG$KJ,2r$7$^$9!#(B
        [scheme]://[netloc]/[path];[params]?[query]#[fragment]
        $B3FMWAG$O0J2<$N%a%=%C%I$G;2>H$G$-$^$9!#(B

$B%a%=%C%I(B:
    scheme
    netloc
    path
    params
    query
    fragment
        URL $B$N3FMWAG$NCM$rJV$7$^$9!#(B
