
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

class Attachment < ApplicationRecord

  require 'open3'

  validates_presence_of :file_name
  validates_presence_of :interaction_id
  validates_presence_of :team_id

####################################################################################################
  def datafile=(input_data)
    return nil if input_data == "" #no file name was entered
    # self.file_name = base_part_of(input_data.original_filename)
    # puts "***** datafile= called *****"

    self.file_name = input_data.original_filename
    self.content_type = input_data.content_type.chomp
    raw_text = input_data.read
    self.contents = Tools::clean_field( raw_text )
    self.created_at = Time::now
    # puts "#{self.contents}"
  
    # Write out the data file for validation
    ofs_name = "Uploads/#{self.file_name}"
    ofs = File.open(ofs_name, 'w')
    ofs.write raw_text
    ofs.close
    is_valid = validate_submission

    if is_valid.index( "True" ) == 0
      puts "****** valid: #{is_valid} ******"
      pairs = ParseResults::parse_data( self.contents )
      interaction = ParseResults::record_data( pairs, self.contents )
      if ! interaction.nil?
        self.interaction_id = interaction.id
        self.team_id = interaction.team_id
      end  # if
    end  # if
  end  # datafile

####################################################################################################
  def validate_submission
    ofs_name = "Uploads/#{self.file_name}"
    py_cmd = "python3 authenticate.py #{ofs_name}"
    stdout, stderr, status = Open3.capture3( py_cmd )
    puts "***** validate_submission *****"
    puts "stdout: #{stdout}"
    puts "stderr: #{stderr}"
    puts "status: #{status}"

    return stdout
  end  # validate_submission

####################################################################################################

end  # class Attachment
