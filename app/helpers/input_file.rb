
# This class provides an object model for an input text file.
#
# Author::      Darrell O. Ricke, Ph.D.  (mailto: d_ricke@yahoo.com)
# Copyright::   Copyright (C) 2000 Darrell O. Ricke, Ph.D., Paragon Software
# License:: GNU GPL license: http://www.gnu.org/licenses/gpl.html
# Contact:: Paragon Software, 1314 Viking Blvd., Cedar, MN 55011
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.         

###############################################################################
class InputFile

# the current end-of-file status
attr_accessor :end_of_file
# the current line of the input text file.
attr_accessor :line 
# the text lines from the input text file.
attr_accessor :lines 
# the name of the input text file.
attr_accessor :file_name


###############################################################################
# Create an input text file object for the named file.
def initialize( n )
  @file_name = n		# Input text file name
  @end_of_file = false		# End-of-file status
  @line = ""			# Current text line
  @lines = []
end  # method 	


###############################################################################
# Open the input text file.
def open_file
  @file = File.open( @file_name )
  @end_of_file = false			# not end of file
end  # method open_file


###############################################################################
# Close the input text file.
def close_file
  @file.close unless @file.nil?
  @end_of_file = true
end  # method close_file


###############################################################################
# Get the next line from the input text file.
def get_line
  return "" if ( @line == nil )  

  return @line
end  # method get_line


###############################################################################
# Get the end-of-file status of the input text file.
def is_end_of_file?
  return @end_of_file
end  # method is_end_of_file


###############################################################################
# Get the next text line from the input text file.
def next_line()
  # Check for end of file.
  @line = ""
  return @line if ( ( @line == nil ) || ( @end_of_file == true ) ) 

  # try block for readline
  begin
    @line = @file.readline()

    # Check for end of file
    if ( @line == nil )  
      @end_of_file = true
      @line = ""
    end  # if
  rescue
    @end_of_file = true
  end  # begin

  return @line		# return the current line
end  # method next_line


###############################################################################
# Get the contents from the input binary file.
def read_binary
  @contents = nil
  begin
    @file.binmode
    @contents = @file.read unless @file.nil?
  rescue
    print "read_binary error"
  end  # begin
  
  return @contents
end  # method read_binary


###############################################################################
# Read the contents from the text file into an array of text lines.
def read_lines
  self.lines = []
  while ( self.end_of_file == false )
    self.next_line
    self.lines << self.line.chomp if ! self.end_of_file
  end  # while

  return self.lines
end  # method read_lines

end  # class InputFile


###############################################################################
# Test module.
def test_input_file
  inf = InputFile.new( "test.data" )
  inf.open_file()
  while ( inf.is_end_of_file? == false )
    l = inf.next_line()
    if ( inf.is_end_of_file? == false )
      print "Line: " 
      print l
    end  # if
  end  # while
end # method test_input_file

# test_input_file()
