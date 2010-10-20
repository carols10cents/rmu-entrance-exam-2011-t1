require 'csv'

class StudentAvailability
  def initialize(csv_file)
    @days = {:monday => ClassDay.new, :wednesday => ClassDay.new}

    CSV.foreach(csv_file, :headers => :first_row) do |row|
      name = row["Name"]
      row["Monday Availability"].split(", ").each do |time|
        @days[:monday].add_attendee(time, name)
      end
      row["Wednesday Availability"].split(", ").each do |time|
        @days[:wednesday].add_attendee(time, name)
      end
    end
  end
  
  def attendees(day, time)
    @days[day].get_attendees(time)
  end
  
  def all_available_times(day)
    @days[day].get_times
  end
  
  def optimal_times
    max_can_attend_at_least_one = 0
    max_can_attend_both = 0
    optimal_monday_time = nil
    optimal_wednesday_time = nil

    all_available_times(:monday).each do |monday_time|
      monday_attendees = attendees(:monday, monday_time)
      all_available_times(:wednesday).each do |wednesday_time|
        wednesday_attendees = attendees(:wednesday, wednesday_time)
        can_attend_at_least_one = (monday_attendees + wednesday_attendees).uniq.size
        can_attend_both = (monday_attendees & wednesday_attendees).size
 
        if can_attend_at_least_one > max_can_attend_at_least_one
          max_can_attend_at_least_one = can_attend_at_least_one
          max_can_attend_both = can_attend_both
          optimal_monday_time = monday_time
          optimal_wednesday_time = wednesday_time

        elsif can_attend_at_least_one == max_can_attend_at_least_one
          if can_attend_both > max_can_attend_both
            max_can_attend_both = can_attend_both
            optimal_monday_time = monday_time
            optimal_wednesday_time = wednesday_time
          end
        end
      end
    end
    {:monday => optimal_monday_time, :wednesday => optimal_wednesday_time}
  end
  
  def write_optimal_solution_to_files
    optimal_solution = optimal_times
    File.open("monday-roster.txt", "w") do |f|
      f << optimal_times[:monday]
      f << "\n\n"
      f << attendees(:monday, optimal_times[:monday]).join("\n")
    end
    File.open("wednesday-roster.txt", "w") do |f|
      f << optimal_times[:wednesday]
      f << "\n\n"
      f << attendees(:wednesday, optimal_times[:wednesday]).join("\n")
    end
  end
end

class ClassDay
  attr_reader :times
  
  def initialize
    @times = {}
  end
  
  def add_attendee(time, attendee_name)
    @times[time] ? @times[time] << attendee_name : @times[time] = [attendee_name]
  end
  
  def get_attendees(time)
    @times[time]
  end
  
  def get_times
    @times.keys
  end
end

if __FILE__ == $PROGRAM_NAME
  student_availability = StudentAvailability.new("student_availability.csv")
  student_availability.write_optimal_solution_to_files
end