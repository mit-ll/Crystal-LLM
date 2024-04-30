
###############################################################################
# ** Large Language Models (LLM) user interface**
# 
# **Author:**  Darrell O. Ricke, Ph.D.  (mailto: Darrell.Ricke@ll.mit.edu)
#  Copyright:  Copyright (c) 2024 Massachusetts Institute of Technology 
#  License:    GNU GPL license (http://www.gnu.org/licenses/gpl.html)  
# 
# **RAMS request ID 1026697**
# 
# **Overview:**
# Large Language Models (LLM) user interface.
# 
# **Citation:** None
# 
# **Disclaimer:**
# DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.
#
# This material is based upon work supported by the Department of the Air Force 
# under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, 
# conclusions or recommendations expressed in this material are those of the 
# author(s) and do not necessarily reflect the views of the Department of the Air Force. 
# 
# © 2024 Massachusetts Institute of Technology
# 
# The software/firmware is provided to you on an As-Is basis
# 
# Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
# Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
# U.S. Government rights in this work are defined by DFARS 252.227-7013 or
# DFARS 252.227-7014 as detailed above. Use of this work other than as specifically
# authorized by the U.S. Government may violate any copyrights that exist in this work.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
###############################################################################

import transformers
import torch
import os
import sys
from os import environ
from langchain.llms.huggingface_pipeline import HuggingFacePipeline
from transformers import AutoTokenizer, AutoModelForCausalLM, TextStreamer 
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain.memory import ChatMessageHistory

from langchain.chains.question_answering import load_qa_chain
from langchain.memory import ConversationBufferMemory

from InputFile import InputFile

model_id = "meta-llama/llama-2-7b-chat-hf"

# environ["HF_HOME"] = "/io"
# environ["HF_HUB_OFFLINE"] = "1"
# environ["TRANSFORMERS_OFFLINE"] = "1"
# environ["TRANSFORMERS_CACHE"] = "/io/hub/llama-2-7b-chat-hf"
#os.environ["CUDA_VISIBLE_DEVICES"]="1,2" # if you need to specify GPUs

###############################################################################
# This function reads in a text file.
def read_text( filename, as_string ):
  df = InputFile()
  df.setFileName( filename )
  df.openFile()
  if as_string:
    df.readText()
    df.closeFile()
    return df.contents
  else:
    df.readArray()
    df.closeFile()
    return df.lines

###############################################################################
arg_count = len(sys.argv)
if ( arg_count >= 4 ):
  token_text = read_text( sys.argv[1], as_string=True )
  template = read_text( sys.argv[2], as_string=True )
  print( "Template:" )
  print( template )

  tokenizer = AutoTokenizer.from_pretrained(model_id, token=token_text, load_in_16bit=True, trust_remote_code=True, device_map="auto", )

  pipeline = transformers.pipeline(
    "text-generation",
    model=model_id,
    tokenizer=tokenizer,
    torch_dtype=torch.bfloat16,
    trust_remote_code=True,
    device_map="auto",
    # max_length=1000,
    max_new_tokens=300,
    do_sample=True,
    top_k=5,
    num_return_sequences=1,
    eos_token_id=tokenizer.eos_token_id
  )

  hf_llm = HuggingFacePipeline(pipeline = pipeline, model_kwargs = {'temperature':0})

  prompt = PromptTemplate(template=template, input_variables=["chat_history","question"])
  cbm_memory = ConversationBufferMemory(memory_key="chat_history", input_key="question")
  llm_chain = LLMChain(prompt=prompt, llm=hf_llm, memory=cbm_memory)

  questions = read_text( sys.argv[3], as_string=False )
  for question in questions:
    print( "-----------------------------------------------------" )
    print( "Question: " + question )
    print(llm_chain.run(question))

  print( "-----------------------------------------------------" )
  print( "Chat history messages buffer:" )
  print( llm_chain.memory.buffer )
else:
  print( "usage: python falcon_chat4.py <token file> <template file> <questions file>" )
