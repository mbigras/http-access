Jun 9, 2000

    HTTPAccessクラスに， 'scheme' という accessor を追加しました．
    高橋征義さんに頂いた patch に感謝します．


Feb 20, 2000

    POSTメソッドを発行するための request_post を追加しました．
    またこれまでは url-parse.rb を使ってURLの解析を行なっていましたが，
    越水さんによる uri.rb を利用するように変更しました．
    パッケージに含まれている uri.rb は，uri.rb (Revision ID: 3.39) に対して，
    [ruby-dev:9258]のPatchを適用したものです．

    uri.rb を作成し，また快く再配布の許可をくださった越水さんに感謝します．


Feb 16, 2000

    パッケージ作成者による追記:

    http-access-0.0.4のオリジナルバージョンは，
    前橋さん(maebashi@iij.ad.jp)によって作成&配布されました．本パッケージは
    それをなひ(nakahiro@sarion.co.jp)が再配布しているものです．
    具体的には，http-access-0.0.4に対し，[ruby-list:18558]のpatchを当て，
    また日本語ドキュメントのREADMEを英訳しました（README_en.txtです．
    拙い英語ですいません．．．）．旧READMEファイルはREADME_ja.txt
    （このファイル）とrenameしました．

    本パッケージは，しばらくアップデートされなかったhttp-accessを見て，
    この素晴らしい成果をより多くの人と共有しようと，なひが勝手に作成し，
    再配布するものです．前橋さんがRuby界に復帰され次第，また前橋さんによって
    メンテナンスが為されることと思います．それまでの「つなぎ」です．^^;

    http-accessを作成，配布してくださった前橋さんに感謝します．

-*- indented-text -*-

http-access.rb
    HTTP プロトコルを取り扱うクラス。詳細は下記参照。

url-parse.rb
    URL を取り扱うためのクラス。

wcat
    サンプルプログラム。引数に URL を指定(例: wcat http://www.xxx.xx.jp/) 
    して起動すると、その内容をそのまま標準出力に出力します。

wbrowser
    サンプルプログラム。超安易 Web ブラウザ。引数に URL を指定して起動す
    ると、その HTML の内容を Ruby/Tk の TkText を使って表示します。
    (要: html-parser)

----------------------------------------------------------------------
HTTPaccess
    HTTP プロトコルによるアクセス機能を提供します。

スーパークラス:
    Object

クラスメソッド:
    new(host[, port[, proxy]])
        host で指定したホストの port で指定したポートと接続する HTTPアク
        セスオブジェクトを返します。port の省略値は 80 です。
        proxy サーバを経由したい場合は、proxy を URL 形式の文字列で指定
        します。
        例: h = HTTPaccess.new('www.netlab.co.jp', 80)
            h = HTTPaccess.new('www.netlab.co.jp', 80,
                               'http://proxy.foo.xx.jp:8080/')

メソッド:
    request_get(path)
        path に対する GET メソッドを発行します。
        例: h.request_get('/')
    request_head(path)
        path に対する HEAD メソッドを発行します。
        例: h.request_head('/')
    request_post(path, query)
        path に対する POST メソッドを発行します。queryには、
        属性ペアの配列を指定します。属性ペアは、属性名と属性値の配列です。
        例: h.request_post('/', [['value1', 'a'], ['value2', 'b']])
    get_response
        サーバからのレスポンス行を取得し、バージョン、レスポンスコード、
        レスポンスフレーズの 3つの文字列からなる配列を返します。
        例: h.get_response #=> ["HTTP/1.1", "200", "OK"]
    http_version
        最後に実行した get_response で返ってきた HTTP バージョンを返しま
        す。
    code
        最後に実行した get_response で返ってきたレスポンスコードを返しま
        す。
    message
        最後に実行した get_response で返ってきたレスポンスフレーズを返し
        ます。
    header
        最後に実行した get_response で返ってきたレスポンスに含まれるヘッ
        ダ行の配列を返します。
    get_header
        get_response を実行していなければ実行し、それに対応するサーバレ
        スポンスに含まれるヘッダ行の配列を返します。
    get_header {|line| ... }
        get_response を実行していなければ実行し、それに対応するサーバレ
        スポンスに含まれるヘッダ行を 1行づつブロックに渡します。
    eof?
        最後に実行した get_response に対応するエンティティボディを全部読
        み込み終わっている場合は true を返します。
    get_data([maxbytes])
        最後に実行した get_response に対応するエンティティボディを、最大
        maxbytes 単位で読み込みます。エンティティボディを最後まで読み込
        んでさらに読み込もうとすると nil を返します。maxbytes のデフォル
        ト値は 512 です。
        例: until eof?; data << get_data; end
    get_data([maxbytes]) {|data| ... }
    get_data([maxbytes], callback)
        get_response を実行していなければ実行し、それに対応するエンティ
        ティボディを、最大 maxbytes 単位で読み込み、callback で示される
        Proc オブジェクトあるいはブロックに渡します。

----------------------------------------------------------------------
URL
    URL を取り扱う

スーパークラス:
    Object

クラスメソッド:
    new(str)
        文字列 str を URL とみなし、以下の 6つの要素に分解します。
        [scheme]://[netloc]/[path];[params]?[query]#[fragment]
        各要素は以下のメソッドで参照できます。

メソッド:
    scheme
    netloc
    path
    params
    query
    fragment
        URL の各要素の値を返します。
