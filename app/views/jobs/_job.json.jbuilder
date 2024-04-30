json.extract! job, :id, :user_id, :question_id, :template_id, :model_id, :is_running, :is_done, :start_time, :run_time, :created_at, :created_at, :updated_at
json.url job_url(job, format: :json)
