# describe directory("C:\\ProgramData\\JnJ\\Its_core") do
#   it { should be_owned_by 'Administrators' }
#   it { should be_grouped_into 'Administrators' }
#   #its('mode') { should cmp 0755 }
#   end

# describe file("C:\\Windows\\its_core_version.txt") do
#   it { should be_owned_by 'Administrators' }
#   it { should be_grouped_into 'Administrators' }
#   #its('mode') { should cmp 0644 }
#   end

# describe file("C:\\ProgramData\\JnJ\\Its_core\\version.txt") do
#   it { should be_owned_by 'Administrators' }
#   it { should be_grouped_into 'Administrators' }
#   #its('mode') { should cmp 0644 }
#   end
# describe directory('C:\\ProgramData\\JnJ\\Its_core') do
#   #its('owner') { should eq 'Administrators' }
#   it { should be_owned_by 'Administrators' }
#   its('mode') { should cmp '00755' }
# end
describe directory("C:\\ProgramData\\JnJ\\Its_core") do
  it { should be_directory }
end
describe file("C:\\Windows\\its_core_version.txt") do
  it { should be_file }
end
describe file("C:\\ProgramData\\JnJ\\Its_core\\version.txt") do
   it { should be_file }
end
describe directory('C:\\ProgramData\\JnJ\\Its_core') do
  it { should be_directory }
end