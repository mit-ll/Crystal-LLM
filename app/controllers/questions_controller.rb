
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


class QuestionsController < ApplicationController
  before_action :set_question, only: %i[ show edit query update destroy download chain_download ]

  ##############################################################################
  def get_users
    @users = {}
    user_list = User.all
    user_list.each do |user|
      @users[ user.id ] = user.user_name
    end  # do
  end  # get_users

  ##############################################################################
  # GET /questions or /questions.json
  def index
    if session[:user_id].nil?
      @questions = Question.all
    else
      @questions = Question.where( user_id: session[:user_id] ).to_a
    end  # if

    get_users
  end  # index

  ##############################################################################
  # GET /questions/1 or /questions/1.json
  def show
    puts "**** show called; params #{params}"
    @questions = nil
    @questions = Question.where( chain_id: @question.chain_id ).order(:chain_order).to_a if ! @question.chain_id.nil?
    get_users
    @template = Template.where(id: @question.template_id).take if ! @question.template_id.nil?

    @user = User.where( id: @question.user_id ).take
    @models = Model.where( is_up: true ).to_a
    @chain_models = Model.where( is_up: true, has_curl: false ).to_a
    @model_names = {}
    @models.each do |model|
      @model_names[ model.id ] = model.modelname
    end  # do

    tools_list = Tool.all
    @tools = {}
    tools_list.each do |tool|
      @tools[ tool.id ] = tool.tool_name
    end  # do
    @responses = Response.where( question_id: @question.id ).to_a
    @add_questions = Question.new
  end  # show

  ##############################################################################
  def query
    puts "*** query; params #{params}"
    query_id = params[:id]
    @question = Question.where(id: query_id ).take
    model_id = nil
    model_id = params[:llm_model][:llm_model] if ! params[:llm_model].nil?
    model_id = params[:model][:model] if model_id.nil? || model_id.size < 1
    if model_id.nil? || model_id.size < 1
      extend_chain
      respond_to do |format|
        format.html { redirect_to question_url(@question), notice: "Question(s) added." }
        format.json { render :show, status: :query, location: @question }
      end  # do
    else
      model = Model.where(id: model_id).take
      questions = nil
      questions = Question.where( chain_id: @question.chain_id ).order(chain_order: :asc).to_a if ! @question.chain_id.nil?
      llm_response = Ask::ask_question( @question, model, questions ) 
      if llm_response == "Server down"
        puts "***** Server is down *****"
        respond_to do |format|
          flash.alert = "This LLM server is currently down."
          format.html { redirect_to question_url(@question), notice: "LLM server is currently down." }
          format.json { render :show, status: :query, location: @question }
          return
        end  # do
      end  # if
 
      if ! questions.nil?
        chain_responses( llm_response, questions, model )
      else 
        response_rec = Response.create( user_id: @question.user_id, question_id: @question.id,
            tool_id: model.tool_id, model_id: model.id, response_text: llm_response,
            created_at: Time::now )
      end  # if
      respond_to do |format|
        format.html { redirect_to question_url(@question), notice: "LLM analysis complete." }
        format.json { render :show, status: :query, location: @question }
      end  # do
    end  # if
  end  # query

  ##############################################################################
  # GET /questions/new
  def new
    @question = Question.new
    @templates = Template.where(user_id: session[:user_id]).to_a
  end

  ##############################################################################
  # GET /questions/1/edit
  def edit
    @user = User.where( id: @question.user_id ).take
    @templates = Template.where(user_id: session[:user_id]).to_a
  end

  ##############################################################################
  def question_form
    user_id = @question.user_id
    user_id = session[:user_id] if user_id.nil?

    # puts "question::create  params: #{params}"
    template_text = params[:template_text]
    if ! template_text.nil? && template_text.size > 1
      @template = Template::create(user_id: user_id, template_text: template_text)
      template_id = @template.id
    else
      template_id = params[:template][:template]
      @template = Template.where(id: template_id).take if ! template_id.nil? && template_id.size > 0
    end  # if

    is_chain = params[:chain]
    chain_order = 1
    chain_id = nil
    chain = nil
    query_text = params[:question][:query_text]
    puts "***** query_text: #{query_text} ****"
    questions = query_text.split( "\n" )
    is_set = false
    if questions.size > 1 
      puts "**** questions.size #{questions.size}"
      questions.each do |question|
        if question.size > 1
          q = Question.new
          q.user_id = user_id
          q.query_text = question.delete( "\r" )
          q.template_id = @template.id if ! @template.nil?
          q.chain_order = chain_order
          if is_chain
            if chain_id.nil?
              chain = Chain::create( user_id: user_id, chain_order: chain_order )
              chain_id = chain.id
              # puts ">>>>chain_id: #{chain_id}, chain_order: #{chain_order} **********"
            else
              # puts "Updating chain_id not nil >>>>chain_id: #{chain_id}, chain_order: #{chain_order} **********"
              chain.chain_order = chain_order
              chain.save
            end  # if
            chain_order += 1
          end  # if
          q.chain_id = chain_id
          q.save
          # puts "***** Question: #{q.id} #{question} user: #{q.user_id} template: #{q.template_id}"
          if is_set == false
            @question = q
            is_set = true
          end  # if
        end  # if
      end  # do
    else
      @question.user_id = user_id
      @question.template_id = template_id if ! template_id.nil? && template_id.size > 0
      @question.query_text = query_text
      @question.chain_order = chain_order
      @question.save
      puts "**** question saved: |#{@question.id}| #{query_text}"
    end  # if
  end  # question_form

  ##############################################################################
  # Adding questions to an existing questions chain.
  def extend_chain
    user_id = @question.user_id
    user_id = session[:user_id] if user_id.nil?

    # puts "question::create  params: #{params}"
    template_id = @question.template_id
    chain_id = @question.chain_id
    @chain = Chain.where(id: chain_id).take if ! chain_id.nil?
    chain_order = 1
    chain_order = @chain.chain_order+1 if ! @chain.nil? && ! chain_order.nil?

    query_text = params[:question][:query_text]
    questions = query_text.split( "\n" )
    if questions.size > 1 
      questions.each do |question|
        if question.size > 1
          q = Question.new
          q.user_id = user_id
          q.query_text = question.delete( "\r" )
          q.template_id = template_id
          q.chain_order = chain_order
          if ! @chain.nil?
            @chain.chain_order = chain_order
            @chain.save
            chain_order += 1
          end  # if
          q.chain_id = chain_id
          q.save
          puts "***** Question: #{q.id} #{question} user: #{q.user_id} template: #{q.template_id}"
        end  # if
      end
    end  # if
  end  # extend_chain

  ##############################################################################
  # POST /questions or /questions.json
  def create
    puts "**** create called #{params}"
    @question = Question.new(question_params)
    question_form

    respond_to do |format|
      format.html { redirect_to question_url(@question), notice: "Question(s) were successfully created." }
      format.json { render :show, status: :created, location: @question }
    end  # do
  end  # create

  ##############################################################################
  # PATCH/PUT /questions/1 or /questions/1.json
  def update
    puts "**** update called #{params}"
    question_form
    respond_to do |format|
      format.html { redirect_to question_url(@question), notice: "Question was successfully updated." }
      format.json { render :show, status: :ok, location: @question }
    end  # do
  end  # update

  ##############################################################################
  # DELETE /questions/1 or /questions/1.json
  def destroy
    @question.destroy!

    respond_to do |format|
      format.html { redirect_to questions_url, notice: "Question was successfully destroyed." }
      format.json { head :no_content }
    end
  end  # destroy

  #############################################################################
  def download
    send_data Question.details(@question), :type => 'text/plain', :disposition => 'attachment'
  end  # download

  #############################################################################
  def all
    send_data Question.all_details(session[:user_id]), :type => 'text/plain', :disposition => 'attachment'
  end  # all

  #############################################################################
  def chain_download
    send_data Question.chain_details(@question), :type => 'text/plain', :disposition => 'attachment'
  end  # chain_download

  ##############################################################################
  private
  ##############################################################################
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

  ##############################################################################
    # Only allow a list of trusted parameters through.
    def question_params
      params.require(:question).permit(:user_id, :chain_id, :chain_order, :template_id, :query_text, :model, :llm_model, :tool, :template, :template_text)
    end

  ##############################################################################
  def match_question( question, query, llm_response, model )
    return if question.nil?
    # puts "**** match_question ****" 
    # puts "Q1: |#{question.query_text}|"
    # puts "Q2: |#{query}|"
    if query == question.query_text
      response_rec = Response.create( user_id: question.user_id, question_id: question.id,
      tool_id: model.tool_id, model_id: model.id, response_text: llm_response.gsub("||","|").gsub("|","\n"),
        created_at: Time::now )
    end  # if
  end  # match_question

  ##############################################################################
  def chain_responses( llm_response, questions, model )
    # puts "llm_response: |#{llm_response}|"
    # responses = llm_response.split( "\n" )
    # for i in 0...llm_response.size do
    #   puts "***** line: #{i}: |#{llm_response[i]}|"
    # end  # do
    # puts "---------------------------------------------------------------------"
    for i in 0...llm_response.size do
      parts = llm_response[i].split( "\t" )
      # puts "i: #{i}: |#{llm_response[i]}|"
      match_question( questions[i], parts[0], parts[1], model )
    end  # do
  end  # chain_responses 

  ##############################################################################
end
