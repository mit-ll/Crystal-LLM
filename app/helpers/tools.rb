

###############################################################################
# ** Large Language Models (LLM) user interface**
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

class Tools

###############################################################################
# Removes non-ascii characters from the text field.
def self.clean_field( field )
  return field.to_s if ! field.instance_of? String
  return "" if field.nil?
  clean = field.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  clean = clean.gsub("'", "")
  clean = clean.gsub('"', "")
  # puts "Clean: #{clean}"
  return "" if clean == "{}"
  return clean 
end  # clean_field
    
#############################################################################
  def self.clean_name(filename)
    return if filename.nil?
    filename.strip.tap do |name|
      name.sub! /\A.*(\\|\/)/, ''
      # Replace all non alphanumeric, underscore or periods with underscore
      name.gsub! /[^\w\.\-]/, '_'
    end  # do
  end  # clean_name

#############################################################################
  def self.clean_pathname( filename )
    index = filename.index( "." )
    filename = filename[ 0...index ] if ! index.nil?
    # index = filename.rindex( '/' )
    # filename = filename[ (index+1)..-1 ] if ! index.nil?
    # index = filename.rindex( '\\' )
    # filename = filename[ (index+1)..-1 ] if ! index.nil?
    return clean_name( filename )
  end # clean_pathname

###############################################################################
# Clip database field to length limit.
def self.clip( field, len )
  return "" if field.nil?
  clean = field.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  clean = clean.gsub("'", "")
  return "" if clean == "{}"
  return clean.rstrip if clean.size < len
  return clean[0...len].rstrip
end  # clip

#############################################################################
def self.encode( str )
  utf8 = str.force_encoding('UTF-8')
  unless utf8.valid_encoding?
    utf8 = str.encode("utf-8", invalid: :replace, undef: :replace, replace: '')
  end
  utf8
end  # encode

#############################################################################
  def self.safe_name(name)
    return if name.nil?
    return ActiveRecord::Base.sanitize(name).gsub( "'", "" )
  end  # safe_name

#############################################################################
  def self.array_cat(base, add)
    # Check for nothing to add
    return base if (add.nil?) || (add.size < 1)
    
    add.each do |member|
      if base.nil?
        base = [member]
      else
        base << member
      end  # if
    end  # do
      
    return base
  end  # array_cat
  
#############################################################################
  def self.hash_dump(hash)
    hash.each do |key,value|
      puts "hash key: #{key} = #{value}"
    end
  end  # hash_dump
  
#############################################################################
  # Converts an array into a hash by record.id
  def self.to_hash(array)
    hash = {}
    array.each do |rec|
      hash[rec.id] = rec
    end  # do
    return hash
  end  # to_hash
  
#############################################################################
  # Removes common delimiters from a string.
  def self.clean(list)
    list = list.gsub(","," ")
    list = list.gsub(";"," ")
    list = list.gsub("\n"," ")
    list = list.gsub("\t"," ")
    return list
  end  # clean
  
#############################################################################
  # reverse RGB color bytes
  def self.color_swap(color)
    return "FFFFFF" if color == nil
    return "FFFFFF" if color == ""
    a = color % 256
    c = color / 256
    b = c % 256
    c /= 256
    # return (a * 65536) + (b * 256) + c
    return zeros(a.to_s(16), 2) + zeros(b.to_s(16), 2) + zeros(c.to_s(16), 2)
  end  # color_swap
  
#############################################################################
  def self.day_of_week(day)
    case day.cwday
      when 1
        return "Monday"
      when 2
        return "Tuesday"
      when 3
        return "Wednesday"
      when 4
        return "Thursday"
      when 5
        return "Friday"
      when 6
        return "Saturday"
      when 7
        return "Sunday"        
     end 
  end # day_of_week
  
#############################################################################
  def self.full_month_int(month)
    case month
      when "January"
        return 1
      when "February"
        return 2
      when "March"
        return 3
      when "April"
        return 4
      when "May"
        return 5
      when "June"
        return 6
      when "July"
        return 7
      when "August"
        return 8
      when "September"
        return 9
      when "October"
        return 10
      when "November"
        return 11
      when "December"
        return 12
    end  # case

    return 0
  end  # month_int 
  
#############################################################################
  def self.month_int(month)
    case month
      when "Jan"
        return 1
      when "Feb"
        return 2
      when "Mar"
        return 3
      when "Apr"
        return 4
      when "May"
        return 5
      when "Jun"
        return 6
      when "Jul"
        return 7
      when "Aug"
        return 8
      when "Sep"
        return 9
      when "Oct"
        return 10
      when "Nov"
        return 11
      when "Dec"
        return 12
    end  # case

    return 0
  end  # month_int 

#############################################################################
  def self.highlight(text, keywords)
    return text if text == nil
    keywords.each do |keyword|
      text = text.gsub(keyword,"<font color=\"#FF0000\">#{keyword}</font>")
    end  # do
    return text
  end  # highlight
  
#############################################################################
  # Add leading zeros to the number.
  def self.zeros(hex, num)
    while hex.length < num
      hex = "0" + hex
    end
    return hex
  end  # zeros
  
#############################################################################
  def self.paramDate( day_when )
    return Date.new( day_when["(1i)"].to_i, day_when["(2i)"].to_i, day_when["(3i)"].to_i )
  end  # paramDate 
  
#############################################################################
  # converts date 'mm/dd/yy' to Date method.
  def self.to_date(day_when)
    tokens = day_when.split('/')

    month = Integer(tokens[0])
    day   = Integer(tokens[1])
    year  = Integer(tokens[2])
    
    if(year < 1000 )
      year = year + 2000
    end #if

    return Date.new(year,month,day)
  end  # method to_date
  
#############################################################################
  # duplicated method
  #def self.to_hash(records)
   # new_hash = {}
    #records.each do |record|
     # new_hash[record.id] = record
    #end  # do
      
    #return new_hash
  #end  # to_hash
  
#############################################################################
  def self.parse_date_time(str)
    # puts "parse_date_time: #{str}"
    segs = str.split(' ')     # segments
    tokens = segs[0].split('/')
    month = tokens[0].to_i
    day   = tokens[1].to_i
    year  = tokens[2].to_i
    
    tokens = segs[1].split(':')
    hour  = tokens[0].to_i
    min   = tokens[1].to_i
    sec   = tokens[2].to_i
    if str =~ /(AM)|(PM)/i
      hour += 12 if ((segs[2] == 'PM') && (hour < 12))
      hour  = 0 if ((segs[2] == 'AM') && (hour == 12))
    end #if
     #puts "Date: #{month}/#{day}/#{year} Time: #{hour}:#{min}:#{sec}"
    return Time::local(year,month,day,hour,min,sec)
  end #method parse_date_time
    
  
#############################################################################
  #returns true if time is between start_t and end_t - does not take date into account
  def self.within_time?( time, start_t, end_t )
    time_i = (time.hour.to_i * 60) + time.min
    start_i = (start_t.hour.to_i * 60) + start_t.min
    end_i = (end_t.hour.to_i * 60) + end_t.min
    if start_i <= end_i
      return time_i >= start_i && time_i < end_i
    else
      return !(time_i >= end_i && time_i < start_i)
    end #if/else
  end #method within_time
    
  
#############################################################################
  #returns true if the Time is between start_t and end_t - takes date into account
  def self.within_datetime?(time, start_t, end_t )
    return time.to_i > start_t.to_i && time.to_i <= end_t.to_i
  end #method within_datetime?
    
  
#############################################################################
  #round the given time to the nearest hour
  def self.round_time(time)
    time = time + 3600 if time.min() >= 30 #round up an hour if over 30 min
    hour = time.strftime("%I").to_i
    return "#{hour}#{time.strftime("%p")}"
    
  end #method round_time
    
  
#############################################################################
  #returns the average of an array of time objects
  def self.mean_time( time_array )
    return nil if time_array.length == 0
    sum = 0
    for time in time_array
      sum += time.to_f
    end #for
    return Time.at(sum / time_array.length).localtime
  end #method mean_time
    
  
  #############################################################################
  #returns the mean of an array of numbers
  def self.mean( numbers )
    sum = 0
    for num in numbers
      sum += num
    end #for
    return sum / numbers.length
  end #method mean
  
  
  #############################################################################
  #returns the given time in sql format
  def self.sql_time(time)
    return time.strftime("%Y-%m-%d %H:%M:%S")
  end #method sql_time
  
  #############################################################################
  # Converting a datetime to an integer
  def self.past_now(time)
    now = Time::now
    return true if time.year < now.year
    return false if time.year > now.year
    return true if time.mon < now.mon
    return false if time.mon > now.mon
    return true if time.day < now.day
    return false if time.day > now.day
    return true if time.hour < now.hour
    return false if time.hour > now.hour
    return true if time.min < now.min
    return false
  end

  #############################################################################
  def self.view_dates(params)
    @check = Check.new
    today = Date::today
    @monday = today - today.cwday + 1
    @sunday = today - today.cwday + 7
    @monday_time = Time::mktime(@monday.year, @monday.month, @monday.day)
    @sunday_time = Time::mktime(@monday.year, @monday.month, @monday.day , 23, 59, 59)
    @check.view_start = @monday
    @check.view_end = @sunday
    @check.start_time = @monday_time
    @check.end_time = @sunday_time
    check = params[:check]

    if (check != nil)
      begin
        @check.view_start = Date::new(check['view_start(1i)'].to_i,check['view_start(2i)'].to_i,check['view_start(3i)'].to_i)
        @check.view_end = Date::new(check['view_end(1i)'].to_i,check['view_end(2i)'].to_i,check['view_end(3i)'].to_i)
        @check.start_time = Time::mktime(check['view_start(1i)'].to_i,check['view_start(2i)'].to_i,check['view_start(3i)'].to_i)
        @check.end_time = Time::mktime(check['view_end(1i)'].to_i,check['view_end(2i)'].to_i,check['view_end(3i)'].to_i, 23, 59, 59)
      rescue
        flash[:error] = "Invalid Date Selected."
      end # begin
    end # if

    return @check
  end  # view_dates
  
  ############################################################################
  # this method converts UTC Datetime to AM/PM Datetime.
  
  def self.to_ampm(time)
    min = time.min.to_s
    hour = time.hour.to_s
    year = time.year.to_s
    month = time.month.to_s
    day = time.day.to_s
    if (time.hour >= 12) && (time.hour <= 23) # chech if time is PM
      hour = case time.hour
        when 12 then 12
        when 13 then 1
        when 14 then 2
        when 15 then 3
        when 16 then 4
        when 17 then 5
        when 18 then 6
        when 19 then 7
        when 20 then 8
        when 21 then 9
        when 22 then 10
        when 23 then 11
      end
      hour = hour.to_s
      if min == "0"
        min = "00"
      end
      return month + "/" + day + "/" + year + " " + hour + ":" + min + "  PM"
    end # if
    if (time.hour >=1 ) && (time.hour <= 11 ) # check if time is AM
      if min == "0"
        min = "00"
      end
      return month + "/" + day + "/" + year + " " + hour + ":" + min + "  AM"
    end # if
    if (time.hour == 0) # check if midnight
      hour = "12"
      if min == "0"
        min = "00"
      end
      return month + "/" + day + "/" + year + " " + hour + ":" + min + "  AM"
    end # if
  end # to_ampm

  ###########################################################################
  # this method converts UTC time to AM/PM time  

  def self.to_ampm_nodate(time)
    min = time.min.to_s
    hour = time.hour.to_s
    if (time.hour >= 12) && (time.hour <= 23) # check if time is PM
      hour = case time.hour
        when 12 then 12
        when 13 then 1
        when 14 then 2
        when 15 then 3
        when 16 then 4
        when 17 then 5
        when 18 then 6
        when 19 then 7
        when 20 then 8
        when 21 then 9
        when 22 then 10
        when 23 then 11
      end
      hour = hour.to_s
      if min == "0"
        min = "00"
      end
      return hour + ":" + min + "  PM"
    end # if
    if (time.hour >=1 ) && (time.hour <= 11 ) # check if time is AM
      if min == "0"
        min = "00"
      end
      return hour + ":" + min + "  AM"
    end # if
    if (time.hour == 0) # check if midnight
      hour = "12"
      if min == "0"
        min = "00"
      end
      return hour + ":" + min + "  AM"
    end # if
  end # to_ampm_nodate
  
  ###########################################################################
  def self.chop_id(id)
    if id.is_a? String
      id = id.reverse.chop
      id = id.reverse
      return id
    end  # if
    
    return id
  end  # chop_id

  ###########################################################################
  def self.to_coordinates(params)
    params.keys.each do |key|
      comma = key.index(',')
      if ! comma.nil?
        x = key[0, comma].to_i
        y = key[(comma+1)..-1].to_i
        return x, y
      end  # if
    end  # do
      
    return 0, 0  # coordinates not found
  end  # to_coordinates


  ###########################################################################
#  #round time to the nearest given interval in hours, the default is 1 hour
#  def self.round_time(time, round_to=1)
#    time = time.to_f
#    round_to = round_to * 3600 #convert hours to seconds
#    return Time.at(time).localtime() if time % round_to == 0 
#    
#    if time % round_to >= round_to / 2 #round up
#      return Time.at( time + (round_to - (time % round_to)) ).localtime()
#    else #round down
#      return Time.at( time - (time % round_to) ).localtime()
#    end #if
#   end #method round_time
 
  ###########################################################################

end  # class Tools


#
#str = "7/13/2005 12:00:05 AM"
#time = Tools.parse_date_time str
#print time.to_s + "\n"

