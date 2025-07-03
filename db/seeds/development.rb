10.times do |i|
  Project.create(name: "sample Project#{i + 1}")
end