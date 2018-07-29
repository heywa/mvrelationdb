# -- coding: utf-8
ENV["SSL_CERT_FILE"] = "#{Rails.root}/lib/tasks/cacert.pem"

require "open-uri"
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
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


class Tasks::RunnerTest
    def self.smvget
    # スクレイピングするURL。カテゴリごとに１〜８ページまでセットする
    mvgeturls = ["http://smv.to/search?keyword=&reject=&opened=0&time=3&page="]
    mvgeturls.each do |mvurl|
      # スクレイピングするURL
        url = mvurl.to_s
        url2 = "http://smv.to/detail/"
        #charset = nil
        for num in 1..4 do
            html = url + num.to_s
            puts html
            doc = Nokogiri::HTML(open(html))
            #doc = Nokogiri::HTML.parse(html, nil, charset)
            # タグを順番に追ってタイトルタグを抜き出す
            #個別ボケページヘのリンクURL取得
              mvbox = doc.xpath('//*[starts-with(@id, "mylist_")]')
            mvbox.each do |node|
            #コンテナ内のタイトル  
            mvtitle = node.xpath('div[2]/h2/a').text
            p mvtitle            
            #コンテナ内のURL
            mvurl = node.xpath('div[2]/h2/a')[0][:href].gsub("/detail/", "")
            p mvurl

            #コンテナ内の日付 
            mvupdate = node.xpath('div[2]/ul/li[1]').text
            p mvupdate
            #コンテナ内の再生時間
            mvplaytime = node.xpath('div[1]/a/time').text
            p mvplaytime
            #コンテナ内のタグ
            mvtags = ""
            node.xpath('div[2]/p[2]/a').each{|anchor|
             p anchor.text.to_s
             mvtags = anchor.text.to_s + "," + mvtags.to_s  
            }
            p mvtags.to_s
            #詳細ページから説明文を取得
            html2 = 'http://smv.to/detail/' + mvurl.to_s
            puts html2
            doc2 = Nokogiri::HTML(open(html2))
            #doc = Nokogiri::HTML.parse(html, nil, charset)
            # タグを順番に追ってタイトルタグを抜き出す
            #個別ボケページヘのリンクURL取得
            mvexplanation = doc2.xpath('//*[@id="outline"]/main/section[1]/div[2]/div[1]/p').text.gsub(/(\r\n|\r|\n)/, "")
            p mvexplanation
            
            
                #テーブルにレコードを作成
                if Smvlist.where('smvid = ?', mvurl).exists?
                    p mvurl
                    #存在する場合は更新日を更新する
                    smvrec = Smvlist.where('smvid = ?', mvurl).first
                    p smvrec.smvid
                    smvrec.updatedate = Time.now
                    #2017.10.22 説明文の挿入処理を追加。既存のものもアップデートさせる
                    smvrec.explanation = mvexplanation
                    
                    smvrec.save
                    
                    puts 'update Movie'
                else
                    #存在しない場合は登録する
                    smvrec = Smvlist.new 
                    smvrec.smvid = mvurl
                    smvrec.smvtitle =  mvtitle
                    smvrec.smvupdate = mvupdate
                    smvrec.tags = mvtags
                    smvrec.smvtime = mvplaytime
                    smvrec.smvurl = url2 + mvurl.to_s
                    smvrec.updatedate = Time.now
                    smvrec.explanation = mvexplanation
                    smvrec.save
                    puts 'insert Movie'
                end
            end
        end
    end
    p Smvlist.all.count
    end
end