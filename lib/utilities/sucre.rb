
class Sucre

###############################################################################
def select_patients( sheet, patients )
  endpoints = []
  sheet.each do |row|
    endpoints << row if (patients[row["Patient Population"]])
  end  # row

  puts "# of endpoints: #{endpoints.size}"
  return endpoints
end  # select_patients

###############################################################################
def load_sheet( sheet )
  
  mild = select_patients( sheet, {"Mild" => true, "Outpatient" => true, "Outpatient+Hospitalized" => true} )
  moderate = select_patients( sheet, {"Outpatient+Hospitalized" => true, "Hospitalized" => true, "Moderate" => true} )
  severe = select_patients( sheet, {"Severe" => true, "Severe-Critical" => true, "Critical" => true, "ICU" => true} )
end  # load_sheet

###############################################################################
def load_excel( filename )
  excl = Xsv.open( filename, parse_headers: true )
  load_sheet( excl.sheets[0] )
end  # load_excel

###############################################################################

end  # class Sucre


###############################################################################
# main method.
def load_mcms( filename )
  app = Sucre.new()
  app.load_excel( filename )
end  # method load_mcms

###############################################################################
load_mcms( "CasaleUpdate_COVID220525.xlsx" )
