
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

class ModelsController < ApplicationController
  before_action :set_model, only: %i[ show edit update destroy ]

  ##############################################################################
  # GET /models or /models.json
  def index
    @models = Model.all
    @tools = get_tools
  end

  ##############################################################################
  # GET /models/1 or /models/1.json
  def show
    @tool = Tool.where( id: @model.tool_id ).take
  end

  ##############################################################################
  # GET /models/new
  def new
    @model = Model.new
    @tools = Tool.all
  end

  ##############################################################################
  # GET /models/1/edit
  def edit
    @tools = Tool.all
  end

  ##############################################################################
  # POST /models or /models.json
  def create
    @model = Model.new(model_params)
    tool_id = params[:tool][:tool]
    @model.tool_id = tool_id

    respond_to do |format|
      if @model.save
        format.html { redirect_to model_url(@model), notice: "Model was successfully created." }
        format.json { render :show, status: :created, location: @model }
      else
        @tools = Tool.all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  ##############################################################################
  # PATCH/PUT /models/1 or /models/1.json
  def update
    tool_id = params[:tool][:tool]
    @model.tool_id = tool_id
    @model.save if ! tool_id.nil?

    respond_to do |format|
      if @model.update(model_params)
        format.html { redirect_to model_url(@model), notice: "Model was successfully updated." }
        format.json { render :show, status: :ok, location: @model }
      else
        @tools = Tool.all
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  ##############################################################################
  # DELETE /models/1 or /models/1.json
  def destroy
    @model.destroy!

    respond_to do |format|
      format.html { redirect_to models_url, notice: "Model was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  ##############################################################################
  private

  ##############################################################################
  def get_tools
    @tools = {}
    tool_list = Tool.all
    tool_list.each do |tool|
      @tools[ tool.id ] = tool.tool_name
    end  # do
    return @tools
  end  # get_tools

  ##############################################################################
    # Use callbacks to share common setup or constraints between actions.
    def set_model
      @model = Model.find(params[:id])
    end

  ##############################################################################
    # Only allow a list of trusted parameters through.
    def model_params
      params.require(:model).permit(:tool_id, :modelname, :model_version, :group_name, :host_name, :host_port, :tool, :has_curl, :has_singularity, :has_docker, :is_code)
    end
  ##############################################################################
end
