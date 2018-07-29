json.extract! relationtbl, :id, :relationid, :frommvid, :tomvid, :fromtitle, :totitle, :updatedate, :created_at, :updated_at
json.url relationtbl_url(relationtbl, format: :json)
