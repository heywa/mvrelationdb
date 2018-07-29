# -- coding: utf-8

require "open-uri"
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/relationlist"
require "active_record"
#require "mysql2"
require "date"
require 'net/http'
require 'uri'
require 'json'
#require 'levenshtein'

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

  #必要な変数定義
  #
  #Smvlist.where('smvid = ?', mvurl).exists?
  #Dmmlist.where("dmmid = ?", item['product_id']).exists?
  
  #時間計測スタート
  start_time = Time.now
  
  #dmm_mvs=Dmmlist.where('updatedate <= ?', 1.days.ago).order("created_at").limit(900)
  dmm_mvs=Dmmlist.order("updated_at").limit(25000)
  
  p dmm_mvs.all.count
  #dmm_mvs=Dmmlist.order("updatedate ASC").limit(200)
  #更新日付が古い順に１００件をチェックする
  dmm_mvs.each do |dmm_mv|
    fechcnt=0
    fechids=""
    if Smvlist.where("smvtitle like '%" + dmm_mv.dmmtitle + "%'").exists?
    #p "not include space"
    fechcnt=Smvlist.where("smvtitle like '" + dmm_mv.dmmtitle + "'").all.count
    fechids=Smvlist.where("smvtitle like '" + dmm_mv.dmmtitle + "'")
    else
    #空白があるか
    if dmm_mv.dmmtitle.include?(" ")
      # p "include space"
    ##タイトルに空白を含む場合
    #空白を区切って配列に格納
    titlestr=dmm_mv.dmmtitle.split(" ")
    fechcnt=0
    fechids=""
    #区切られた文字列を一つずつ取り出しand条件で検索
      if Smvlist.where("smvtitle like '%" + titlestr[0] + "%'").exists?
        #p titlestr[0]
      resultrec=Smvlist.where("smvtitle like '%" + titlestr[0] + "%'")
      titlestr.each do |str|
        #p str
        resultcnt=resultrec.where("smvtitle like '" + str + "%'")
        if resultcnt.all.count == 0
          #p "separate str not match"
           #０件の場合は0を挿入し、以後の文字列は確認しない
           fechcnt=0
           break
        else
           resultrec=resultrec.where("smvtitle like '%" + str + "%'")
           fechcnt=resultrec.where("smvtitle like '%" + str + "%'").all.count
           fechids=resultrec
        end
        #p fechcnt.to_s
      end
      end
    ##空白行がない場合はそのまま一致するかを検索
    else
    #p "not include space"
    fechcnt=Smvlist.where("smvtitle like '" + dmm_mv.dmmtitle + "'").all.count
    fechids=Smvlist.where("smvtitle like '" + dmm_mv.dmmtitle + "'")
    end
    end
                          
    if fechcnt==0
          #一致しない場合、更新日付のみ更新する
          relation=Dmmlist.where('dmmid = ?', dmm_mv.dmmid).first
           p "更新前更新日付:" + relation.updatedate.to_s
           relation.updatedate=Time.now
           p "更新後更新日付:" + relation.updatedate.to_s
          relation.save
          p "DmmTitle is not match"
          #p 'DmmTitle:' + dmm_mv.dmmtitle.to_s
    else
         #一致しているものがある場合、relationlistsに挿入する
          p "DmmTitle is not match"
       fechids.each do |fechid|
         #DMMから商品説明をスクレイピングして更新する２０１７／１２／２
         html = dmm_mv.afiriurl.gsub("/unforgiven-990","").split(",")
         puts html[0]
         doc = Nokogiri::HTML(open(html[0]), nil, "UTF-8")
         #p doc
         #doc = Nokogiri::HTML.parse(html, nil, charset)
         # タグを順番に追ってタイトルタグを抜き出す
         #個別ボケページヘのリンクURL取得
         #bookexp = doc.xpath("/html/body/div[2]/div/div[2]/div[2]/div[1]/div/div[2]/div[4]").inner_text
         mvexp = doc.at_xpath('//div[starts-with(@class,"mg-b20")]').inner_text
         #p mvexp
         p mvexp.encode.gsub("\n","").gsub("\t","").to_s
         #ーーーーーー
         #relationlistsに存在しているかを確認
         if relation = Relationlist.where('frommvid = ?', dmm_mv.dmmid).where('tomvid = ?', fechid.smvid).exists?
         #if Relationlist.where('frommvid = ?','tomvid = ?', dmm_mv.dmmid, fechid.smvid).exists?
           relation=Dmmlist.where('dmmid = ?', dmm_mv.dmmid).first
           #p relation.updatedate
           p "更新前更新日付:" + relation.updatedate.to_s
           relation.updatedate=Time.now
           p "更新後更新日付:" + relation.updatedate.to_s
           relation.save
           p "Relationlist not insert"
          else
            #存在しない場合は挿入する
            relation=Relationlist.new
            relation.relationid="dmmtosmv"
            relation.frommvid=dmm_mv.dmmid.to_s
            relation.tomvid=fechid.smvid.to_s
            relation.fromtitle=dmm_mv.dmmtitle.to_s
            relation.totitle=fechid.smvtitle.to_s
            relation.updatedate=Time.now
            relation.save
            #DMMテーブルの更新時間を更新する。重複して更新されることを防ぐ
            dmm_mv.updatedate=Time.now
            dmm_mv.save
            p "Relationlist insert"
         end
          p 'Smvid:' + fechid.smvid.to_s
          p 'Smvtitle:' + fechid.smvtitle.to_s
          p 'Dmmid:' + dmm_mv.dmmid.to_s
          p 'DmmTitle:' + dmm_mv.dmmtitle.to_s
       end    
    end
  end
  p "relationlist件数:" + Relationlist.all.count.to_s
  #処理にかかった時間を出力する
  p "処理時間 #{Time.now - start_time}s"
