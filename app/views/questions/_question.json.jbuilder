json.extract! question, :id, :user_id, :query_text 
json.url question_url(question, format: :json)
