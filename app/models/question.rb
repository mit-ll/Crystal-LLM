
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

class Question < ApplicationRecord
  validates :user_id, presence: true

  ##############################################################################
  def self.details( q )
    resp = "Question: #{q.query_text}\n"  
    ai_responses = Response.where(question_id: q.id).to_a
    template = nil
    template = Template.where(id: q.template_id).take if ! q.template_id.nil?
    resp += "Template: #{template.template_text}\n" if ! template.nil?
   
    ai_responses.each do |ai_response|
      model = Model.where(id: ai_response.model_id).take
      resp += "Model: #{model.modelname}\n"
      resp += "AI: #{ai_response.response_text}\n"
    end  # do

    return resp
  end  # details

  ##############################################################################
  def self.all_details( user_id )
    questions = Question.where( user_id: user_id ).order(:id).to_a
    all_response = ""
    questions.each do |question|
      all_response += Question.details( question ) + "\n"
    end  # do
    return all_response
  end  # all_details

  ##############################################################################
  def self.chain_details( q )
    questions = Question.where( chain_id: q.chain_id ).order(:chain_order).to_a if ! q.chain_id.nil?
    chain_response = ""
    questions.each do |question|
      chain_response += Question.details( question ) + "\n"
    end  # do
    return chain_response
  end  # chain_details

  ##############################################################################

end  # class
