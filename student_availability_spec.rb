require File.join(File.dirname(__FILE__), "student_availability")

describe "Student availability" do
  it "should return attendees given a day and time" do
    s = StudentAvailability.new("two_entries.csv")
    s.attendees(:monday, "8:00 am EDT (12:00 UTC)").should eql(["Mylene Wilkinson"])
    s.attendees(:monday, "12:00 pm EDT (16:00 UTC)").should eql(["Mylene Wilkinson", "Elza Yost"])
  end
  
  it "should get a list of all the times people are available in a day" do
    s = StudentAvailability.new("two_entries.csv")
    mon = s.all_available_times(:monday)
    mon.should include("8:00 am EDT (12:00 UTC)")
    mon.should include("12:00 pm EDT (16:00 UTC)")
    mon.should include("3:00 pm EDT (19:00 UTC)")
    mon.should include("4:00 pm EDT (20:00 UTC)")
  end
    
  it "should pick 8am mon and 8am wed from the small test case" do
    # The small test case has:
    # student | M | W
    # test1   | 8 | 8, 12
    # test2   | 8 | 12
    # test3   | 9 | 8
    # It should not pick M:8 and W:12 because then test3 will not be able to make either.
    # M:8 W:8 and M:9 W:12 both allow all 3 students to attend at least one session.
    # Since those are equal, it should pick M:8 W:8 because that lets 1 student attend both
    # and M:9 W:12 does not allow anyone to attend both.
    s = StudentAvailability.new("small_test_case.csv")
    s.optimal_times.should eql({:monday => "8:00 am EDT (12:00 UTC)", :wednesday => "8:00 am EDT (12:00 UTC)"})
  end

  it "should pick mon 3pm and wed 8pm for the actual file" do
    # Choosing Monday at 4pm produces the same solution, but we get 3pm first so pick that one...
    s = StudentAvailability.new("student_availability.csv")
    s.optimal_times.should eql({:monday => "3:00 pm EDT (19:00 UTC)", :wednesday => "8:00 pm EDT (00:00 UTC Thursday)"})
  end
end

describe "Class day" do
  it "should be able to add an attendee and return it" do
    c = ClassDay.new
    c.add_attendee("8:00 am EDT (12:00 UTC)", "Carol Nichols")
    c.get_attendees("8:00 am EDT (12:00 UTC)").should eql(["Carol Nichols"])
  end
  
  it "should be able to add several times and return them" do
    c = ClassDay.new
    c.add_attendee("8:00 am EDT (12:00 UTC)", "Carol Nichols")
    c.add_attendee("9:00 am EDT (13:00 UTC)", "Carol Nichols")
    c.get_times.should eql(["8:00 am EDT (12:00 UTC)", "9:00 am EDT (13:00 UTC)"])
  end
end