# -- coding: utf-8

require "open-uri"
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/youflixlist"
require "#{Rails.root}/app/models/relationlist"
require "#{Rails.root}/app/models/genrerelationlist"
require "active_record"
#require "mysql2"
ActiveRecord::Base.logger = Logger.new(STDOUT)

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
  #Youflixlist.where('smvid = ?', mvurl).exists?
  #Dmmlist.where("dmmid = ?", item['product_id']).exists?
  
  #時間計測スタート
  start_time = Time.now
  #update件数格納
  updatecnt = 0
  #insert件数格納
  insertcnt = 0
  
  
  
  #検索対象メディア（サイト名）
  mediasitename = ""
  
  #検索ジャンルキーワード格納
  genrerelationword = "アニメ"
  
  #検索キーワード格納
  searchkeywords = ["アニメ"
                    ]
  
  #設定されたキーワードをループさせて検索
  searchkeywords.each do |searchkeyword|
    p "検索ワード：" + searchkeyword.to_s + "」検索開始"
    fechcnt=0
    fechids=""
    #Sharemovie検索処理開始
    mediasitename = "sharemovie"
    if Smvlist.where("smvtitle like ? or  tags like ? or  explanation like ?", "%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%").exists?
    #p "not include space"
    fechcnt=Smvlist.where("smvtitle like ? or  tags like ? or  explanation like ?", "%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%").all.count
    fechids=Smvlist.where("smvtitle like ? or  tags like ? or  explanation like ?", "%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%")
        fechids.each do |fechid|
        #無修正ものはなるべく回避する
        #if fechid.smvtitle.to_s.include?("無修正") || fechid.tags.to_s.include?("無修正")
        #  next
        #end
        #if fechid.smvtitle.to_s.include?("（無）") || fechid.tags.to_s.include?("（無）")
        #  next
        #end
        #if fechid.smvtitle.to_s.include?("(無)") || fechid.tags.to_s.include?("(無)")
        #  next
        #end

            if Genrerelationlist.where('mvid = ?', fechid.smvid).where('genrerelationid = ?', genrerelationword).where('medianame = ?', mediasitename).exists?
            #すでにテーブルに登録済みの場合は何もしない。
            p fechid.smvid.to_s + "is already exist skip!"
            updatecnt = updatecnt + 1
            else
            #テーブルに存在しない場合は情報をGenrerelationlistに挿入していく
            user = Genrerelationlist.new
            user.mvid = fechid.smvid
            user.genrerelationid = genrerelationword
            user.medianame = mediasitename
            user.keyword = searchkeyword
            user.save
            p fechid.smvid.to_s + "is already exist skip!"
            insertcnt = insertcnt + 1
            end
        end
    else
    end
    #---------Sharemovie検索結果格納完了ｰｰｰｰｰｰ
    #Youflix検索処理開始
    mediasitename = "Youflix"
    if Youflixlist.where("youflixtitle like ? or  tags like ? or  explanation like ?", "%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%").exists?
    #p "not include space"
    fechcnt=Youflixlist.where("youflixtitle like ? or  tags like ? or  explanation like ?", "%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%").all.count
    fechids=Youflixlist.where("youflixtitle like ? or  tags like ? or  explanation like ?", "%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%","%#{searchkeyword.to_s}%")
        fechids.each do |fechid|
        #無修正ものはなるべく回避する
        if fechid.youflixtitle.to_s.include?("無修正") || fechid.tags.to_s.include?("無修正")
          next
        end
        if fechid.youflixtitle.to_s.include?("（無）") || fechid.tags.to_s.include?("（無）")
          next
        end
        if fechid.youflixtitle.to_s.include?("(無)") || fechid.tags.to_s.include?("(無)")
          next
        end

            if Genrerelationlist.where('mvid = ?', fechid.youflixid).where('genrerelationid = ?', genrerelationword).where('medianame = ?', mediasitename).exists?
            #すでにテーブルに登録済みの場合は何もしない。
            p fechid.youflixid.to_s + "is already exist skip!"
            updatecnt = updatecnt + 1
            else
            #テーブルに存在しない場合は情報をGenrerelationlistに挿入していく
            user = Genrerelationlist.new
            user.mvid = fechid.youflixid
            user.genrerelationid = genrerelationword
            user.medianame = mediasitename
            user.keyword = searchkeyword
            user.save
            p fechid.youflixid.to_s + "is already exist skip!"
            insertcnt = insertcnt + 1
            end
        end
    else
    end
    #---------Youflix検索結果格納完了ｰｰｰｰｰｰ

  end
  p "relationlist件数:" + Genrerelationlist.all.count.to_s
  #処理にかかった時間を出力する
  p "処理時間 #{Time.now - start_time}s"
  p "挿入件数：" + insertcnt.to_s
  p "更新件数：" + updatecnt.to_s
  
