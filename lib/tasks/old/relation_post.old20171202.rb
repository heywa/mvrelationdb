# -- coding: utf-8

require "open-uri"
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/relationlist"
require "active_record"
require "mysql2"
require "csv"
require 'uri'
ActiveRecord::Base.logger = Logger.new(STDOUT)


#投稿ID
postid = nil
#女優名
postactressstr = nil
#ジャンル名
postgenre = nil
#シリーズ名
postseries = nil
#メーカー名
postmaker = nil
#レーベル名
postlabel = nil
#Activerevordログ採取開始
#ActiveRecord::Base.logger = Logger.new(STDOUT)
#関連付けリストの投稿日が空白の物を抽出
    relations = Relationlist.where(potdate: nil)
    p relations.all.count
    relation  = relations.order("updated_at").limit(10)
    #relation = Relationlist.find_by_sql(['select * from relationlist where potdate = ?', ""])

    
    p relation.count.to_s 
    p Relationlist.all.count
    if relation.count > 0
    relation.each do |data|
        ActiveRecord::Base.establish_connection(:development)
        require "#{Rails.root}/app/models/dmmlist"
        require "#{Rails.root}/app/models/smvlist"
        require "#{Rails.root}/app/models/thisavlist"
        require "#{Rails.root}/app/models/relationlist"
        
        #投稿日が挿入されている場合はスキップする。
        if data.potdate == nil
        else
            next
        end
        
        #DMMのID
        p data.frommvid
        dmmdata = Dmmlist.where('dmmid = ?', data.frommvid).first
        #SharemovieのID
        p data.tomvid
        case data.relationid.to_s
        when "dmmtosmv"
        tomvdata = Smvlist.where('smvid = ?', data.tomvid).first
        
        when "dmmtothisav"
        tomvdata = Thisavlist.where('thisavurl = ?', data.tomvid).first
        end
        
        #女優名を配列から格納
        hoge = dmmdata.actressname.to_s.gsub("av,","").split(",")

        actressstr=""
        tempstr=""
        hoge.each do|str|
            if str =="av"
            else
            if tempstr == ""
               tempstr = str
               else
                if actressstr == ""
                   actressstr = actressstr + str + "(" + tempstr + ")"
                   tempstr =""
                else
                   actressstr = actressstr + "、" + str + "(" + tempstr + ")"
                   tempstr =""
                end
            end
            end   
        end
        postactressstr = actressstr.to_s
        p postactressstr
        #監督名を配列から格納
        hoge = dmmdata.direcrtorname.gsub("av,","").split(",")
        direcrtorstr=""
        tempstr=""
        hoge.each do|str|
            if str =="av"
            else
            if tempstr == ""
               tempstr = str
               else
               direcrtorstr = direcrtorstr + str + "(" + tempstr + ")、"
               tempstr =""
            end
            end   
        end
        p direcrtorstr.to_s
        #タグをsharemovieのタグとDMMのジャンルを連結させて格納
        #movietag = dmmdata.genre.gsub(",","、") + "、" + tomvdata.tags.gsub(",","、")
        #p movietag.gsub("、、","").to_s
        postgenre = dmmdata.genre
        
        #動画埋め込みリンク。複数ある場合はその分を挿入する。
        mvembe="<br>"
        p data.frommvid.to_s
        Relationlist.where('frommvid = ?', data.frommvid).each do |mvid|
           case mvid.relationid.to_s
           when "dmmtosmv" 
           #合致したIDからSharemovieのリンクURLを抽出
           p mvid.tomvid
           smvurl = Smvlist.where('smvid = ?', mvid.tomvid).first
           p "smv exist"
           mvembe << %(<iframe src="http://smv.to/embed/#{smvurl.smvid.to_s}/" frameborder=0 width="640" height="360" scrolling=no></iframe><br>)
           when "dmmtothisav"
           mvembe << %(<iframe scrolling="no" width="640px" height="360px" frameborder="0" src="http://www.thisav.com/video/embed/#{mvid.tomvid.to_s}/"></iframe><br>)
           end
        end
        p mvembe.to_s
        
        #アフィリエイトリンクを格納
        p dmmdata.afiriurl
        
        if dmmdata.afiriurl == ""
        else
        hoge = dmmdata.afiriurl.split(",")
        afiriurlpc = hoge[0].gsub(" ","")
        
        #afiriurlmobile = hoge[1].gsub(" ","")
        end
        p afiriurlpc
        #p afiriurlmobile
        
        #サンプル画像を格納
        sampleimages=""
        p dmmdata.images
        if dmmdata.images ==""
        else
        hoge  = dmmdata.images.to_s.gsub("\"","").split(",")
        hoge.each do |str|
            #p str
            if dmmdata.afiriurl == ""
                sampleimages << %(<a href="#{str.gsub(" ","")}"><img src="#{str.gsub(" ","")}" alt="#{dmmdata.dmmtitle}" /></a>)
            else
                sampleimages << %(<a href="#{afiriurlpc.gsub(" ","")}"><img src="#{str.gsub(" ","")}" alt="#{dmmdata.dmmtitle}" /></a>)
            end
        end
        end
        p sampleimages
        
        #サンプル動画を格納
        if dmmdata.sampremovieurl.to_s == ""
        else
        samplmovie = %(<iframe width="560" height="360" src="http://www.dmm.co.jp/litevideo/-/part/=/affi_id=unforgiven-990/cid=#{dmmdata.dmmid}/size=560_360/" scrolling="no" frameborder="0" allowfullscreen></iframe>)
        end
        post_author = '1'
        p post_author.to_s
        post_name = dmmdata.dmmid.to_s
        p post_name.to_s
        post_modified = Time.now
        p post_modified.to_s
        post_title = dmmdata.dmmtitle
        p post_title.to_s
        #本文挿入
        #パッケージ画像
        post_content = %(<img src="http://pics.dmm.co.jp/digital/video/#{dmmdata.dmmid.to_s}/#{dmmdata.dmmid.to_s}pl.jpg" />)
        #ビデオ情報
        #動画説明文
        case data.relationid.to_s
        when "dmmtosmv"
        post_content <<  %(<p>#{tomvdata.explanation.to_s}</p><br>)
        end
        #post_content <<  "<p>「" +  dmmdata.dmmtitle + "」にタイトルが<b>似ている</b>無料動画を紹介します。</p>"
        post_content <<  "<h2>「" +  dmmdata.dmmtitle + "」の動画情報</h2><br>"
        post_content <<  "<p>配信日・発売日：" +  dmmdata.instoredate.to_s + "</p><br>"
        post_content <<  "<p>女優名：" +  postactressstr + "</p><br>"
        post_content <<  "<p>監督名：" +  direcrtorstr.to_s + "</p><br>"
        post_content <<  "<p>タグ・ジャンル：" +  postgenre.to_s + "</p><br>"
        post_content <<  "<p>シリーズ名：" +  dmmdata.series + "</p><br>"
        postseries = dmmdata.series
        post_content <<  "<p>メーカー名：" +  dmmdata.maker + "</p><br>"
        postmaker = dmmdata.maker
        post_content <<  "<p>レーベル名：" +  dmmdata.label + "</p><br>"
        postlabel = dmmdata.label
        #サンプル画像
        if sampleimages==""
        else
        #post_content <<  "<img src=""http://pics.dmm.co.jp/digital/video/" + dmmdata.dmmid.to_s + "/" + dmmdata.dmmid.to_s + "ps.jpg""></a>"
        #ランダムに画像を二重で挿入。アイキャッチにするため
        #numbers = sampleimages.gsub(/\\/,"").to_s.split(",")
        #strcount = numbers.count - 1
        #post_content << numbers[rand(strcount)]
        post_content <<  sampleimages.gsub(/\\/,"")
        end
        #動画埋め込みリンク。複数ある場合はその分を挿入する。
        post_content <<  mvembe.to_s.gsub(/\\/, '')
        
        #DMMサンプル動画（あれば）
        if samplmovie.to_s ==""
        else
        post_content << samplmovie
        end
        #DMMアフィリエイトリンク
        post_content <<  %(<p>動画が見れない場合は<a href="#{afiriurlpc}">こちら</a>からどうぞ！</p><br>)
        
        p post_content.to_s
        
        # WordPress用MysqlDB接続設定
        ActiveRecord::Base.establish_connection(
        adapter:  "mysql2",
        host:     "153.122.58.96",
        username: "wpadmin01",
        password: "BX9hfRinszBC",
        database: "wordpress_7",
        )
        # テーブルにアクセスするためのクラスを宣言
        class User2 < ActiveRecord::Base
        # テーブル名が命名規則に沿わない場合、
        self.table_name = 'wp_5_posts'  # set_table_nameは古いから注意
            self.primary_key = :ID
        end

        #WordPress用DBへ記事をinsertする。
        # 投稿がすでに存在するかをチェックする
        #p data["id"].to_i
        if user = User2.where("post_name = ?", post_name).exists?
            #存在する場合はUpdateする
            p 'start update'
            p post_content.to_s
            user = User2.where("post_name = ?", post_name).first
            user.post_content = post_content.to_s
            user.save
            ActiveRecord::Base.establish_connection(:development)
            require "#{Rails.root}/app/models/dmmlist"
            require "#{Rails.root}/app/models/smvlist"
            require "#{Rails.root}/app/models/relationlist"
            #投稿済の動画のpotdateに日付を挿入。複数ある場合はその分繰り返す。
            Relationlist.where('frommvid = ?', data.frommvid).each do |mvid|
               mvid.potdate = Time.now
               mvid.save
            end
            p 'End update'
        else
            #存在しない場合はInsertする
            p 'start insert'
            #user = User2.where('id' == data["bokepostid"]).first
            user = User2.new
            p post_content.to_s
            user.post_content = post_content.to_s
            #p data["id"].to_i
            #IDは自動採番のため、挿入しない。しては行けない。
            #user.id = data["id"].to_i
            user.post_author = post_author
            user.post_date = Time.now
            user.post_date_gmt = Time.now
            user.post_title = post_title
            user.post_name = post_name
            user.post_modified = Time.now
            user.post_modified_gmt
            user.post_excerpt = post_title
            user.to_ping = " "
            user.pinged = " "
            user.post_content_filtered = " "
            user.save
            #挿入後、IDが採番されるので、GUIDを挿入する。
            user = User2.where("post_name = ?", post_name).first
            user.guid = 'http://digital-curation-blog.com/wordpress/freemovie/?p=' + user.id.to_s
            user.save
            postid = user.id
            #カスタムフィールドを挿入する
            # テーブルにアクセスするためのクラスを宣言
            class User3 < ActiveRecord::Base
            # テーブル名が命名規則に沿わない場合、
            self.table_name = 'wp_5_postmeta' # set_table_nameは古いから注意
            self.primary_key = :meta_id
            end
            #女優名
            user = User3.new
            user.post_id = postid
            user.meta_key = 'wpcf-mvactressname'
            user.meta_value = postactressstr.to_s
            user.save
            #ジャンル
            user = User3.new
            user.post_id = postid
            user.meta_key = 'wpcf-mvgenre'
            user.meta_value = postgenre.to_s
            user.save
            #メーカー
            user = User3.new
            user.post_id = postid
            user.meta_key = 'wpcf-mvmaker'
            user.meta_value = postmaker.to_s
            user.save
            #メーカー
            user = User3.new
            user.post_id = postid
            user.meta_key = 'wpcf-mvmaker'
            user.meta_value = postmaker.to_s
            user.save
            #レーベル
            user = User3.new
            user.post_id = postid
            user.meta_key = 'wpcf-mvlabel'
            user.meta_value = postlabel.to_s
            user.save
            #シリーズ名
            user = User3.new
            user.post_id = postid
            user.meta_key = 'postseries'
            user.meta_value = postseries.to_s
            user.save
            #サムネイル（パッケージ）
            user = User3.new
            user.post_id = postid
            user.meta_key = '_post_alt_thumbnail'
            user.meta_value = "http://pics.dmm.co.jp/digital/video/" + dmmdata.dmmid.to_s + "/" + dmmdata.dmmid.to_s + "ps.jpg"
            user.save
=begin            
        #wp_term_relationshipsに記事とタグを関連付ける
        # テーブルにアクセスするためのクラスを宣言
        class Termsrelationtbl < ActiveRecord::Base
        # テーブル名が命名規則に沿わない場合、
        self.table_name = 'wp_5_term_relationships' # set_table_nameは古いから注意
        self.primary_key = :object_id
        end
        if Termsrelationtbl.where("object_id = ?", postid).where("term_taxonomy_id = ?", '45').exists?
        else
        #共通のカテゴリを挿入
        #DMM
        user3 = Termsrelationtbl.new
        user3.object_id = postid
        user3.term_taxonomy_id = '45'
        user3.term_order = 1
        #user3.parent = 1
        user3.save
        #Sharemovie
        user3 = Termsrelationtbl.new
        user3.object_id = postid
        user3.term_taxonomy_id = '47'
        user3.term_order = 1
        #user3.parent = 1
        user3.save
        end  
=end            
            
            #個別タグを挿入する
            # テーブルにアクセスするためのクラスを宣言
            class Termstbl < ActiveRecord::Base
            # テーブル名が命名規則に沿わない場合、
            self.table_name = 'wp_5_terms' # set_table_nameは古いから注意
            self.primary_key = :term_id
            end
            postgenrestr = postgenre + ',DMM,Sharemovie'
            p 'postgenrestr' + postgenrestr.to_s
            postgenrestr.split(",").each do |genrestr|
                if user = Termstbl.where("name = ?", genrestr.to_s).exists?
                user = Termstbl.where("name = ?", genrestr.to_s).first 
                user.slug = URI.escape(genrestr)
                user.save
                # テーブルにアクセスするためのクラスを宣言
                class Termtaxonomy < ActiveRecord::Base
                # テーブル名が命名規則に沿わない場合、
                self.table_name = 'wp_5_term_taxonomy' # set_table_nameは古いから注意
                self.primary_key = :term_taxonomy_id
                end
                user2 = Termtaxonomy.where("term_id = ?", user.term_id).first
                user2.count = user2.count.to_i + 1 
                #「無料動画」のカテゴリを親カテゴリにする。IDはサイトごとに異なる。
                user2.parent = '134'
                user2.save
                #wp_term_relationshipsに記事とタグを関連付ける
                # テーブルにアクセスするためのクラスを宣言
                class Termsrelationtbl < ActiveRecord::Base
                # テーブル名が命名規則に沿わない場合、
                self.table_name = 'wp_5_term_relationships' # set_table_nameは古いから注意
                self.primary_key = :object_id
                end
                user3 = Termsrelationtbl.new
                user3.object_id = postid
                user3.term_taxonomy_id = user2.term_taxonomy_id
                user3.term_order = 0
                user3.save
                else
                #タグ・カテゴリが存在しない場合。
                user = Termstbl.new
                user.name = genrestr.to_s
                user.slug = URI.escape(genrestr)
                user.save
                user = Termstbl.where("name = ?", genrestr.to_s).first
                # テーブルにアクセスするためのクラスを宣言
                class Termtaxonomy < ActiveRecord::Base
                # テーブル名が命名規則に沿わない場合、
                self.table_name = 'wp_5_term_taxonomy' # set_table_nameは古いから注意
                self.primary_key = :term_taxonomy_id
                end
                user2 = Termtaxonomy.new
                user2.term_id = user.term_id
                user2.taxonomy = 'category'
                user2.description  = ''
                #「無料動画」のカテゴリを親カテゴリにする。IDはサイトごとに異なる。
                user2.parent = '134'
                user2.count = 1
                user2.save
                #user2.count = user2.count.to_i + 1 

                #wp_term_relationshipsに記事とタグを関連付ける
                # テーブルにアクセスするためのクラスを宣言
                class Termsrelationtbl < ActiveRecord::Base
                # テーブル名が命名規則に沿わない場合、
                self.table_name = 'wp_5_term_relationships' # set_table_nameは古いから注意
                self.primary_key = :object_id
                end
                user3 = Termsrelationtbl.new
                user3.object_id = postid
                user3.term_taxonomy_id = user2.term_taxonomy_id
                user3.term_order = 1
                #user3.parent = 1
                user3.save


                end
            end
            


        ActiveRecord::Base.establish_connection(:development)
        require "#{Rails.root}/app/models/dmmlist"
        require "#{Rails.root}/app/models/smvlist"
        require "#{Rails.root}/app/models/relationlist"
        #投稿済の動画のpotdateに日付を挿入。複数ある場合はその分繰り返す。
        Relationlist.where('frommvid = ?', data.frommvid).each do |mvid|
               mvid.potdate = Time.now
               mvid.save
        end

        end

        


    end
    end



#p User.all
