
###############################################################################
class LoadEndpoints

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
def setup_endpoint( drug_name, study, endpoint_name, treated_events, control_events, pvalue, organism_name, organism_id, disease_id )
   # Check for no endpoint information
   return if endpoint_name.nil? || endpoint_name.size < 1

   # Setup this endpoint.
   endpoint_text = Tools::clip( endpoint_name, 40 )
   endpoint = Endpoint.where( study_id: study.id, endpoint_name: endpoint_text ).take
   endpoint = Endpoint.new if endpoint.nil?
   endpoint.study_id = study.id
   endpoint.organism_id = organism_id
   endpoint.disease_id = disease_id
   endpoint.study_type = study.study_type
   endpoint.evidence_source = study.evidence_source
   endpoint.drug_name = drug_name
   endpoint.endpoint_name = endpoint_text
   endpoint.patient_population = study.patient_population
   endpoint.treated_events = treated_events.to_i
   endpoint.control_events = control_events.to_i
   endpoint.p_value = pvalue.to_f if ! pvalue.nil?
   endpoint.is_adjusted = false
  
   # Calculate odds ratios, confidence interval, and p-value 
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

   endpoint.save

   # Calculate values for this endpoint.
   endpoint.calculate_risks( endpoint.endpoint_name.downcase )

   # Calculate score(s)
   Scoring::score_endpoint( endpoint, organism_name )

   # Calculate rank score
   if ! endpoint.abs_risk_reduction.nil? && ! endpoint.score.nil?
     endpoint.rank_score = 0
     endpoint.rank_score = endpoint.abs_risk_reduction * endpoint.score * 100 if endpoint.p_value <= 0.05
     endpoint.save
   end  # if
end  # setup_endpoint

###############################################################################
# Setup a new drug and clinical trial set of records.
def load_study( line, delimiter )

   # Find or create the Drug record.
   tokens = line.split( delimiter )
   return if tokens.size < 12
   drug_recs = setup_drugs( tokens[0] )

   drug_name = Tools::clip( tokens[0].strip.downcase, 120 )

   # Setup target virus
   organism_name = Tools::clean_field( tokens[22] )
   organism_id = setup_organism( organism_name )

   # Setup disease
   disease_name = Tools::clean_field( tokens[3] )
   disease_id = setup_disease( disease_name, organism_id )

   reference_id = setup_reference( tokens[1], tokens[2] )
   trial_id = setup_trial( tokens[4] ) if ! tokens[4].nil? && tokens[4].length > 0

   puts "No organism found #{tokens[22]} for #{drug_name}" if organism_id.nil?
   return if organism_id.nil?

   # Find this Study.
   study = Study.where(drug_name: drug_name, reference_id: reference_id ).take
   if study.nil?
     study = Study.new
     study.reference_id = reference_id
   end  # if

   study.organism_id = organism_id
   study.disease_id = disease_id
   study.reference_id = reference_id
   study.trial_id = trial_id

   study.drug_name = drug_name
   study.study_type = Tools::clip( tokens[5], 40 ) if ! tokens[5].nil? 
   study.patient_population = Tools::clip( tokens[6], 80 ) if ! tokens[6].nil?
   study.drugs_combined = tokens[7].to_i if ! tokens[7].nil?
   study.dosing = Tools::clip( tokens[23], 160 ) if ! tokens[23].nil?
   study.evidence_source = Tools::clip( tokens[3], 80 ) if ! tokens[3].nil?
   study.number_treated = tokens[8].to_i if ! tokens[8].nil?
   study.number_controls = tokens[9].to_i if ! tokens[9].nil?
   study.treated_events = Tools::clean_field(tokens[18]) if ! tokens[18].nil?
   study.controls_events = Tools::clean_field(tokens[19]) if ! tokens[19].nil?
   study.notes = Tools::clean_field(tokens[21]) if ! tokens[21].nil?
   study.summary = Tools::clean_field(tokens[20]) if ! tokens[20].nil?

   study.save

   # Create StudyDrug records linking this study to the drugs.
   link_drugs( drug_recs, study.id )

   # Setup this endpoint
   puts "No endpoint found for #{drug_name}" if tokens[10].nil? || tokens[10].size < 1
   return if tokens[10].nil? || tokens[10].size < 1

   setup_endpoint( drug_name, study, tokens[10], tokens[11], tokens[12], tokens[13], organism_name, organism_id, disease_id )
   setup_endpoint( drug_name, study, tokens[14], tokens[15], tokens[16], tokens[17], organism_name, organism_id, disease_id )

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

end  # class LoadEndpoints


###############################################################################
# main method.
def load_studys_main
  app = LoadEndpoints.new()
  app.load_table( "Clinical_Studies.txt", "\t" )

  endpoints = Endpoint.all
  Forest.write_ratios( endpoints )
end  # method load_studys_main

###############################################################################
load_studys_main()

