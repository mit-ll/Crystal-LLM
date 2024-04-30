
###############################################################################
# main method.
def load_studys_main
  app = LoadMcms.new()
  x = Xsv.open("COVID-19_Drug_News.xlsx") 
  sheet = x.sheets[1]
 
  app.load_sheet( sheet )

  endpoints = Endpoint.all
  Forest.write_ratios( endpoints )
end  # method load_studys_main

###############################################################################
load_studys_main()

