
###############################################################################
# **Large Language Models (LLM) user interface**
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

require 'input_file'
require 'json'
require 'net/http'
require 'open3'
require 'output_file'
require 'uri'

class Ask

  ##############################################################################
  def self.run_curl( quest, model )
    url = "http://#{model.host_name}:#{model.host_port}/generate"
    params = {'inputs' => quest.query_text, 'parameters' => {'max_new_tokens' => 1024} }
    headers = { 'Content-Type': 'application/json' }

    begin
      puts "***** url: #{url} ******"
      x = Net::HTTP.post(URI.parse(url), params.to_json, headers)
    rescue Errno::ECONNREFUSED
      puts ">>> ECONNREFUSED, x: #{x} #{x.body}"
      return "Server down"
    rescue Net::HTTPOK
      puts "****** OK: #{x.body} ******"
    else
      puts "****** else: #{x} #{x.body} ******"
      # return "Server down"
    end  # begin

    puts "***** #{x.body} *****"
    response = Tools::encode( Tools::clean_field( x.body ) )
   
    str = Ask::clean_response( response )
    # puts "----- #{str} ------"
    return str
  end  # run_curl

  ##############################################################################
  def self.write_history( quest, model, questions )
    quest_name = "Q#{quest.id}.txt"
    quest_file = OutputFile.new( "/io/tmp/#{quest_name}" )
    quest_file.open_file()
    hist_name = "H#{quest.id}.txt"
    hist_file = OutputFile.new( "/io/tmp/#{hist_name}" )
    hist_file.open_file()
    chain_gap = false
    questions.each do |q|
      if chain_gap || q.chain_id <= quest.chain_order
        resp = Response.where( question_id: q.id, model_id: model.id, chain_order: q.chain_order ).take
        if resp.nil?
          quest_file.write( "#{q.query_text}\n" )
          chain_gap = true
        else
          response = resp.response_text.gsub( "\n", " " )
          hist_file.write( "#{q.query_text}\t#{response}\n" )
        end  # if
      else
        quest_file.write( "#{q.query_text}\n" )
      end  # if
    end  # do
    quest_file.close_file()
    hist_file.close_file()
    return quest_name, hist_name
  end  # write_history

  ##############################################################################
  def self.write_template( quest )
    template = nil
    template = Template.where( id: quest.template_id ).take if ! quest.template_id.nil?
    template_name = "T#{quest.id}.txt"
    temp_file = OutputFile.new( "/io/tmp/#{template_name}" )
    temp_file.open_file()
    temp_file.write( "#{template.template_text}\n" ) if ! template.nil?
    temp_file.close_file()

    return template_name
  end  # write_template

  ##############################################################################
  def self.run_chain( quest, model, questions )
    template_name = Ask::write_template( quest )
    quest_name, hist_name = Ask::write_history( quest, model, questions )
    results_name = "R#{quest.id}.txt"

    cmd = "python /io/lang_chain.py /io/token.txt \"#{model.modelname}\" /io/tmp/#{template_name} /io/tmp/#{quest_name} /io/tmp/#{hist_name} /io/tmp/#{results_name}"
    puts "***** lang_chain command: #{cmd}"
    stdout, stderr, status = Open3.capture3("#{cmd}")
    str = Ask::clean_response( stdout )
    puts "**** stdout: #{stdout}"
    puts "**** stderr: #{stderr}"
    puts "**** status: #{status}"

    results = InputFile.new( "/io/tmp/#{results_name}" )
    results.open_file()
    pairs_text = results.read_lines()
    results.close_file()

    if status == 0
      return pairs_text
    else
      puts "**** Something went wrong" 
      return pairs_text
    end  # if
  end  # run_chain

  ##############################################################################
  def self.run_local( quest, model )
    cmd = "python /io/llms_cli.py \"#{model.modelname}\" \"#{quest.query_text}\""
    puts "***** Docker command: #{cmd}"
    stdout, stderr, status = Open3.capture3("#{cmd}")
    str = Ask::clean_response( stdout )
    puts "**** stdout: #{stdout}"
    puts "**** stderr: #{stderr}"
    puts "**** status: #{status}"
    if status == 0
      return str
    else
      puts "**** Something went wrong" 
      return str
    end  # if
  end  # run_local

  ##############################################################################
  def self.run_docker( quest, model, questions )
    puts "**** run_docker called *****"
    if ! quest.chain_id.nil?
      return Ask::run_chain( quest, model, questions )
    else
      return Ask::run_local( quest, model )
    end  # if
  end  # run_docker

  ##############################################################################
  def self.run_singularity( quest, model, questions )
    if ! quest.chain_id.nil?
      return Ask::run_chain( quest, model, questions )
    else
      return Ask::run_local( quest, model )
    end  # if
  end  # run_singularity

  ##############################################################################
  def self.ask_question( query, model, questions )
    return "*** Bad model_id ***" if model.nil?
    puts "**** ask_question called *****"

    if model.has_singularity
      return run_singularity( query, model, questions )
    else
      if model.has_curl
        return run_curl( query, model )
      else
        if model.has_docker
          return run_docker( query, model, questions )
        end  # if
      end  # if
    end  # if

    return "*Information* Model not currently available"
  end  # ask_question

  ##############################################################################
  def self.clean_response( str )
    str = str.gsub( "\n\n", "\n" )
    lines = []
    index = str.index( "\\" )
    x = str[ 0..-2 ]
    x = str[ (index+2)..-2 ] if ! index.nil? && index > 0
    index = x.index( "\\" )

    count = 0
    while (! index.nil? )
      line = x[ 0...index ]
      x = x[ (index+2)..-1 ]
      # puts "(#{count}) index: #{index}, line: #{line}"
      # puts "x: #{x}"
      index = x.index( "\\" )
      if line.size > 0
        lines << line 
        count += 1
      end  # if
      return lines.join( "\n" ) if count > 9
    end

    lines << x

    return lines.join( "\n" )
  end  # clean_response 

  ##############################################################################

end  # class
