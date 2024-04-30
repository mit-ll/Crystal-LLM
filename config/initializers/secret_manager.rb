require 'aws-sdk-secretsmanager'

def set_aws_managed_secrets
  # secret name created in aws secret manager
  # secret_name = "#{ENV['RAILS_ENV']}/repository_name/postgres/username"
  secret_name = "mysql/username"
  # region name
  region_name = 'ap-east-1'

  client = Aws::SecretsManager::Client.new(region: region_name)

  begin
    get_secret_value_response = client.get_secret_value(secret_id: secret_name)
  rescue Aws::SecretsManager::Errors::DecryptionFailure => e
    raise
  rescue Aws::SecretsManager::Errors::InternalServiceError => e
    raise
  rescue Aws::SecretsManager::Errors::InvalidParameterException => e
    raise
  rescue Aws::SecretsManager::Errors::InvalidRequestException => e
    raise
  rescue Aws::SecretsManager::Errors::ResourceNotFoundException => e
    raise
  else
    if get_secret_value_response.secret_string
      secret_json = get_secret_value_response.secret_string
      secret_hash = JSON.parse(secret_json)
      ENV['DATABASE_HOST'] = secret_hash['host']
      ENV['DATABASE_USERNAME'] = secret_hash['username']
      ENV['DATABASE_PASSWORD'] = secret_hash['password']
    end  # if
  end  # begin
end  # set_aws_managed_secrets

