
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

class AttachmentsController < ApplicationController
  before_action :set_attachment, only: %i[ show edit update destroy ]

  ##############################################################################
  # GET /attachments or /attachments.json
  def index
    @attachment = Attachment.new
  end

  ##############################################################################
  # GET /attachments/1 or /attachments/1.json
  def show
  end

  ##############################################################################
  # GET /attachments/new
  def new
    @attachment = Attachment.new
  end

  ##############################################################################
  # GET /attachments/1/edit
  def edit
  end

  ##############################################################################
  # POST /attachments or /attachments.json
  def create
    @attachment = Attachment.new(attachment_params)
    puts "****** Attachments controller.create called *****"

    is_valid = @attachment.validate_submission
    flash[:notice] = is_valid

    respond_to do |format|
      if is_valid.index( "True" ) != 0
        flash[:notice] = is_valid + " Invalid submission!"
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      else
        if @attachment.interaction_id.nil? 
          flash[:notice] = "*Warning* upload failed; check team key: #{is_valid}"
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: @attachment.errors, status: :unprocessable_entity }
        else
          if ! @attachment.interaction_id.nil? && @attachment.save
            puts "*** After @attachment.save success ***"
            format.html { redirect_to interaction_url(@attachment.interaction_id), notice: "Attachment was successfully created." }
            format.json { render :show, status: :created, location: @attachment }
          else
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: @attachment.errors, status: :unprocessable_entity }
          end  # if
        end  # if
      end  # if
    end  # do
  end  # create

  ##############################################################################
  # PATCH/PUT /attachments/1 or /attachments/1.json
  def update
    respond_to do |format|
      if @attachment.update(attachment_params)
        format.html { redirect_to attachment_url(@attachment), notice: "Attachment was successfully updated." }
        format.json { render :show, status: :ok, location: @attachment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  ##############################################################################
  # DELETE /attachments/1 or /attachments/1.json
  def destroy
    @attachment.destroy

    respond_to do |format|
      format.html { redirect_to attachments_url, notice: "Attachment was successfully destroyed." }
      format.json { head :no_content }
    end
  end  # destroy

  #############################################################################
  def download
    # send_data @attachment.file_binary, :filename => @attachment.name, :type => @attachment.content_type
  end  # download

  ##############################################################################
  private
  ##############################################################################
    # Use callbacks to share common setup or constraints between actions.
    def set_attachment
      @attachment = Attachment.find(params[:id])
    end  # set_attachment

  ##############################################################################
    # Only allow a list of trusted parameters through.
    def attachment_params
      params.require(:attachment).permit(:file_type, :file_name, :file_path, :content_type, :contents, :created_at, :datafile)
    end  # attachment_params
  ##############################################################################
end  # class
