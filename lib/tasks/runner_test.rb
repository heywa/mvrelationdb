# -- coding: utf-8
ENV["SSL_CERT_FILE"] = "#{Rails.root}/lib/tasks/cacert.pem"

require "open-uri"
require 'open_uri_redirections'
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/thisavlist"
require "#{Rails.root}/app/models/relationlist"
require "#{Rails.root}/app/models/youflixlist"
require "#{Rails.root}/app/models/genrerelationlist"
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
      #時間計測スタート
      start_time = Time.now
  
      #挿入件数
      insertrec = 0
      #更新件数
      updaterec = 0
    # スクレイピングするURL。カテゴリごとに１〜８ページまでセットする
    mvgeturls = ["http://smv.to/search?keyword=&reject=&sort_key=0&opened=0&time=2&page="]
    mvgeturls.each do |mvurl|
      # スクレイピングするURL
        url = mvurl.to_s
        url2 = "http://smv.to/detail/"
        #charset = nil
        for num in 1..20 do
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
            begin
              doc2 = Nokogiri::HTML(open(html2))
            rescue
            #  deleteFLG = "ON"
              next
            end
            #doc = Nokogiri::HTML.parse(html, nil, charset)
            # タグを順番に追ってタイトルタグを抜き出す
            #個別ボケページヘのリンクURL取得
            mvexplanation = doc2.xpath('//*[@id="outline"]/main/section[1]/div[2]/div[1]/p').text.gsub(/(\r\n|\r|\n)/, "")
            p mvexplanation
            
            
=begin     20180503 サムネイルを連番で抽出するのは時間がかかりすぎるため、算出方法を変更
　　　　　20180505 やはりうまくいかず、元の手法に戻す。
            #サムネイル数計算
            #3秒につき１枚生成されると思われるため、
            #秒数を求めてから３で割る。
            
            timestr = mvplaytime.split(":")
            stimestr = Time.mktime(1970, 1, 1, 0,0, 0)
            #２４時間以上の動画が存在したため、条件を分岐させる。
            if timestr[0].to_i > 23
              mvtimestr = Time.mktime(1970, 1, (timestr[0].to_i / 24), (timestr[0].to_i % 24),timestr[1].to_i, timestr[2].to_i)              
            else  
              mvtimestr = Time.mktime(1970, 1, 1, timestr[0].to_i,timestr[1].to_i, timestr[2].to_i)
            end
            thumbnum = ((mvtimestr - stimestr) / 3).floor
=end
            
            #サムネイルを列挙。
            #サムネイルはhttp://thumb1.youflix.is/1bYHIqYTFv/animation/00003.jpg
            #の形式で連番になっているので、順にOpenURIで参照し、エラーが帰ってくるまで繰り返す。
            thumbnum = 0
            101.step(3000, 100){|num|
              url2 = 'http://img1.smv.to/' + mvurl.to_s + '/animation_' + num.to_s.rjust(5, "0") + '.jpg'
              p url2.to_s
              begin
                html = Nokogiri::HTML(open(url2))
              # 例外処理、４０４エラーが発生したら、その番号のサムネイルが存在しないとして、処理を抜ける。
              rescue
                if num == 101
                   thumbnum = num
                  else
                   thumbnum = num - 100
                end
                break
              end
            }
           
            p "Thumb number is " + thumbnum.to_s
            
            
                #テーブルにレコードを作成
                if Smvlist.where('smvid = ?', mvurl).exists?
                    p mvurl
                    #存在する場合は更新日を更新する
                    smvrec = Smvlist.where('smvid = ?', mvurl).first
                    p smvrec.smvid
                    smvrec.updatedate = Time.now
                    #2017.10.22 説明文の挿入処理を追加。既存のものもアップデートさせる
                    smvrec.explanation = mvexplanation
                    #2018.3.17 サムネイル番号の挿入を追加
                    smvrec.thumbnum = thumbnum.to_s
                    
                    smvrec.save
                    
                    puts 'update Movie'
                    updaterec = updaterec + 1
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
                    smvrec.thumbnum = thumbnum.to_s
                    smvrec.save
                    puts 'insert Movie'
                    insertrec = insertrec + 1
                end
            end
        end
    end
    p Smvlist.all.count
    #処理にかかった時間を出力する
  p "処理時間 #{Time.now - start_time}s"
  p "更新件数：" + updaterec.to_s
  p "挿入件数：" + insertrec.to_s
    end
    
    #ThisAVの動画削除メンテナンス
    def self.thisavmente
    #Smv動画リストから、更新日が古い順に取得
    mvgeturls = Thisavlist.order("updated_at")
    deleteFLG = "OFF"
    deletecount = 0
    # スクレイピングするURL。カテゴリごとに１〜８ページまでセットする
    mvgeturls.each do |mvurl|
      # スクレイピングするURL
        url2 = 'https://www.thisav.com/video/' + mvurl.thisavid.to_s + '/'
        #charset = nil
            #詳細ページのタイトルから、
            html2 = url2
            puts html2
            begin
            doc2 = Nokogiri::HTML(open(html2))
            rescue
            deleteFLG = "ON"
            next
            end
            #2018/02/04 ThisAVの場合はページが存在していても動画が存在しない場合がある。
            #ページ内容を比較し、判別する
            pagedata = doc2.xpath('//*[@id="mediaspace"]').text
            if pagedata.include?("You do not have Adobe Flash Player installed.")
            deleteFLG = "ON"  
            end 
            if deleteFLG == "ON"
                #存在しない場合は、relationlistとSmvlistから削除する
                p html2.to_s + " Not Exist.Delete!"
                #Smvlistの削除
                smvrec = Thisavlist.where('thisavid = ?', mvurl.thisavid.to_s)
                smvrec.destroy_all
                #Relationlistの削除。存在するのは１レコードのみのはず
                if Relationlist.where('tomvid = ?', mvurl.thisavid.to_s).where('relationid = ?', 'dmmtothisav').exists?
                relationrec = Relationlist.where('tomvid = ?', mvurl.thisavid.to_s)
                relationrec.destroy_all
                end
        
                #Genrerelationlistの削除。存在するのは１レコードのみのはず
                if Genrerelationlist.where('mvid = ?', mvurl.thisavid.to_s).where('medianame = ?', 'thisav').exists?
                relationrec = Genrerelationlist.where('mvid = ?', mvurl.thisavid.to_s).where('medianame = ?', 'thisav').destroy_all
                end
                    deletecount = deletecount + 1 
            else
                #ページが開けた場合は動画は存在するとし、更新日を更新する。
                p html2.to_s + " Exist"
                #存在する場合は更新日を更新する
                smvrec = Thisavlist.where('thisavid = ?', mvurl.thisavid.to_s).first
                smvrec.updatedate = Time.now
                smvrec.save
            end
    deleteFLG = "OFF"
    end
    p Thisavlist.all.count
    p "削除件数：" + deletecount.to_s
    end
    #Sharemovieの動画削除メンテナンス
    def self.smvmente
    #Smv動画リストから、更新日が古い順に取得
    mvgeturls = Smvlist.order("updated_at").limit(10000)
    deletecount = 0
    # スクレイピングするURL。カテゴリごとに１ページまでセットする
    mvgeturls.each do |mvurl|
      # スクレイピングするURL
        url2 = "http://smv.to/detail/" + mvurl.smvid.to_s
        #charset = nil
            #詳細ページのタイトルから、
            html2 = url2
            puts html2
            begin
            doc2 = Nokogiri::HTML(open(html2))
            rescue
            p html2.to_s + " Not Exist.Delete!"
            #存在しない場合は、relationlistとSmvlistから削除する
            #Smvlistの削除
            smvrec = Smvlist.where('smvid = ?', mvurl.smvid.to_s)
            smvrec.destroy_all
            #Relationlistの削除。存在するのは１レコードのみのはず
            if Relationlist.where('tomvid = ?', mvurl.smvid.to_s).where('relationid = ?', 'dmmtosmv').exists?
            relationrec = Relationlist.where('tomvid = ?', mvurl.smvid.to_s)
            relationrec.destroy_all
            end
            
            #Genrerelationlistの削除。存在するのは１レコードのみのはず
            if Genrerelationlist.where('mvid = ?', mvurl.smvid.to_s).where('medianame = ?', 'sharemovie').exists?
            relationrec = Genrerelationlist.where('mvid = ?', mvurl.smvid.to_s).destroy_all
            end
            
            
            deletecount = deletecount + 1 
            next
            end
            #ページが開けた場合は動画は存在するとし、更新日を更新する。
            #合致しない場合は
            p html2.to_s + " Exist"
            #存在する場合は更新日を更新する
            smvrec = Smvlist.where('smvid = ?', mvurl.smvid.to_s).first
            smvrec.updatedate = Time.now
            smvrec.save
    end
    p Smvlist.all.count
    p "削除件数：" + deletecount.to_s
    end
    #relationリストメンテ処理
    def self.relationmente
    #relationリストから、更新日が古い順に取得
    mvgeturls = Relationlist.where('relationid = ?', 'dmmtosmv').order("updated_at").limit(1000)
    deletecount = 0
    # スクレイピングするURL。カテゴリごとに１ページまでセットする
    mvgeturls.each do |mvurl|
      # スクレイピングするURL
        url2 = "http://smv.to/detail/" + mvurl.tomvid.to_s
        #charset = nil
            #詳細ページのタイトルから、
            html2 = url2
            puts html2
            begin
            doc2 = Nokogiri::HTML(open(html2))
            rescue
            p html2.to_s + " Not Exist.Delete!"
            #存在しない場合は、relationlistから削除する
            #Relationlistの削除。存在するのは１レコードのみのはず
            if Relationlist.where('tomvid = ?', mvurl.tomvid.to_s).where('relationid = ?', 'dmmtosmv').exists?
            relationrec = Relationlist.where('tomvid = ?', mvurl.tomvid.to_s)
            relationrec.destroy_all
            end
            
            #Genrerelationlistの削除。存在するのは１レコードのみのはず
            if Genrerelationlist.where('mvid = ?', mvurl.tomvid.to_s).where('medianame = ?', 'sharemovie').exists?
            relationrec = Genrerelationlist.where('mvid = ?', mvurl.tomvid.to_s).destroy_all
            end
            deletecount = deletecount + 1 
            next
            end
            #ページが開けた場合は動画は存在するとし、更新日を更新する。
            #合致しない場合は
            p html2.to_s + " Exist"
            #存在する場合は更新日を更新する
            #smvrec = Relationlist.where('tomvid = ?', mvurl.tomvid.to_s).first
            #smvrec.updatedate = Time.now
            #smvrec.save
    end
    p Relationlist.all.count
    p "削除件数：" + deletecount.to_s
    end
    #rerationlistメンテ２
    def self.relationmente2
    #relationリストから、PotdateがNullのものを抽出。
    mvgeturls = Relationlist.where('relationid = ?', 'dmmtosmv').where(potdate: nil)
    deletecount = 0
    # スクレイピングするURL。カテゴリごとに１ページまでセットする
    mvgeturls.each do |mvurl|
      # スクレイピングするURL
        url2 = "http://smv.to/detail/" + mvurl.tomvid.to_s
        #charset = nil
            #詳細ページのタイトルから、
            html2 = url2
            puts html2
            begin
            doc2 = Nokogiri::HTML(open(html2))
            rescue
            p html2.to_s + " Not Exist.Delete!"
            #存在しない場合は、relationlistから削除する
            #Relationlistの削除。存在するのは１レコードのみのはず
            if Relationlist.where('tomvid = ?', mvurl.tomvid.to_s).where('relationid = ?', 'dmmtosmv').exists?
            relationrec = Relationlist.where('tomvid = ?', mvurl.tomvid.to_s)
            relationrec.destroy_all
            end
            
            #Genrerelationlistの削除。存在するのは１レコードのみのはず
            if Genrerelationlist.where('mvid = ?', mvurl.tomvid.to_s).where('medianame = ?', 'sharemovie').exists?
            relationrec = Genrerelationlist.where('mvid = ?', mvurl.tomvid.to_s).destroy_all
            end
            deletecount = deletecount + 1 
            next
            end
            #ページが開けた場合は動画は存在するとし、更新日を更新する。
            #合致しない場合は
            p html2.to_s + " Exist"
            #存在する場合は更新日を更新する
            #smvrec = Relationlist.where('tomvid = ?', mvurl.tomvid.to_s).first
            #smvrec.updatedate = Time.now
            #smvrec.save
    end
    p Relationlist.all.count
    p "削除件数：" + deletecount.to_s
    end
    
    #youflix動画メンテ処理
    def self.youflixmente
    #relationリストから、更新日が古い順に取得
    mvgeturls = Youflixlist.order("updated_at").limit(100)
    deletecount = 0
    # スクレイピングするURL。カテゴリごとに１ページまでセットする
    mvgeturls.each do |mvurl|
      # スクレイピングするURL
        url2 = 'http://youflix.is/detail/' + mvurl.youflixid.to_s
        #charset = nil
            #詳細ページのタイトルから、
            html2 = url2
            puts html2
            begin
            doc2 = Nokogiri::HTML(open(html2))
            rescue
            p html2.to_s + " Not Exist.Delete!"
            
            #存在しない場合は、relationlistとyouflixlistから削除する
            #Smvlistの削除
            smvrec = Youflixlist.where('youflixid = ?', mvurl.youflixid.to_s)
            smvrec.destroy_all
            #Relationlistの削除。存在するのは１レコードのみのはず
            if Relationlist.where('tomvid = ?', mvurl.youflixid.to_s).where('relationid = ?', 'dmmtoyouflix').exists?
            relationrec = Relationlist.where('tomvid = ?', mvurl.youflixid.to_s)
            relationrec.destroy_all
            end
            
            #Genrerelationlistの削除。存在するのは１レコードのみのはず
            if Genrerelationlist.where('mvid = ?', mvurl.youflixid.to_s).where('medianame = ?', 'Youflix').exists?
            relationrec = Genrerelationlist.where('mvid = ?', mvurl.youflixid.to_s).destroy_all
            end
            deletecount = deletecount + 1 
            next
            end
            #ページが開けた場合は動画は存在するとし、更新日を更新する。
            #合致しない場合は
            p html2.to_s + " Exist"
            #存在する場合は更新日を更新する
            smvrec = Youflixlist.where('youflixid = ?', mvurl.youflixid.to_s).first
            smvrec.updatedate = Time.now
            smvrec.save
    end
    p Youflixlist.all.count
    p "削除件数：" + deletecount.to_s
    end

    
end