
###############################################################################
class LoadMetaAnalysis

###############################################################################
#
# Author:       Darrell O. Ricke, Ph.D.
#
###############################################################################

###############################################################################
def setup_drugs( drug_names )
   drug_recs = []
   drugs = drug_names.split( '+' )
   drugs.each do |drug_name|
     name_drug = drug_name.strip.downcase
     # Setup each drug
     drug = Drug.where( drug_name: name_drug ).take
     if drug.nil?
       drug = Drug.new
       drug.drug_name = name_drug
       drug.updated_at = Time::now
       drug.save
     end  # if

     drug_recs << drug
  end  # do

  return drug_recs
end  # setup_drugs

###############################################################################
def link_drugs( drug_recs, study_id )
   drug_recs.each do |drug|
     study_drug = StudyDrug.where(drug_id: drug.id, study_id: study_id).take
     if study_drug.nil?
       study_drug = StudyDrug.new
       study_drug.drug_id = drug.id
       study_drug.study_id = study_id
       study_drug.drug_name = drug.drug_name
       study_drug.save
     end  # if
   end  # do
end  # link_drugs

###############################################################################
def setup_organism( target_virus )
  return nil if target_virus.nil? || target_virus.size < 1

  organism = Organism.where( common_name: target_virus ).take
  return organism.id if ! organism.nil?

  # Create a new organism record.
  organism = Organism.new
  organism.common_name = target_virus
  organism.save
  return organism.id
end  # setup_organism

###############################################################################
def setup_reference( url, ref_text )
  ref = Reference.where( url: url ).take
  return ref.id if ! ref.nil?

  ref = Reference.new
  ref.url = url
  ref.title = ref_text if ! ref_text.nil?
  ref.save
  return ref.id
end  # setup_reference

###############################################################################
def setup_trial( nct_number )
  trial = Trial.where( nct_number: nct_number ).take
  return trial.id if ! trial.nil?

  trial = Trial.new
  trial.nct_number = nct_number
  trial.save
  return trial.id
end # setup_trial

###############################################################################
def setup_endpoint( drug_name, study, endpoint_name, treated_events, control_events, ratio, ci_low, ci_high, pvalue, i2, organism_name, ratio_type )
   # Check for no endpoint information
   return if endpoint_name.nil? || endpoint_name.size < 1

   # Setup this endpoint.
   endpoint_text = Tools::clip( endpoint_name, 40 )
   endpoint = Endpoint.where( study_id: study.id, endpoint_name: endpoint_text ).take
   endpoint = Endpoint.new if endpoint.nil?
   endpoint.study_id = study.id
   endpoint.study_type = study.study_type
   endpoint.evidence_source = study.evidence_source
   endpoint.drug_name = drug_name
   endpoint.endpoint_name = endpoint_text
   endpoint.patient_population = study.patient_population
   endpoint.treated_events = treated_events.to_i if treated_events.size > 0
   endpoint.control_events = control_events.to_i if control_events.size > 0
   endpoint.i2 = i2

   endpoint.confidence_low = ci_low.to_f if ci_low.size > 0
   endpoint.confidence_high = ci_high.to_f if ci_high.size > 0
   endpoint.odds_ratio = ratio.to_f if ratio_type == "OR" && ratio.size > 0
   endpoint.relative_risk = ratio.to_f if ratio_type == "RR" && ratio.size > 0
   endpoint.p_value = pvalue.to_f if ! pvalue.nil? && pvalue.size > 0
   endpoint.is_adjusted = false
  
   # Calculate odds ratios, confidence interval, and p-value 
   if ! endpoint.treated_events.nil? 
     a = endpoint.treated_events.to_f
     b = study.number_treated - a
     c = endpoint.control_events.to_f
     d = study.number_controls - c
     if b > 0.0 && c > 0.0 && d > 0.0
       odds_ratio, ci_low, ci_high, p_value = Scoring::odds_ratio(a, b, c, d)
       endpoint.odds_ratio = odds_ratio
       endpoint.confidence_low = ci_low
       endpoint.confidence_high = ci_high
       endpoint.p_value = p_value
     end  # if

     # Calculate values for this endpoint.
     endpoint.calculate_risks( endpoint.endpoint_name.downcase )

     # Calculate score(s)
     Scoring::score_endpoint( endpoint, organism_name )
   end  # if

   endpoint.save
end  # setup_endpoint

###############################################################################
# Setup a new drug and clinical trial set of records.
def load_study( line, delimiter )

   # Find or create the Drug record.
   tokens = line.split( delimiter )
   return if tokens.size < 12
   drug_recs = setup_drugs( tokens[1] )

   drug_name = Tools::clip( tokens[1].strip.downcase, 120 )

   # Setup target virus
   organism_name = Tools::clean_field( tokens[38] )
   organism_id = setup_organism( organism_name )
   reference_id = setup_reference( tokens[2], tokens[3] )
   trial_id = setup_trial( tokens[5] ) if ! tokens[5].nil? && tokens[5].length > 0

   puts "No organism found #{organism_name} for #{drug_name}" if organism_id.nil?
   return if organism_id.nil?

   # Find this Study.
   study = Study.where(drug_name: drug_name, reference_id: reference_id ).take
   if study.nil?
     study = Study.new
     study.reference_id = reference_id
   end  # if

   study.organism_id = organism_id
   study.reference_id = reference_id
   study.trial_id = trial_id

   study.drug_name = drug_name
   study.study_type = Tools::clip( tokens[6], 40 ) if ! tokens[6].nil? 
   study.patient_population = Tools::clip( tokens[7], 80 ) if ! tokens[7].nil?
   study.drugs_combined = tokens[8].to_i if ! tokens[8].nil?
   study.dosing = Tools::clip( tokens[39], 160 ) if ! tokens[39].nil?
   study.evidence_source = Tools::clip( tokens[4], 80 ) if ! tokens[4].nil?
   study.number_treated = tokens[9].to_i if ! tokens[9].nil?
   study.number_controls = tokens[10].to_i if ! tokens[10].nil?
   study.treated_events = Tools::clean_field(tokens[13]) if ! tokens[13].nil?
   study.controls_events = Tools::clean_field(tokens[14]) if ! tokens[14].nil?
   study.notes = Tools::clean_field(tokens[37]) if ! tokens[37].nil?
   study.summary = Tools::clean_field(tokens[36]) if ! tokens[36].nil?

   study.save

   # Create StudyDrug records linking this study to the drugs.
   link_drugs( drug_recs, study.id )

   # Setup this endpoint
   puts "No endpoint found for #{drug_name}" if tokens[12].nil? || tokens[12].size < 1
   return if tokens[12].nil? || tokens[12].size < 1

   ratio_type = tokens[11]

   setup_endpoint( drug_name, study, tokens[12], tokens[13], tokens[14], tokens[15], tokens[16], tokens[17], tokens[18], tokens[19], organism_name, ratio_type )
   setup_endpoint( drug_name, study, tokens[20], tokens[21], tokens[22], tokens[23], tokens[24], tokens[25], tokens[26], tokens[27], organism_name, ratio_type )
   setup_endpoint( drug_name, study, tokens[28], tokens[29], tokens[30], tokens[31], tokens[32], tokens[33], tokens[34], tokens[35], organism_name, ratio_type )

   # Create scatter plots.
   Scatter::plot_scatters
end  # end load_study

###############################################################################
def load_table( table_name, delimiter )
  in_file = InputFile.new( table_name )
  in_file.open_file
  header = in_file.next_line
  while ( ! in_file.is_end_of_file? )
    line = in_file.next_line

    if ( ! line.nil? ) && ( line.length > 0 )
      load_study( Tools::clip( line, 9999 ), delimiter )
    end  # if
  end  # while
  in_file.close_file
end  # load_table

###############################################################################

end  # class LoadMetaAnalysis


###############################################################################
# main method.
def load_studys_main
  app = LoadMetaAnalysis.new()
  app.load_table( "meta_analysis.txt", "\t" )

  endpoints = Endpoint.all
  Forest.write_ratios( endpoints )
end  # method load_studys_main

###############################################################################
load_studys_main()

