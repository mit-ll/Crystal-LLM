
# This class provides an object model for an output text file.
#
# Author::    	Darrell O. Ricke, Ph.D.  (mailto: d_ricke@yahoo.com)
# Copyright:: 	Copyright (c) 2000 Darrell O. Ricke, Ph.D., Paragon Software
# License::   	GNU GPL license  (http://www.gnu.org/licenses/gpl.html)
# Contact::   	Paragon Software, 1314 Viking Blvd., Cedar, MN 55011
#
#             	This program is free software; you can redistribute it and/or modify
#             	it under the terms of the GNU General Public License as published by
#             	the Free Software Foundation; either version 2 of the License, or
#             	(at your option) any later version.
#         
#             	This program is distributed in the hope that it will be useful,
#             	but WITHOUT ANY WARRANTY; without even the implied warranty of
#             	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#             	GNU General Public License for more details.
#
#               You should have received a copy of the GNU General Public License
#               along with this program. If not, see <http://www.gnu.org/licenses/>.
         
class OutputFile

# lines - the number of lines written to the output text file.
attr_accessor  :lines
# name - the name of the output text file.
attr_accessor :name

####################################################################################################
# Create an output object for the named file.
def initialize( n )
  @lines = 0				# lines written
  close_file()				# close the file
  @file = nil
  set_file_name( n )			# set the file name
end  # method initialize

####################################################################################################
# Open the output text file.
def open_file()
  @file = File.new( @name, "w" )
end  # method open_file

####################################################################################################
# Close the output text file.
def close_file()
  @file.close unless @file.nil?	# close file
end  # method close_file

####################################################################################################
# Delete the file.
def delete_file()
  close_file()				# close the file if open
  File.delete( @name )		# delete the file by name
end  # method delete_file 

####################################################################################################
# Get the number of lines written.
def get_lines()
  return @lines
end  # method get_lines

####################################################################################################
# Get the name of the output text file.
def get_file_name()
  return @name
end  # method get_file_name

####################################################################################################
# Set the name of the output text file.
def set_file_name( n )
  @name = n
end  # method set_file_name

####################################################################################################
# Write a text string to the output text file.
def write( text )
  begin
    @file.print( text ) unless @file.nil?
    @lines += 1
  rescue
    print "Write error"
  end  # begin
end  # method write 

####################################################################################################
def zap(data)
  begin
    @file.binmode
    @file.write(data) unless @file.nil?
  rescue
    print "Zap error"
  end
end  # method zap

####################################################################################################

end  # class OutputFile

####################################################################################################
# Testing module.
def test
  file = OutputFile.new( "test.data" )
  file.open_file()
  file.write( ">Seq1 This is a FASTA sequence file.\n" )
  file.write( "ACGTACGTACGT\n" )
  file.write( ">Seq2 This second sequence in the file.\n" )
  file.write( "AAAACCCCGGGGTTTT\n" )
  file.close_file()
  print "The number of lines written is ", file.get_lines(), "\n"
end  # method test

# test() 

