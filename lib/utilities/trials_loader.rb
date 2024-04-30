###############################################################################
#
# Author:       Darrell O. Ricke, Ph.D.
#
###############################################################################


###############################################################################
# main method.
def load_trials_main
  puts "Load Clinical Trials data started"
  if ARGV.length >= 1
    app = LoadTrials.new()
    app.load_table( ARGV[0], "\t" )
    puts "Processing complete"
  else
    puts "rails runner load_trials.rb <clinical trials>"
  end  # if
end  # method load_trials_main

###############################################################################
load_trials_main()

