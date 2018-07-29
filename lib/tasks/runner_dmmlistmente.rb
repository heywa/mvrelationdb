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

#Dmm削除メンテナンス
    #DMM動画リストから、更新日が古い順に取得
    dmm_mvs = Dmmlist.order("updated_at").limit(10000)
    deletecount = 0
    # スクレイピングするURL。カテゴリごとに１ページまでセットする
    dmm_mvs.each do |dmm_mv|
      # スクレイピングするURL
        url2 = dmm_mv.afiriurl.gsub("/unforgiven-990","").split(",")
        #charset = nil
            #URLを開き、存在を確認する
            html2 = url2[0]
            puts html2
            begin
            doc2 = Nokogiri::HTML(open(html2))
            rescue
            p html2.to_s + " Not Exist.Delete!"
            #存在しない場合は、relationlistとDmmlistから削除する
            #Dmmlistの削除
            mvrec = Dmmlist.where('dmmid = ?', dmm_mv.dmmid.to_s)
            mvrec.destroy_all
            #Relationlistの削除。存在するのは１レコードのみのはず
            if Relationlist.where('frommvid = ?', dmm_mv.dmmid.to_s).exists?
            relationrec = Relationlist.where('frommvid = ?', dmm_mv.dmmid.to_s)
            relationrec.destroy_all
            end
            deletecount = deletecount + 1
            next
            end
            #ページが開けた場合は動画は存在するとし、更新日を更新する。
            #合致しない場合は
            p html2.to_s + " Exist"
            #存在する場合は更新日を更新する
            #smvrec = Smvlist.where('smvid = ?', mvurl.smvid.to_s).first
            #smvrec.updatedate = Time.now
            #smvrec.save
    end
    p Dmmlist.all.count
    p "削除件数：" + deletecount.to_s
