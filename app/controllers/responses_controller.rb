
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

class ResponsesController < ApplicationController
  before_action :set_response, only: %i[ show edit update destroy ]

  ##############################################################################
  def get_data
    @user = User.where( id: @response.user_id ).take
    @question = Question.where( id: @response.question_id ).take
    @tool = Tool.where( id: @response.tool_id ).take
    @model = Model.where( id: @response.model_id ).take
  end  # get_data

  ##############################################################################
  def get_lists
    user_list = User.all
    question_list = Question.all
    tool_list = Tool.all
    model_list = Model.all

    @users = {}
    user_list.each do |user|
      @users[ user.id ] = user.user_name
    end  # do

    @questions = {}
    question_list.each do |question|
      @questions[ question.id ] = question.query_text
    end  # do

    @tools = {}
    tool_list.each do |tool|
      @tools[ tool.id ] = tool.tool_name
    end  # do

    @models = {}
    model_list.each do |model|
      @models[ model.id ] = model.modelname
    end  # do
  end  # get_lists

  ##############################################################################
  # GET /responses or /responses.json
  def index
    if session[:user_id].nil?
      @responses = Response.all
    else
      @responses = Response.where( user_id: session[:user_id] ).to_a
    end  # if
    get_lists
  end

  ##############################################################################
  # GET /responses/1 or /responses/1.json
  def show
    get_data
  end

  ##############################################################################
  # GET /responses/1 or /responses/1.json
  def query
    puts "**** Responses_controller.query called *****"
    puts "params: #{params}"
  end

  ##############################################################################
  # GET /responses/new
  def new
    @response = Response.new
  end

  ##############################################################################
  # GET /responses/1/edit
  def edit
  end

  ##############################################################################
  # POST /responses or /responses.json
  def create
    @response = Response.new(response_params)
    @response.user_id = session[:user_id]

    respond_to do |format|
      if @response.save
        format.html { redirect_to response_url(@response), notice: "Response was successfully created." }
        format.json { render :show, status: :created, location: @response }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @response.errors, status: :unprocessable_entity }
      end
    end
  end

  ##############################################################################
  # PATCH/PUT /responses/1 or /responses/1.json
  def update
    respond_to do |format|
      if @response.update(response_params)
        format.html { redirect_to response_url(@response), notice: "Response was successfully updated." }
        format.json { render :show, status: :ok, location: @response }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @response.errors, status: :unprocessable_entity }
      end
    end
  end

  ##############################################################################
  # DELETE /responses/1 or /responses/1.json
  def destroy
    @response.destroy!

    respond_to do |format|
      format.html { redirect_to responses_url, notice: "Response was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  ##############################################################################
  private
  ##############################################################################
    # Use callbacks to share common setup or constraints between actions.
    def set_response
      @response = Response.find(params[:id])
    end

  ##############################################################################
    # Only allow a list of trusted parameters through.
    def response_params
      # params.require(:response).permit(:user_id, :question_id, :tool_id, :model_id, :chain_id, :chain_order, :response_text, :runtime, :created_at)
    end
  ##############################################################################
end
