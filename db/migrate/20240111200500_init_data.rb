class InitData < ActiveRecord::Migration[7.0]
  def change
    ricke = User::create(user_name: "Darrell Ricke", is_admin: true)
    guest = User::create(user_name: "Guest", is_admin: false)

    llama2 = Tool::create(tool_name: "LLAMA2")
    falcon = Tool::create(tool_name: "Falcon")
    mistai = Tool::create(tool_name: "MistralAI")
    code_llama = Tool::create(tool_name: "CodeLLAMA")
    zephyr = Tool::create(tool_name: "Zephyr")

    falcon_7b_local = Model::create(tool_id: falcon.id, modelname: "tiiuae/falcon-7b", model_version: "7B", group_name: "Standard", host_name: "localhost", host_port: 0, has_curl: false, has_singularity: true, has_docker: true, is_code: false, is_up: true )

    llama2_7b_chat = Model::create(tool_id: llama2.id, modelname: "meta-llama/Llama-2-7b-chat", model_version: "7b", group_name: "Chat", host_name: "localhost", host_port: 0, has_curl: false, has_singularity: true, has_docker: true, is_code: false, is_up: true )
    llama2_7b_chat_hf = Model::create(tool_id: llama2.id, modelname: "meta-llama/Llama-2-7b-chat-hf", model_version: "7b", group_name: "Chat", host_name: "localhost", host_port: 0, has_curl: false, has_singularity: true, has_docker: true, is_code: false, is_up: true )

    mistral_7b_local = Model::create(tool_id: mistai.id, modelname: "mistralai/Mistral-7B-Instruct-v0.2", model_version: "v0.2", group_name: "Instruct", host_name: "localhost", host_port: 0, has_curl: false, has_singularity: true, has_docker: true, is_code: false, is_up: true )
    mistral_7b1_local = Model::create(tool_id: mistai.id, modelname: "mistralai/Mistral-7B-v0.1", model_version: "v0.1", group_name: "Standard", host_name: "localhost", host_port: 0, has_curl: false, has_singularity: true, has_docker: true, is_code: false, is_up: true )
  end  # change
end  # class
