# -- coding: utf-8

require "open-uri"
#require "rubygems"
require "nokogiri"
require "#{Rails.root}/app/models/dmmlist"
require "#{Rails.root}/app/models/smvlist"
require "#{Rails.root}/app/models/thisavlist"
require "#{Rails.root}/app/models/youflixlist"
require "#{Rails.root}/app/models/relationlist"
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

flag404 = nil

#Activerevordログ採取開始
#ActiveRecord::Base.logger = Logger.new(STDOUT)
#関連付けリストの投稿日が空白の物を抽出
    relations = Relationlist.where(potdate: nil)
    p relations.all.count
    relation  = relations.order("updated_at").limit(40)
    #relation = Relationlist.find_by_sql(['select * from relationlist where potdate = ?', ""])

    
    p relation.count.to_s 
    p Relationlist.all.count
    if relation.count > 0
    relation.each do |data|
        ActiveRecord::Base.establish_connection(:development)
        require "#{Rails.root}/app/models/dmmlist"
        require "#{Rails.root}/app/models/smvlist"
        require "#{Rails.root}/app/models/thisavlist"
        require "#{Rails.root}/app/models/youflixlist"
        require "#{Rails.root}/app/models/relationlist"
        
        #投稿日が挿入されている場合はスキップする。
        #if data.potdate == nil
        #else
        #    next
        #end
        
        #DMMのID
        p data.frommvid
        dmmdata = Dmmlist.where('dmmid = ?', data.frommvid).first
        #SharemovieのID
        p data.tomvid
        case data.relationid.to_s
        when "dmmtosmv"
        tomvdata = Smvlist.where('smvid = ?', data.tomvid).first
        
        when "dmmtothisav"
        tomvdata = Thisavlist.where('thisavid = ?', data.tomvid).first
        
        when "dmmtoyouflix"
        tomvdata = Youflixlist.where('youflixid = ?', data.tomvid).first
        
        
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
           sharemvdata = Smvlist.where('smvid = ?', mvid.tomvid).first
               #ページの存在確認
                flag404 = nil
                url404 = 'http://smv.to/detail/' + sharemvdata.smvid.to_s
                p url404.to_s
                begin
                    html = Nokogiri::HTML(open(url404))
                # 例外処理、４０４エラーが発生したら、その番号のサムネイルが存在しないとして、処理を抜ける。
                rescue
                    flag404 = "ON"
                    next
                end
            if  flag404 == "ON"
            else
                mvembe << %(<p>掲載元（Sharemovie）のタイトル：<a href="http://smv.to/detail/#{sharemvdata.smvid.to_s}">#{sharemvdata.smvtitle.to_s}</a></p><br>)
                #smvurl = Smvlist.where('smvid = ?', mvid.tomvid).first
                p "smv exist"
                mvembe << %(<iframe src="http://smv.to/embed/#{mvid.tomvid.to_s}/" frameborder=0 width="640" height="360" scrolling=no></iframe><br>)
            end
            
           when "dmmtothisav"
           thsismvdata = Thisavlist.where('thisavid = ?', mvid.tomvid).first
           mvembe << %(<p>掲載元（ThisAV）のタイトル：#{thsismvdata.thisavtitle.to_s}</p><br>)
           mvembe << %(<iframe scrolling="no" width="640px" height="360px" frameborder="0" src="http://www.thisav.com/video/embed/#{mvid.tomvid.to_s}/"></iframe><br>)
           
           when "dmmtoyouflix"
           youflixmvdata = Youflixlist.where('youflixid = ?', mvid.tomvid).first
                flag404 = nil
                #ページの存在確認
                url404 = 'http://youflix.is/detail/'  + youflixmvdata.youflixid.to_s
                p url404.to_s
                begin
                    html = Nokogiri::HTML(open(url404))
                # 例外処理、４０４エラーが発生したら、その番号のサムネイルが存在しないとして、処理を抜ける。
                rescue
                    flag404 = "ON"
                    next
                end
            if  flag404 == "ON"
            else
                mvembe << %(<p>掲載元（Youflix）のタイトル：<a href="http://youflix.is/detail/#{youflixmvdata.youflixid.to_s}">#{youflixmvdata.youflixtitle.to_s}</a></p><br>)
                mvembe << %(<iframe src="http://youflix.is/embed/#{mvid.tomvid.to_s}" frameborder=0 width="640" height="360" scrolling=no></iframe>)
            end
            
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
                sampleimages << %(<a href="#{str.gsub(" ","")}"><img src="#{str.gsub(" ","")}" width="210" height="120" alt="#{dmmdata.dmmtitle}" /></a>)
            else
                sampleimages << %(<a href="#{afiriurlpc.gsub(" ","")}"><img src="#{str.gsub(" ","")}"  width="210" height="120" alt="#{dmmdata.dmmtitle}" /></a>)
            end
        end
        end
        
        p sampleimages
        #2018/03/16サムネイル画像処理追加。各動画サイトのサムネイル画像を追加。
        Relationlist.where('frommvid = ?', data.frommvid).each do |mvid|
            case mvid.relationid.to_s
                when "dmmtosmv" 
                tomvdata = Smvlist.where('smvid = ?', mvid.tomvid).first
                    thumbnummax = tomvdata.thumbnum.to_i
                    p thumbnummax.to_s
                if thumbnummax.nil? or thumbnummax == 0
                    thumbnummax = 100 
                    #next
                else
                    thumbnumstep =thumbnummax / 20
                    1.step(thumbnummax.to_i, thumbnumstep.to_i){|num|
                    urlthumbnum = 'http://img1.smv.to/' + mvid.tomvid.to_s + '/animation_' + num.to_s.rjust(5, "0") + '.jpg'
                    sampleimages << %(<a href="#{afiriurlpc.gsub(" ","")}"><img src="#{urlthumbnum.gsub(" ","")}" width="210" height="120" alt="#{dmmdata.dmmtitle}" /></a>)
                    }
                end
                when "dmmtothisav"
               
                when "dmmtoyouflix"
                tomvdata = Youflixlist.where('youflixid = ?', mvid.tomvid).first
                thumbnummax = tomvdata.thumbnum.to_i
                p thumbnummax.to_s
                if thumbnummax.nil? or thumbnummax == 0
                    thumbnummax = 100 
                    #next
                else
                thumbnumstep =thumbnummax / 20
                1.step(thumbnummax.to_i, thumbnumstep.to_i){|num|
                    urlthumbnum = 'http://thumb1.youflix.is/' + mvid.tomvid.to_s + '/animation/' + num.to_s.rjust(5, "0") + '.jpg'
                    sampleimages << %(<a href="#{afiriurlpc.gsub(" ","")}"><img src="#{urlthumbnum.gsub(" ","")}" width="210" height="120" alt="#{dmmdata.dmmtitle}" /></a>)
                }
                end
            end
        end
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
        #アフィリエイトリンクを挿入するように修正
        if dmmdata.afiriurl == ""
            post_content = %(<img src="http://pics.dmm.co.jp/digital/video/#{dmmdata.dmmid.to_s}/#{dmmdata.dmmid.to_s}pl.jpg" />)
        else
            post_content =  %(<a href="#{afiriurlpc.gsub(" ","")}"><img src="http://pics.dmm.co.jp/digital/video/#{dmmdata.dmmid.to_s}/#{dmmdata.dmmid.to_s}pl.jpg" alt="#{dmmdata.dmmtitle}" /></a>)
        end

        #post_content = %(<img src="http://pics.dmm.co.jp/digital/video/#{dmmdata.dmmid.to_s}/#{dmmdata.dmmid.to_s}pl.jpg" />)
        
        post_content <<  "<p>タイトルが<b>似ている</b>動画が投稿されている動画投稿サイトを紹介しています。</p><br>"
        
        #ビデオ情報
        #動画説明文
        #DMMから商品説明をスクレイピングして更新する２０１７／１２／２
         html = dmmdata.afiriurl.gsub("/unforgiven-990","").split(",")
         puts html[0]
         begin
         doc = Nokogiri::HTML(open(html[0]), nil, "UTF-8")
         #p doc
         #doc = Nokogiri::HTML.parse(html, nil, charset)
         # タグを順番に追ってタイトルタグを抜き出す
         #個別ボケページヘのリンクURL取得
         #bookexp = doc.xpath("/html/body/div[2]/div/div[2]/div[2]/div[1]/div/div[2]/div[4]").inner_text
         mvexp = doc.at_xpath('//div[starts-with(@class,"mg-b20")]').inner_text
         #p mvexp
         p mvexp.encode.gsub("\n","").gsub("\t","").gsub("※ 配信方法によって収録内容が異なる場合があります。","").to_s
         post_content <<  %(<p>#{mvexp.encode.gsub("\n","").gsub("\t","").gsub("※ 配信方法によって収録内容が異なる場合があります。","").to_s}</p><br>)
         rescue
         end
         #ーーーーーー
        
        post_content <<  "<h2>「" +  dmmdata.dmmtitle + "」の動画情報</h2><br>"
        post_content <<  "<p>品番：" +  dmmdata.dmmid.to_s + "</p><br>"
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
        #post_content <<  "<img src=""http://pics.dmm.co.jp/digital/video/" + dmmdata.dmmid.to_s + "/" + dmmdata.dmmid.to_s + "pl.jpg""></a>"
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
            #user.save
            postid = user.id
            #2017/12/17追加。サムネイル画像登録処理
            #サムネイル用の画像をpostsテーブルに登録
            thumb_name = post_name + "thumb"
            # postsテーブルに投稿がすでに存在するかをチェックする
            if user5= User2.where("post_title = ?", thumb_name).exists?
            #2018/03/03 サムネイルがPostテーブルに存在していた場合、Postテーブルから削除する。
            deleterec = User2.where("post_title = ?", thumb_name)
            deleterec.destroy_all
            end
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
            user5.guid = %(http://pics.dmm.co.jp/digital/video/#{post_name}/#{post_name}pl.jpg)
            user5.post_parent = postid
            user5.save   
            thumbpostid = user5.id
            user.save
            #カスタムフィールドを挿入する
            # テーブルにアクセスするためのクラスを宣言
            class User3 < ActiveRecord::Base
            # テーブル名が命名規則に沿わない場合、
            self.table_name = 'wp_5_postmeta' # set_table_nameは古いから注意
            self.primary_key = :meta_id
            end
            
            #サムネイルIDを挿入
            #2018/03/03 Updateした場合、postmetaにサムネイルIDが重複して挿入されてしまう。
            #最初に条件に合致するレコードから削除して挿入する。
            if User3.where('post_id = ?', postid.to_s).where('meta_key = ?', '_thumbnail_id').exists?
                deleterec = User3.where('post_id = ?', postid.to_s).where('meta_key = ?', '_thumbnail_id')
                deleterec.destroy_all
            end
            user = User3.new
            user.post_id = postid
            user.meta_key = '_thumbnail_id'
            user.meta_value = thumbpostid
            user.save
            #2017/12/21追記。記事Update時、サムネイルもUpdateする。
            if user5= User3.where("post_id = ?", postid).where("meta_key = ?", '_post_alt_thumbnail').exists?
            user = User3.where("post_id = ?", postid).where("meta_key = ?", '_post_alt_thumbnail').first
            user.meta_value = %(http://pics.dmm.co.jp/digital/video/#{post_name}/#{post_name}pl.jpg)
            user.save
            else
            end
            #挿入後、記事IDを指定して再度保存
            user = User2.where("post_name = ?", post_name).first
            user.post_modified = Time.now
            #user.guid = 'http://digital-curation-blog.com/wordpress/freemovie/?p=' + user.id.to_s
            user.save
            
            #--------サムネイル画像登録処理-------
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
            #2017/12/17追加。サムネイル画像登録処理
            #サムネイル用の画像をpostsテーブルに登録
            thumb_name = post_name + "thumb"
            # postsテーブルに投稿がすでに存在するかをチェックする
            if user5= User2.where("post_title = ?", thumb_name).exists?
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
            user5.guid = %(http://pics.dmm.co.jp/digital/video/#{post_name}/#{post_name}pl.jpg)
            user5.post_parent = postid
            user5.save   
            thumbpostid = user5.id
            end
            #--------サムネイル画像登録処理-------
            
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
            user.meta_key = 'mvactressname'
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
            user.meta_value = "http://pics.dmm.co.jp/digital/video/" + dmmdata.dmmid.to_s + "/" + dmmdata.dmmid.to_s + "pl.jpg"
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
            #user.guid = 'http://digital-curation-blog.com/wordpress/freemovie/?p=' + user.id.to_s
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
            postgenrestr = postgenre
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
