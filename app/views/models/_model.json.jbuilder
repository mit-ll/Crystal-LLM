json.extract! model, :id, :tool_id, :modelname, :model_version, :group_name, :host_name, :host_port, :created_at, :updated_at
json.url model_url(model, format: :json)
