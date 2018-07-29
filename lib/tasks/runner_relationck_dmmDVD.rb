# -- coding: utf-8

require "open-uri"
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/relationlist"
require "#{Rails.root}/app/models/thisavlist"
require "#{Rails.root}/app/models/youflixlist"
require "#{Rails.root}/app/models/dmmdvdlist"
require "#{Rails.root}/app/models/relationlist"
require "active_record"
#require "mysql2"
require "date"
require 'net/http'
require 'uri'
require 'json'
#require 'levenshtein'
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
  #sharemovie用relationlist登録処理
  def smvdmmrelation(dmmdvdid,updatecnt,insertcnt)
   if Smvlist.where("smvtitle like ? or tags like ? or smvtitle like ? or tags like ?" , "%#{dmmdvdid}%","%#{dmmdvdid}%","%#{dmmdvdid.gsub("-","")}%","%#{dmmdvdid.gsub("-","")}%").exists?
        recs = Smvlist.where("smvtitle like ? or tags like ? or smvtitle like ? or tags like ?" , "%#{dmmdvdid}%","%#{dmmdvdid}%","%#{dmmdvdid.gsub("-","")}%","%#{dmmdvdid.gsub("-","")}%")
        recs.each do |rec|
           rec.smvid.to_s
           #Relationlistに存在するかを確認
           if Relationlist.where('tomvid = ?', rec.smvid.to_s).where('relationid = ?', "dmmtosmv").exists?
            #すでに存在する場合はスキップ
            updatecnt = updatecnt + 1
           else
            #存在しない場合はrelationlistに登録する
            #登録するため、Dmmlistから同タイトルのIDを取得する。
            mvtitle =  Dmmdvdlist.where('makerid = ?', dmmdvdid).first
                #DVDに登録されていても、動画に登録されていない場合があるので判別する
                if Dmmlist.where('dmmtitle = ?', mvtitle.dmmtitle).exists?
                   dmm_mv = Dmmlist.where('dmmtitle = ?', mvtitle.dmmtitle).first
                   #Relationlistへ登録する
                    relation=Relationlist.new
                    relation.relationid="dmmtosmv"
                    relation.frommvid=dmm_mv.dmmid.to_s
                    relation.tomvid=rec.smvid.to_s
                    relation.fromtitle=dmm_mv.dmmtitle.to_s
                    p "DmmTitle is :" + dmm_mv.dmmtitle.to_s
                    p "DMMDVDTitle is :" + mvtitle.dmmtitle.to_s
                    relation.totitle=rec.smvtitle.to_s
                    p "Totitle is :" + rec.smvtitle.to_s
                    relation.updatedate=Time.now
                    relation.save
                    insertcnt = insertcnt + 1
                else
                    #DVDのみしか存在しない場合、「dmmdvdtosmv」をrelationidにして挿入
                    relation=Relationlist.new
                    relation.relationid="dmmdvdtosmv"
                    p relation.relationid
                    relation.frommvid=mvtitle.dmmid.to_s
                    relation.tomvid=rec.smvid.to_s
                    relation.fromtitle=mvtitle.dmmtitle.to_s
                    p "DMMDVDTitle is :" + mvtitle.dmmtitle.to_s
                    relation.totitle=rec.smvtitle.to_s
                    relation.updatedate=Time.now
                    #relation.save
                    #insertcnt = insertcnt + 1
                end
           end
        end

   end
  
      
  end
  
  #ThisAV用relationlist登録処理
  def thisavmmrelation(dmmdvdid,updatecnt,insertcnt)
   if Thisavlist.where("thisavtitle like ? or tags like ? or thisavtitle like ? or tags like ?" , "%#{dmmdvdid}%","%#{dmmdvdid}%","%#{dmmdvdid.gsub("-","")}%","%#{dmmdvdid.gsub("-","")}%").exists?
        recs = Thisavlist.where("thisavtitle like ? or tags like ? or thisavtitle like ? or tags like ?" , "%#{dmmdvdid}%","%#{dmmdvdid}%","%#{dmmdvdid.gsub("-","")}%","%#{dmmdvdid.gsub("-","")}%")
        recs.each do |rec|
           rec.thisavid.to_s
           #Relationlistに存在するかを確認
           if Relationlist.where('tomvid = ?', rec.thisavid.to_s).where('relationid = ?', "dmmtothisav").exists?
            #すでに存在する場合はスキップ
            updatecnt = updatecnt + 1
           else
            #存在しない場合はrelationlistに登録する
            #登録するため、Dmmlistから同タイトルのIDを取得する。
            mvtitle =  Dmmdvdlist.where('makerid = ?', dmmdvdid).first
                #DVDに登録されていても、動画に登録されていない場合があるので判別する
                if Dmmlist.where('dmmtitle = ?', mvtitle.dmmtitle).exists?
                   dmm_mv = Dmmlist.where('dmmtitle = ?', mvtitle.dmmtitle).first
                   #Relationlistへ登録する
                    relation=Relationlist.new
                    relation.relationid="dmmtothisav"
                    relation.frommvid=dmm_mv.dmmid.to_s
                    relation.tomvid=rec.thisavid.to_s
                    relation.fromtitle=dmm_mv.dmmtitle.to_s
                    p "DmmTitle is :" + dmm_mv.dmmtitle.to_s
                    p "DMMDVDTitle is :" + mvtitle.dmmtitle.to_s
                    relation.totitle=rec.thisavtitle.to_s
                    p "Totitle is :" + rec.thisavtitle.to_s
                    relation.updatedate=Time.now
                    relation.save
                else
                    #DVDのみしか存在しない場合、「dmmdvdtosmv」をrelationidにして挿入
                    relation=Relationlist.new
                    relation.relationid="dmmdvdthisav"
                    p relation.relationid
                    relation.frommvid=mvtitle.dmmid.to_s
                    relation.tomvid=rec.thisavid.to_s
                    relation.fromtitle=mvtitle.dmmtitle.to_s
                    p "DMMDVDTitle is :" + mvtitle.dmmtitle.to_s
                    relation.totitle=rec.thisavtitle.to_s
                    relation.updatedate=Time.now
                    #relation.save
                end
           end
        end

   end
  
      
  end
  #必要な変数定義
  #
  #Smvlist.where('smvid = ?', mvurl).exists?
  #Dmmlist.where("dmmid = ?", item['product_id']).exists?
  
  #時間計測スタート
  start_time = Time.now
  #update件数格納
  updatecnt = 0
  #insert件数格納
  insertcnt = 0
  
  #dmm_mvs=Dmmlist.where('updatedate <= ?', 1.days.ago).order("created_at").limit(900)
  dmm_mvs=Dmmdvdlist.order("updated_at").limit(25000)
  p dmm_mvs.all.count
  #dmm_mvs=Dmmlist.order("updatedate ASC").limit(200)
  #更新日付が古い順に一定件数をチェックする
  dmm_mvs.each do |dmm_mv|
   #DMMのDVDのメーカー品番を含むタイトルとタグが存在するかをチェック
   #DMMDVD品番と検索される側のタイトル、タグからそれぞれ「ー」、「ｰ」を削除して検索
   if dmm_mv.makerid.to_s.include?("-")
    scmakerid = dmm_mv.makerid.to_s.split("-")
    else
    scmakerid = dmm_mv.makerid.to_s
   end
   #メーカーIDをタイトルから検索
   #Sharemovie
   if Smvlist.where("smvtitle like ? or tags like ? or smvtitle like ? or tags like ?" , "%#{dmm_mv.makerid}%","%#{dmm_mv.makerid}%","%#{dmm_mv.makerid.gsub("-","")}%","%#{dmm_mv.makerid.gsub("-","")}%").exists?
       #存在する場合、relationリストに登録する
       p dmm_mv.makerid  + "is match in smv"
       smvdmmrelation(dmm_mv.makerid,updatecnt,insertcnt)
       #登録後、日付をアップデート
       dmm_mv.updatedate=Time.now
       dmm_mv.save
   else
        p dmm_mv.makerid  + "is Not match in smv"
       #存在しない場合は日付データのみupdate
       dmm_mv.updatedate=Time.now
       dmm_mv.save
   end
   
   #ThisAV
   if Thisavlist.where("thisavtitle like ? or tags like ? or thisavtitle like ? or tags like ?" , "%#{dmm_mv.makerid}%","%#{dmm_mv.makerid}%","%#{dmm_mv.makerid.gsub("-","")}%","%#{dmm_mv.makerid.gsub("-","")}%").exists?
       #存在する場合、relationリストに登録する
       p dmm_mv.makerid  + "is match in ThisAV"
       thisavmmrelation(dmm_mv.makerid,updatecnt,insertcnt)
       #登録後、日付をアップデート
       dmm_mv.updatedate=Time.now
       dmm_mv.save
   else
        p dmm_mv.makerid  + "is Not match in ThisAV"
       #存在しない場合は日付データのみupdate
       dmm_mv.updatedate=Time.now
       dmm_mv.save
   end
   

  end
  p "relationlist件数:" + Relationlist.all.count.to_s
  #処理にかかった時間を出力する
  p "処理時間 #{Time.now - start_time}s"
  p "挿入件数：" + insertcnt.to_s
  p "更新件数：" + updatecnt.to_s
  
