# -- coding: utf-8
ENV["SSL_CERT_FILE"] = "#{Rails.root}/lib/tasks/cacert.pem"

require "open-uri"
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/thisavlist"
require "#{Rails.root}/app/models/youflixlist"
#require "#{Rails.root}/app/models/relationlist"
require "active_record"
#require "mysql2"
require "date"
require 'net/http'
require 'uri'
require 'json'


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
  
    #挿入件数
    insertrec = 0
    #更新件数
    updaterec = 0
    
    #サムネイル数カウント用変数
    thumbnum = 0


    # スクレイピングするURL。指定したURLを順にスクレイピングする。
    mvgeturls = ["https://www.thisav.com/video/"]
    mvgeturls.each do |mvurl|
      # スクレイピングするURL
        url = mvurl.to_s
        #url2 = "http://www.thisav.com/video/"
        #charset = nil
        #1-指定したページまでスクレイピングする。
            html = url
            puts html
            doc = Nokogiri::HTML(open(html))
            p doc.text
            #doc = Nokogiri::HTML.parse(html, nil, charset)
            # タグを順番に追ってタイトルタグを抜き出す
            mvbox = doc.xpath('//*[@id="wrap"]/main/section[1]/div[2]/article[*]')
            #mvbox = doc.xpath('//div[@class="infobox"]/h2')
        mvbox.each do |node|
            #p node
            #コンテナ内のID格納
            #mvid = node.xpath('div[2]/h2').text.gsub("/detail/","").to_s
            mvid = node.xpath('div[@class="infobox"]/h2').css("a")[0][:href].gsub("/detail/","").to_s
            p mvid.to_s
            #再生時間を格納
            mvtime = node.xpath('div[@class="thumbbox"]').css("time")[0].text.to_s
            p mvtime.to_s
            
            #再生時間が１５分以下の場合はスキップする
            timestr = mvtime.split(":")
            timesum =  timestr[0].to_i * 3600 + timestr[1].to_i * 60 +  + timestr[2].to_i
            if timesum < 900
               p 'Time is ' +  timesum.to_s
               p mvid.to_s + "is too short. Skip!"
               next
             else
               p mvid.to_s + "is Longer than 15minute. Continue!"
            end
            
            #コンテナ内のタイトル格納
            mvtitle =  node.xpath('div[@class="infobox"]/h2').css("a")[0].text.to_s.gsub(/(\r\n|\r|\n)/, "")
            p mvid.to_s
            p mvtitle.to_s
            
            #サムネイルを列挙。
            #サムネイルはhttp://thumb1.youflix.is/1bYHIqYTFv/animation/00003.jpg
            #の形式で連番になっているので、順にOpenURIで参照し、エラーが帰ってくるまで繰り返す。
            1.step(3000, 100){|num|
              url = 'http://thumb1.youflix.is/' + mvid.to_s + '/animation/' + num.to_s.rjust(5, "0") + '.jpg'
              p url.to_s
              begin
                html = Nokogiri::HTML(open(url))
              # 例外処理、４０４エラーが発生したら、その番号のサムネイルが存在しないとして、処理を抜ける。
              rescue
              thumbnum = num - 100
                break
              end
            }
            p "Thumb number is " + thumbnum.to_s
            
            #詳細ページから説明文を取得。
            
            url = 'http://youflix.is/detail/' + mvid.to_s
            p url.to_s
            begin
              html = Nokogiri::HTML(open(url))
            # 例外処理、４０４エラーが発生したら、その番号のサムネイルが存在しないとして、処理を抜ける。
            rescue
              skip
            end
            
            mvexplanation = html.xpath('//*[@id="detail_main"]/section[1]/div[3]/p[2]').text.gsub(/(\r\n|\r|\n)/, "")
            p mvexplanation.to_s
            
            mvtaginfo = ""
            mvtaginfos = html.xpath('//*[@id="detail_main"]/section[1]/div[3]/div/ul/li[*]')
            mvtaginfos.each do |tagstr|
              mvtaginfo << tagstr.text.to_s + ","
            end
            p mvtaginfo.to_s
            
            
            
        end
    end
#処理にかかった時間を出力する
p "処理時間 #{Time.now - start_time}s"
p "更新件数：" + updaterec.to_s
p "挿入件数：" + insertrec.to_s