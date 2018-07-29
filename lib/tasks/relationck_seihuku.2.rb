# -- coding: utf-8

require "open-uri"
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/youflixlist"
require "#{Rails.root}/app/models/relationlist"
require "#{Rails.root}/app/models/genrerelationlist"
require "#{Rails.root}/app/models/afilinklist"
require "active_record"
require "mysql2"
require "csv"
require 'uri'
ActiveRecord::Base.logger = Logger.new(STDOUT)


#記事投稿ID
postid = nil
#サムネ投稿ID
thumbpostid = nil
#投稿者ID
post_author = "1"


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

#投稿ジャンル格納変数
postgenreid = "制服"
#DBID: wp_20_
#タグ格納用変数
postgenrestr = postgenreid.to_s
#カテゴリ格納変数
postcategorystr = postgenreid.to_s

#サムネイル
thumbimage = nil

#Activerevordログ採取開始
#ActiveRecord::Base.logger = Logger.new(STDOUT)
#関連付けリストの投稿日が空白の物を抽出
    relations = Genrerelationlist.where(posteddate: nil).where('genrerelationid = ?', postgenreid.to_s)
    #relations = Genrerelationlist.where("posteddate = ? and genrerelationid = ?",nil,"livechat")
    #relations = Genrerelationlist.where("genrerelationid = ?","personalmovie")
    #relations = relations.where(posteddate: nil)
    p relations.all.count
    relation  = relations.order("updated_at").limit(40)
    #relation = Genrerelationlist.find_by_sql(['select * from relationlist where potdate = ?', ""])

    
    p relation.count.to_s 
    p Genrerelationlist.all.count
if relation.count > 0
    relation.each do |data|
        #タグ格納用変数
        postgenrestr = postgenreid.to_s
        ActiveRecord::Base.establish_connection(:development)
        require "#{Rails.root}/app/models/dmmlist"
        require "#{Rails.root}/app/models/smvlist"
        require "#{Rails.root}/app/models/thisavlist"
        require "#{Rails.root}/app/models/relationlist"
        require "#{Rails.root}/app/models/youflixlist"
        require "#{Rails.root}/app/models/afilinklist"
        
        #投稿日が挿入されている場合はスキップする。
        #if data.potdate == nil
        #else
        #    next
        #end
        case data.medianame.to_s
        #メディアが「Sharemovieの場合の投稿情報格納
            when "sharemovie"
            tomvdata = Smvlist.where('smvid = ?', data.mvid).first
            #本文
            ##ヘッダー画像（サムネイルから取得）
            thumbhedder = tomvdata.thumbnum.to_i / 3
                p thumbhedder.to_s
            if thumbhedder.nil? or thumbhedder == 0
                thumbhedder = 30 
                #next
            else
            end
            #thumbimage =%(<img src="http://img1.smv.to//<%= smvlist.smvid %>/animation_00001.jpg" width="640" height="360" title="犬とサッカー">)
            thumbimage =%(http://img1.smv.to//#{tomvdata.smvid}/animation_#{thumbhedder.to_s.rjust(5, "0")}.jpg)
            post_content = %(<img src="#{thumbimage.to_s}" width="640" height="360" title="#{tomvdata.smvtitle.to_s}">)
            #H2タグ
            post_content <<  "<h2>「" +  tomvdata.smvtitle + "」の無料動画情報</h2><br>"
            #説明文
            post_content <<  "<p>" +  tomvdata.explanation.to_s + "</p><br>"
            #サムネイル
            thumbnummax = tomvdata.thumbnum.to_i
                p thumbnummax.to_s
            if thumbnummax.nil? or thumbnummax == 0
                thumbnummax = 100 
                #next
            else
            end
            #アフィリリンクテーブルからランダムにURLを取得する
            afilink = Afilinklist.offset( rand(Afilinklist.count) ).first.afilinkurl
            
            thumbnumstep =thumbnummax / 20
            1.step(thumbnummax.to_i, thumbnumstep.to_i){|num|
                urlthumbnum = 'http://img1.smv.to/' + tomvdata.smvid.to_s + '/animation_' + num.to_s.rjust(5, "0") + '.jpg'
                post_content << %(<a href="#{afilink}"><img src="#{urlthumbnum.gsub(" ","")}" width="210" height="120" alt="#{tomvdata.smvtitle}" /></a>)
            }

            
            post_content << %(<br>)
            #埋め込み動画
            post_content << %(<iframe src="http://smv.to/embed/#{tomvdata.smvid.to_s}/" frameborder=0 width="640" height="360" scrolling=no></iframe><br>)
            #投稿元サイト
            post_content << %(投稿元サイト：<a href="http://smv.to/detail/#{tomvdata.smvid.to_s}">sharemovie</a>)
            #投稿名
            post_name = tomvdata.smvid.to_s
            p post_name.to_s
            #投稿タイトル
            post_title = tomvdata.smvtitle
            p post_title.to_s
            #タグデータ格納
            postgenrestr = postgenreid.to_s + "," + data.keyword.to_s + "," + tomvdata.tags.to_s
            #カテゴリデータ格納
            postcategorystr = postgenreid.to_s + ",sharemovie"
        #メディアが「youflixの場合の投稿情報格納
            when "Youflix"
            tomvdata = Youflixlist.where('youflixid = ?', data.mvid).first
            #本文
            ##ヘッダー画像（サムネイルから取得）
            thumbhedder = tomvdata.thumbnum.to_i / 3
                p thumbhedder.to_s
            if thumbhedder.nil? or thumbhedder == 0
                thumbhedder = 30 
                #next
            else
            end
            #thumbimage =%(<img src="http://img1.smv.to//<%= Youflixlist.youflixid %>/animation_00001.jpg" width="640" height="360" title="犬とサッカー">)
            thumbimage =%(http://thumb1.youflix.is/#{tomvdata.youflixid}/animation/#{thumbhedder.to_s.rjust(5, "0")}.jpg)
            post_content = %(<img src="#{thumbimage.to_s}" width="640" height="360" title="#{tomvdata.youflixtitle.to_s}">)
            #H2タグ
            post_content <<  "<h2>「" +  tomvdata.youflixtitle + "」の無料動画情報</h2><br>"
            #説明文
            post_content <<  "<p>" +  tomvdata.explanation.to_s + "</p><br>"
            #サムネイル画像追加
            thumbnummax = tomvdata.thumbnum.to_i
            p thumbnummax.to_s
            if thumbnummax.nil? or thumbnummax == 0
                thumbnummax = 100 
                #next
            else
            end
            
            #アフィリリンクテーブルからランダムにURLを取得する
            afilink = Afilinklist.offset( rand(Afilinklist.count) ).first.afilinkurl
            
            thumbnumstep =thumbnummax / 20
            1.step(thumbnummax.to_i, thumbnumstep.to_i){|num|
                urlthumbnum = 'http://thumb1.youflix.is/' + tomvdata.youflixid.to_s + '/animation/' + num.to_s.rjust(5, "0") + '.jpg'
                post_content << %(<a href="#{afilink}"><img src="#{urlthumbnum.gsub(" ","")}" width="210" height="120" alt="#{tomvdata.youflixtitle}" /></a>)
            }
            
            post_content << %(<br>)
            #埋め込み動画
            post_content << %(<iframe src="http://youflix.is/embed/#{tomvdata.youflixid.to_s}" frameborder=0 width="640" height="360" scrolling=no></iframe><br>)
            #投稿元サイト
            post_content << %(投稿元サイト：<a href="http://youflix.is/detail/#{tomvdata.youflixid.to_s}">Youflix</a>)
            #投稿名
            post_name = tomvdata.youflixid.to_s
            p post_name.to_s
            #投稿タイトル
            post_title = tomvdata.youflixtitle
            p post_title.to_s
            #タグデータ格納
            postgenrestr = postgenreid.to_s + "," + data.keyword.to_s + "," + tomvdata.tags.to_s
            #カテゴリデータ格納
            postcategorystr = postgenreid.to_s + ",youflix"
                
                
        end
        
        post_author = '1'
        p post_author.to_s
        post_modified = Time.now
        p post_modified.to_s
        
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
        self.table_name = ' wp_20_posts'  # set_table_nameは古いから注意
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
            postid = user.id
            #2017/12/17追加。サムネイル画像登録処理
            #サムネイル用の画像をpostsテーブルに登録
            thumb_name = post_name + "thumb"
            # postsテーブルに投稿がすでに存在するかをチェックする
            if user5= User2.where("post_name = ?", thumb_name).exists?
                thumbpostid = user5.id
            else
                user5 =User2.new
                user5.post_author = post_author
                user5.post_date = Time.now
                user5.post_date_gmt = Time.now
                user5.post_title = thumb_name
                user5.post_content = thumb_name
                user5.post_name = post_name
                user5.post_modified = Time.now
                user5.post_modified_gmt
                user5.post_excerpt = thumb_name
                user5.to_ping = " "
                user5.pinged = " "
                user5.post_status = "inherit"
                user5.ping_status = "closed"
                user5.post_content_filtered = " "
                user5.menu_order =  0
                user5.post_type = "attachment"
                user5.post_mime_type = "image/jpeg"
                #サムネイルはGUIDを挿入する
                user5.guid = thumbimage
                user5.post_parent = postid
                user5.save   
                thumbpostid = user5.id
            end
            #カスタムフィールドを挿入する
            # テーブルにアクセスするためのクラスを宣言
            class User3 < ActiveRecord::Base
                # テーブル名が命名規則に沿わない場合、
                self.table_name = ' wp_20_postmeta' # set_table_nameは古いから注意
                self.primary_key = :meta_id
            end
            #サムネイルIDを挿入
            user = User3.new
            user.post_id = postid
            user.meta_key = '_thumbnail_id'
            user.meta_value = thumbpostid
            user.save
            #2017/12/21追記。記事Update時、サムネイルもUpdateする。
            if user5= User3.where("post_id = ?", postid).where("meta_key = ?", '_post_alt_thumbnail').exists?
                user = User3.where("post_id = ?", postid).where("meta_key = ?", '_post_alt_thumbnail').first
                user.meta_value = thumbimage
                user.save
            else
            end
            #挿入後、記事IDを指定して再度保存
            user = User2.where("post_name = ?", post_name).first
            user.post_modified = Time.now
            #user.guid = 'http://digital-curation-blog.com/wordpress/livechat-movie/?p=' + user.id.to_s
            user.save
            
            #--------サムネイル画像登録処理-------
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
            user.guid = 'http://digital-curation-blog.com/wordpress/livechat-movie/?p=' + user.id.to_s
            user.save
            postid = user.id
            #2017/12/17追加。サムネイル画像登録処理
            #サムネイル用の画像をpostsテーブルに登録
            thumb_name = post_name + "thumb"
            # postsテーブルに投稿がすでに存在するかをチェックする
            if user5= User2.where("post_name = ?", thumb_name).exists?
                thumbpostid = user5.id
            else
            user5 =User2.new
            user5.post_author = post_author
            user5.post_date = Time.now
            user5.post_date_gmt = Time.now
            user5.post_title = thumb_name
            user5.post_content = thumb_name
            user5.post_name = post_name
            user5.post_modified = Time.now
            user5.post_modified_gmt
            user5.post_excerpt = thumb_name
            user5.to_ping = " "
            user5.pinged = " "
            user5.post_status = "inherit"
            user5.ping_status = "closed"
            user5.post_content_filtered = " "
            user5.menu_order =  0
            user5.post_type = "attachment"
            user5.post_mime_type = "image/jpeg"
            #サムネイルはGUIDを挿入する
            user5.guid = thumbimage
            user5.post_parent = postid
            user5.save   
            thumbpostid = user5.id
            end
            #--------サムネイル画像登録処理-------
            
            #カスタムフィールドを挿入する
            # テーブルにアクセスするためのクラスを宣言
            class User3 < ActiveRecord::Base
                # テーブル名が命名規則に沿わない場合、
                self.table_name = ' wp_20_postmeta' # set_table_nameは古いから注意
                self.primary_key = :meta_id
            end
            # テーブルにアクセスするためのクラスを宣言
            class Termtaxonomy < ActiveRecord::Base
            # テーブル名が命名規則に沿わない場合、
                self.table_name = ' wp_20_term_taxonomy' # set_table_nameは古いから注意
                self.primary_key = :term_taxonomy_id
            end
            #サムネイル（パッケージ）
            user = User3.new
            user.post_id = postid
            user.meta_key = '_post_alt_thumbnail'
            user.meta_value = thumbimage
            user.save
            
            #サムネイルIDを挿入
            user = User3.new
            user.post_id = postid
            user.meta_key = '_thumbnail_id'
            user.meta_value = thumbpostid
            user.save
            #挿入後、記事IDを指定して再度保存
            user = User2.where("post_name = ?", post_name).first
            user.post_modified = Time.now
            #user.guid = 'http://digital-curation-blog.com/wordpress/livechat-movie/?p=' + user.id.to_s
            user.save
            
            #ジャンルを個別タグを挿入する
            # テーブルにアクセスするためのクラスを宣言
            class Termstbl < ActiveRecord::Base
                # テーブル名が命名規則に沿わない場合、
                self.table_name = ' wp_20_terms' # set_table_nameは古いから注意
                self.primary_key = :term_id
            end
            p 'postgenrestr' + postgenrestr.to_s
            genrestrs = postgenrestr.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z').split(",").uniq
            p 'genrestrs:' + genrestrs.to_s
            genrestrs.each do |genrestr|
                #タグの文字列が２００を超えてしまう場合、テーブル規則として格納できないため、スキップ
                if URI.escape(genrestr).length > 190
                    next
                end
                #タグが存在するかチェックする。タグに全角英数字が混じっている場合、半角に統一する（2018/02/03）
                if user = Termstbl.where("name = ?", genrestr.to_s.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')).exists?
                    #タグがすでに存在する場合、カテゴリと重複していないか確認する
                    user = Termstbl.where("name = ?", genrestr.to_s).first 
                    if user2 = Termtaxonomy.where("term_id = ? and taxonomy = ?",user.term_id,'post_tag').exists?
                        #タグがすでに存在する場合
                        user = Termstbl.where("name = ?", genrestr.to_s).first 
                        user.slug = URI.escape(genrestr).to_s[0..150]
                        user.save
                        # テーブルにアクセスするためのクラスを宣言
                        class Termtaxonomy < ActiveRecord::Base
                        # テーブル名が命名規則に沿わない場合、
                            self.table_name = ' wp_20_term_taxonomy' # set_table_nameは古いから注意
                            self.primary_key = :term_taxonomy_id
                        end 
                        user2 = Termtaxonomy.where("term_id = ?", user.term_id).first
                        user2.count = user2.count.to_i + 1 
                        #「無料動画」のカテゴリを親カテゴリにする。IDはサイトごとに異なる。
                        #user2.parent = '0'
                        user2.save
                        #wp_term_relationshipsに記事とタグを関連付ける
                        # テーブルにアクセスするためのクラスを宣言
                        class Termsrelationtbl < ActiveRecord::Base
                            # テーブル名が命名規則に沿わない場合、
                            self.table_name = ' wp_20_term_relationships' # set_table_nameは古いから注意
                            self.primary_key = :object_id
                        end
                        #大文字小文字違いでキー重複してしまう場合があるため、既にレコードが存在している場合、
                        #スキップさせることとする。2018/2/14
                        if Termsrelationtbl.where("object_id = ? and term_taxonomy_id = ?",postid,user2.term_taxonomy_id).exists?
                        else
                            user3 = Termsrelationtbl.new
                            user3.object_id = postid
                            user3.term_taxonomy_id = user2.term_taxonomy_id
                            user3.term_order = 0
                            user3.save
                        end
                    end
                else
                        #タグ・カテゴリが存在しない場合。
                        user = Termstbl.new
                        user.name = genrestr.to_s
                        user.slug = URI.escape(genrestr).to_s[0..150]
                        user.save
                        user = Termstbl.where("name = ?", genrestr.to_s).first
                        # テーブルにアクセスするためのクラスを宣言
                        class Termtaxonomy < ActiveRecord::Base
                        # テーブル名が命名規則に沿わない場合、
                            self.table_name = ' wp_20_term_taxonomy' # set_table_nameは古いから注意
                            self.primary_key = :term_taxonomy_id
                        end
                        user2 = Termtaxonomy.new
                        user2.term_id = user.term_id
                        user2.taxonomy = 'post_tag'
                        user2.description  = ''
                        user2.count = 1
                        user2.save
                        #user2.count = user2.count.to_i + 1 
                        #wp_term_relationshipsに記事とタグを関連付ける
                        # テーブルにアクセスするためのクラスを宣言
                        class Termsrelationtbl < ActiveRecord::Base
                            # テーブル名が命名規則に沿わない場合、
                            self.table_name = ' wp_20_term_relationships' # set_table_nameは古いから注意
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
            #テーマをカテゴリに登録する
            # テーブルにアクセスするためのクラスを宣言
            class Termstbl < ActiveRecord::Base
            # テーブル名が命名規則に沿わない場合、
                self.table_name = ' wp_20_terms' # set_table_nameは古いから注意
                self.primary_key = :term_id
            end
            p 'postgenrestr' + postgenrestr.to_s
            genrestrs = postcategorystr.split(",").uniq
            p 'genrestrs:' + genrestrs.to_s
            genrestrs.each do |genrestr|
                if user = Termstbl.where("name = ?", genrestr.to_s).exists?
                    #カテゴリがすでに存在する場合、カテゴリと重複していないか確認する
                    user = Termstbl.where("name = ?", genrestr.to_s).first 
                    if user2 = Termtaxonomy.where("term_id = ? and taxonomy = ?",user.term_id,'category').exists?
                        #カテゴリがすでに存在する場合
                        user = Termstbl.where("name = ?", genrestr.to_s).first 
                        user.slug = URI.escape(genrestr).to_s[0..150]
                        user.save
                        # テーブルにアクセスするためのクラスを宣言
                        class Termtaxonomy < ActiveRecord::Base
                            # テーブル名が命名規則に沿わない場合、
                            self.table_name = ' wp_20_term_taxonomy' # set_table_nameは古いから注意
                            self.primary_key = :term_taxonomy_id
                        end
                        user2 = Termtaxonomy.where("term_id = ?", user.term_id).first
                        user2.count = user2.count.to_i + 1 
                        #「無料動画」のカテゴリを親カテゴリにする。IDはサイトごとに異なる。
                        #user2.parent = '0'
                        user2.save
                        #wp_term_relationshipsに記事とタグを関連付ける
                        # テーブルにアクセスするためのクラスを宣言
                        class Termsrelationtbl < ActiveRecord::Base
                        # テーブル名が命名規則に沿わない場合、
                            self.table_name = ' wp_20_term_relationships' # set_table_nameは古いから注意
                            self.primary_key = :object_id
                        end
                        user3 = Termsrelationtbl.new
                        user3.object_id = postid
                        user3.term_taxonomy_id = user2.term_taxonomy_id
                        user3.term_order = 0
                        user3.save
                    end
                else
                    #タグ・カテゴリが存在しない場合。
                        user = Termstbl.new
                        user.name = genrestr.to_s
                        user.slug = URI.escape(genrestr).to_s[0..150]
                        user.save
                        user = Termstbl.where("name = ?", genrestr.to_s).first
                        # テーブルにアクセスするためのクラスを宣言
                        class Termtaxonomy < ActiveRecord::Base
                            # テーブル名が命名規則に沿わない場合、
                            self.table_name = ' wp_20_term_taxonomy' # set_table_nameは古いから注意
                            self.primary_key = :term_taxonomy_id
                        end
                        user2 = Termtaxonomy.new
                        user2.term_id = user.term_id
                        user2.taxonomy = 'category'
                        user2.description  = ''
                        user2.count = 1
                        user2.save
                        #user2.count = user2.count.to_i + 1 
                        #wp_term_relationshipsに記事とタグを関連付ける
                        # テーブルにアクセスするためのクラスを宣言
                        class Termsrelationtbl < ActiveRecord::Base
                            # テーブル名が命名規則に沿わない場合、
                            self.table_name = ' wp_20_term_relationships' # set_table_nameは古いから注意
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
            

        end
    ActiveRecord::Base.establish_connection(:development)
    require "#{Rails.root}/app/models/dmmlist"
    require "#{Rails.root}/app/models/smvlist"
    require "#{Rails.root}/app/models/youflixlist"
    require "#{Rails.root}/app/models/relationlist"
    require "#{Rails.root}/app/models/genrerelationlist"
    #投稿済の動画のpotdateに日付を挿入。複数ある場合はその分繰り返す。
    data.posteddate = Time.now
    data.save    
    end
end

#p User.all
