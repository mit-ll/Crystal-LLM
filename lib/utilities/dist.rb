require 'rubystats'

# amh = Rubystats::NormalDistribution.new(0.6286, 0.7022)
amh = Rubystats::NormalDistribution.new(50.6286, 10.7022)
sample = 5000.times.map{ amh.rng }

bins = 0
counts = {}
for i in 0..101 do
  counts[i] = 0
end  # for

# Histogram the samples.
sample.each do |s|
  v = s.to_i
  counts[v] += 1 if (v >= 0) && (v <=101)
end  # do

for i in 0..101 do
  puts "#{i}\t#{counts[i]}"
end  # for

# puts "#{sample}"
