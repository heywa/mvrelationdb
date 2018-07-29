# -- coding: utf-8
#ENV["SSL_CERT_FILE"] = "#{Rails.root}/lib/tasks/cacert.pem"

require "open-uri"
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/dmmdvdlist"
#require "#{Rails.root}/app/models/relationlist"
require "active_record"
#require "mysql2"
require "date"
require 'net/http'
require 'uri'
require 'json'
ActiveRecord::Base.logger = Logger.new(STDOUT)

=begin
# WordPress用MysqlDB接続設定
ActiveRecord::Base.establish_connection(
adapter:  "mysql2",
host:     "localhost",
username: "root",
password: "tKTWWGsau8Wp",
database: "wpdb-01",
)
# テーブルにアクセスするためのクラスを宣言
class User < ActiveRecord::Base
    # テーブル名が命名規則に沿わない場合、
    self.table_name = 'wp_defusers'  # set_table_nameは古いから注意
end
=end
  #時間計測スタート
  start_time = Time.now
  #必要な変数定義
  #APIリクエスト用パラメータ
  #API ID
  dmmapiid="tExGq0Pm05y6Qg1bgAE1"
  #アフィリエイトID（サイトごとに採番される）
  dmmaffiliateid="unforgiven-990"
  #site:R18か一般か
  dmmsite="DMM.R18"
  #サービス:service フロアAPIから取得できるサービスコードを指定
  #通販＝"mono"
  #動画＝"digital
  dmmservice="mono"
  #フロア:floor:フロアAPIから取得できるフロアコードを指定
  #DVD="dvd"
  #動画＝"videoa"
  
  dmmfloor="dvd"
  #取得件数：hits 初期値：20　最大：100
  dmmhits=100
  #検索開始位置	offset	初期値：1　最大：50000
  dmmoffset=1
  #ソート順	sort 初期値：rank
  #新着：date
  #評価：review
  dmmsort="date"
  
  #挿入件数
  insertrec = 0
  #更新件数
  updaterec = 0
  
  #RESTされたURLからJCON形式のデータを返すメソッドを定義
  #https://qiita.com/awakia/items/bd8c1385115df27c15fa
  def get_json(location, limit = 100)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0
    uri = URI.parse(location)
    begin
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get(uri.request_uri)
    end
    case response
        when Net::HTTPSuccess
            json = response.body
            JSON.parse(json)
        when Net::HTTPRedirection
            location = response['location']
            warn "redirected to #{location}"
            get_json(location, limit - 1)
        else
            puts [uri.to_s, response.value].join(" : ")
            # handle error
    end
    rescue => e
        puts [uri.to_s, e.class, e].join(" : ")
        # handle error
    end
  end
  #APIからデータをGetするメソッドを実行
  #リクエスト用のURLを格納
for num in 0..100 do
  dmmoffset=num.to_s + '01'
  dmmrequest=%(https://api.dmm.com/affiliate/v3/ItemList?api_id=#{dmmapiid.to_s}&affiliate_id=#{dmmaffiliateid.to_s}&site=#{dmmsite.to_s}&service=#{dmmservice.to_s}&floor=#{dmmfloor.to_s}&hits=#{dmmhits.to_s}&offset=#{dmmoffset.to_s}&sort=#{dmmsort.to_s}&output=json)
  puts dmmrequest
  results=get_json(dmmrequest.to_s)
  puts results['result']['result_count']
  puts results['result']['total_count']
  parsed = results['result']['items']
  parsed.each do |item|
    #品番
    if user = Dmmdvdlist.where("dmmid = ?", item['product_id']).exists?
    p 'allreadyExist'
    user = Dmmdvdlist.where("dmmid = ?", item['product_id']).first
    updaterec = updaterec + 1
    else
    insertrec = insertrec + 1

        user=Dmmdvdlist.new
        user.dmmid=item['product_id']
        puts item['product_id']
    end
    
    #タイトル
    user.dmmtitle=item['title']
    puts item['title']
    #商品URL
    #user.itemurl=item['URL']
    puts item['URL']
    
    #商品情報URLから説明分を抜き出す
    #html = item['URL'].to_s
    #puts html
    #doc = Nokogiri::HTML(open(html))
    #dmmexplanations = doc.xpath('/html/body/table/tbody/tr/td[2]/div/table/tbody/tr/td[1]/div[4]')
    #dmmexplanations.each do |node|
    #  p node.to_html
    #end
    #dmmexplanation = doc.at('/html/body/table/tbody/tr/').to_html
    #p dmmexplanation.to_s.gsub(/(\r\n|\r|\n)/, "")
    
    #p dmmexplanation
    
    #配信日
    #instoredate:date
    user.instoredate=item['date']
    puts item['date']
  
  
    #ジャンル名
    itemgenres=item['iteminfo']['genre']
    genres=""
    if itemgenres ==nil
    else
    itemgenres.each do |genre|
       if genres==""
         genres=genre['name'].to_s
       else
         genres=genres.to_s  + "," + genre['name'].to_s
       end
    end
    end
    user.genre=genres.to_s
    puts genres.to_s
    #シリーズ名
    itemseries=item['iteminfo']['series']
    series=""
    if itemseries ==nil
    else
      series=itemseries[0]['name'].to_s
    end
    user.series=series.to_s
    puts series.to_s
    
    #女優名
    itemactress=item['iteminfo']['actress']
    actress=""
    if itemactress ==nil
    else
      itemactress.each do |hoge|
        if actress==""
           actress=hoge['name'].to_s
        else
          actress=hoge['name'].to_s + "," + actress.to_s 
        end
      end
    end
    user.actressname=actress.to_s
    puts actress.to_s
    #監督名
    itemdirector=item['iteminfo']['director']
    director=""
    if itemdirector ==nil
       else
       itemdirector.each do |hoge|
          if director==""
              director=hoge['name'].to_s
          else
              director=hoge['name'].to_s + "," + director.to_s 
          end
        end
    end
  user.direcrtorname=director.to_s
  puts director.to_s
  #メーカー名
  itemmaker=item['iteminfo']['maker']
  maker=""
  if itemmaker ==nil
  else
    maker=itemmaker[0]['name'].to_s
  end
  user.maker=maker.to_s
  puts maker.to_s
  
  #レーベル名
  itemlabel=item['iteminfo']['label']
  maker=""
  if itemlabel ==nil
  else
    label=itemlabel[0]['name'].to_s
  end
  user.label=label.to_s
  puts label.to_s
  
  #メーカー品番
  puts item['maker_product'].to_s
  user.makerid=item['maker_product'].to_s
  

  #サムネイル画像URL
  #item['iteminfo']['imageURL']['list']
  #item['iteminfo']['imageURL']['small']
  #item['iteminfo']['imageURL']['large']
  #thumburl:string
  user.thumburl=item['imageURL']['list'].to_s + ',' +  item['imageURL']['small'].to_s + ',' + item['imageURL']['large'].to_s
  puts item['imageURL']['list'].to_s + ',' +  item['imageURL']['small'].to_s + ',' + item['imageURL']['large'].to_s
  
  #アフィリエイトリンク
  #item['imageURL']['affiliateURL']
  #item['imageURL']['affiliateURLsp']
  #afiriurl:string
  user.afiriurl=item['affiliateURL'].to_s + ',' +  item['affiliateURLsp'].to_s
  puts item['affiliateURL'].to_s + ',' +  item['affiliateURLsp'].to_s
  
  
  #サンプル動画URL
  #item['sampleMovieURL']['size_476_306']
  #item['sampleMovieURL']['size_560_360']
  #item['sampleMovieURL']['size_644_414']
  #sampleMovieURL
  #sampremovieurl:string 
  itemsamplemv=item['sampleMovieURL']
  #puts item['sampleMovieURL']['size_476_306'].to_s + ',' +  item['sampleMovieURL']['size_560_360'].to_s + ',' +  item['sampleMovieURL']['size_644_414'].to_s
  samplemv=""
  if itemsamplemv ==nil
  else
    itemsamplemv.each do |hoge|
       #puts hoge[0]
       hoge.each do |hogehoge|
          if samplemv==""
            samplemv=hogehoge.to_s
          else
            samplemv=hogehoge.to_s + "," + samplemv.to_s 
          end
        end
    end
  end
  user.sampremovieurl=samplemv.to_s.gsub('[', '').gsub(']', '')
  puts samplemv.to_s.gsub('[', '').gsub(']', '')
   
  
  #サンプル画像リストURL
  #item['sampleImageURL']['sample_s']['image']
  #sampleumageurl:string
  itemimage= item['sampleImageURL']
  #p itemimage
  
  #itemimage=item['sampleImageURL']['sample_s']['image']

  images=""
  if itemimage ==nil
  else
     itemimage.each do |hoge|
       #puts hoge[0]
       hoge.each do |hogehoge|
          if images==""
            images=hogehoge['image'].to_s
          else
            images=hogehoge['image'].to_s + "," + images.to_s 
          end
        end
     end
  end

  user.images=images.to_s.gsub('[', '').gsub(']', '')
  puts images.to_s.gsub('[', '').gsub(']', '')
  #更新日時
  #空白の場合のみ更新する（Rrationck時との重複更新を避けるため）
  #updatedate:date
  if user.updatedate=nil
  else
    user.updatedate=Time.now
    puts Time.now
  end
  #レコードを保存
  user.save
#一回文のAPIリスクエストの集計が完了
 end
#指定回数分の集計が完了
end
 p "登録全件数：" + Dmmdvdlist.all.count.to_s
 p "更新件数：" + updaterec.to_s
 p "挿入件数：" + insertrec.to_s

 #処理にかかった時間を出力する
 p "処理時間 #{Time.now - start_time}s"
 