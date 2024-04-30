
#
# This class provides an object model for an output text file.
#
# Author::    	Darrell O. Ricke, Ph.D.  (mailto: doricke@gmail.com)
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
#             	You should have received a copy of the GNU General Public License
#             	along with this program; if not, write to the Free Software
#             	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###############################################################################
class OutputFile:

  #
  # Initialization routine.
  #
  def initialize ( self ):
    self.file_name = ""			# File name
    self.file = None			# Output file
    self.lines = 0			# Lines written


  #############################################################################
  #
  # Constructor.
  #
  def __init__ ( self, name = "" ):
    self.initialize ()			# initialize
    self.setFileName ( name )
    self.openFile ()


  #############################################################################
  #
  # This method opens the output text file.
  #
  def openFile ( self ):
    if ( self.file_name == "" ):
      print("No file name has been specified.")
      return
    try:
      self.file = open ( self.file_name, "w" )	# open the file for writing
    except:
      print("Open failure on file named ", self.file_name)


  #############################################################################
  # 
  # This method closes the output text file.
  #
  def closeFile ( self ):
    self.file.close ()			# close the input file


  #############################################################################
  # 
  # This method deletes the output text file.
  #
  def deleteFile ( self ):
    print("The delete file function has not been implemented yet.")


  #############################################################################
  # 
  # This method returns the name of the output text file.
  #
  def getFileName ( self ):
    return self.file_name


  #############################################################################
  # 
  # This method sets the name of the output text file.
  #
  def setFileName ( self, name ):
    if ( name == "" ):  return
    self.file_name = str ( name )


  #############################################################################
  # 
  # This method writes to the output text file.
  #
  def write ( self, text ):
    self.file.write ( text )
    self.lines = self.lines + 1


###############################################################################
# 
# Testing module.
#
if ( __name__ == "__main__" ):
  test = OutputFile ( "test.data" )
  # for i in range ( 10 ):
  #   test.write ( "Line " + str ( i ) + "\n" )
  test.write( ">Seq1 This is a FASTA sequence file.\n" )
  test.write( "ACGTACGTACGT\n" )
  test.write( ">Seq2 This second sequence in the file.\n" )
  test.write( "AAAACCCCGGGGTTTT\n" )
  test.closeFile ()

