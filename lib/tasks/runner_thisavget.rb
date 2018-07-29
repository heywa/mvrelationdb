# -- coding: utf-8
ENV["SSL_CERT_FILE"] = "#{Rails.root}/lib/tasks/cacert.pem"

require "open-uri"
require 'open_uri_redirections'
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/thisavlist"
#require "#{Rails.root}/app/models/relationlist"
require "active_record"
#require "mysql2"
require "date"
require 'net/http'
require 'net/https'
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

    # スクレイピングするURL。カテゴリごとに１〜８ページまでセットする
    mvgeturls = ['https://www.thisav.com/search?o=mr&type=&c=28&t=a&query=&for=videos&r=&min=30&max=&page=']
    mvgeturls.each do |mvurl|
      # スクレイピングするURL
        url = mvurl.to_s
        url2 = "https://www.thisav.com/video/"
        #charset = nil
        for num in 1..300 do
            html = url.to_s + num.to_s
            puts html
            doc = Nokogiri::HTML(open(html))
            p doc.text.to_s
            #doc = Nokogiri::HTML.parse(html, nil, charset)
            # タグを順番に追ってタイトルタグを抜き出す
              mvbox = doc.xpath('//*[@id="content"]/div[1]/div[2]/div[*]/a')
            mvbox.each do |node|
            #コンテナ内のタイトル  
            
            mvid = node.xpath('img').attribute('id').text.gsub("rotate_","").to_s
            p mvid

            #詳細ページから説明文を取得
            html2 = 'https://www.thisav.com/video/' + mvid.to_s + '/'
            puts html2
            doc2 = Nokogiri::HTML(open(html2))
            #doc = Nokogiri::HTML.parse(html, nil, charset)
            #個別動画ページからタイトルを取得
            str = doc2.xpath('/html/head/title').text.split(" - 視頻 -")
            mvtitle = str[0]
            p mvtitle
            
            mvtag = doc2.xpath('//*[@id="video_tags"]/a').text.strip
            p mvtag
            
                  
                #テーブルにレコードを作成
                if Thisavlist.where('thisavid = ?', mvid).exists?
                    #存在する場合は更新日を更新する
                    thisavrec = Thisavlist.where('thisavid = ?', mvid).first
                    p thisavrec.thisavid
                    thisavrec.updatedate = Time.now
                    thisavrec.tags = mvtag
                    thisavrec.save
                    
                    puts 'update Movie'
                else
                    #存在しない場合は登録する
                    thisavrec = Thisavlist.new 
                    thisavrec.thisavid = mvid
                    thisavrec.thisavtitle =  mvtitle
                    thisavrec.thisavurl =  html2
                    thisavrec.tags = mvtag
                    thisavrec.updatedate = Time.now
                    thisavrec.save
                    puts 'insert Movie'
                end
            end
        end
    end
p Thisavlist.all.count
