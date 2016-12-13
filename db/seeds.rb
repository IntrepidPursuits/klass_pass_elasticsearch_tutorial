puts "Seeding categories..."
categories = [
  "Spinning",
  "Yoga",
  "Pilates",
  "Barre",
  "Other"
]
categories.each do |name|
  Category.find_or_create_by(name: name)
  puts "- #{name}"
end

puts "Seeding exercise class attributes..."
exercise_class_attributes = [
  "Cardiovascular",
  "Challenging",
  "Relaxing",
  "Strength Building",
  "Technical",
  "Way too hard"
]
exercise_class_attributes.each do |name|
  ExerciseClassAttribute.find_or_create_by(name: name)
  puts "- #{name}"
end

puts "Seeding users..."
users = [
  { name: "Benn S.", email: "benn@example.com" },
  { name: "Bob S.", email: "bob@example.com" },
  { name: "D-Rod", email: "d-rod@example.com" },
  { name: "Danjin S.", email: "danjin@example.com" },
  { name: "Danny R.", email: "danny@example.com" },
  { name: "Helen H.", email: "helen@example.com" },
  { name: "Liz V.", email: "liz@example.com" },
  { name: "Margaret M.", email: "margaret@example.com" },
  { name: "Rachel M.", email: "rachel@example.com" },
  { name: "Vikram R.", email: "vikram@example.com" },
  { name: "Wizard", email: "wizard@example.com" }
]
users.each do |user_attrs|
  user = User.find_or_create_by(user_attrs)
  puts "- #{user.name}"
end

puts "Seeding studios and classes..."
studio_data = [
  {
    name: "Flywheel",
    address: "51 Astor Place, New York, NY",
    classes: [
      { name: "Fly 45", description: "cycling...for 45 minutes", category: "Spinning" },
      { name: "Flybarre", description: "sounds way easier than it is", category: "Barre" }
    ]
  },
  {
    name: "Laughing Lotus",
    address: "125 West 23rd St, New York, NY",
    classes: [
      { name: "Vinyasa Flow", description: "90 min of power flow class", category: "Yoga" },
      { name: "Yin Yoga", description: "Lots of slow stretching", category: "Yoga" },
      { name: "Hip Hop Yoga", description: "Why does this exist", category: "Yoga" }
    ]
  },
  {
    name: "Gramercy Pilates",
    address: "113 3rd Ave, New York, NY",
    classes: [
      { name: "Pilates Reformer - Beginner", description: "for beginners", category: "Pilates" },
      { name: "Pilates Reformer - Intermediate", description: "not for beginners", category: "Pilates" },
      { name: "Pilates Reformer - Advanced", description: "best know what you're doing", category: "Pilates" },
      { name: "Pilates Mat", description: "no machines!", category: "Pilates" }
    ]
  },
  {
    name: "Mile High Run Club",
    address: "28 East 4th St, New York, NY 10003",
    classes: [
      { name: "DASH 28", description: "28 min of intervals on the treadmill, 15 min stability exercises", category: "Other" },
      { name: "HIGH 45", description: "45 min of intervals on the treadmill", category: "Other" },
      { name: "THE DISTANCE", description: "60 min of intervals on the treadmill", category: "Other" }
    ]
  },
  {
    name: "Turnstyle",
    address: "14 Hampshire St, Cambridge, MA 02139",
    classes: [
      { name: "Turnstyle Spin", description: "a spin class", category: "Spinning" },
      { name: "TRX Bootcamp", description: "hang from the ceiling off of strap things", category: "Other" }
    ]
  }
]
studio_data.each do |studio_attrs|
  studio = Studio.find_or_create_by(
    name: studio_attrs[:name],
    address: studio_attrs[:address]
  )

  puts "- #{studio.name}, with classes:"
  studio_attrs[:classes].each do |class_attrs|
    category = Category.find_by(name: class_attrs[:category])
    all_attrs = class_attrs.merge(
      studio: studio,
      category: category
    )

    studio_class = ExerciseClass.find_or_create_by(all_attrs)
    puts "  * #{studio_class.name}"
  end
end

puts "Seeding attendance..."
users = User.all
classes = ExerciseClass.all
dates = (1..4).map { |n| n.days.ago }

users.each do |user|
  dates.each do |date|
    exercise_class = classes.sample
    Attendance.find_or_create_by(
      user: user,
      exercise_class: exercise_class,
      date: date
    )
    puts "- #{user.name} | #{date} | #{exercise_class.name}"
  end
end

puts "Seeding ratings..."
attendances = Attendance.includes(:user, :exercise_class).all
attributes = ExerciseClassAttribute.all

attendances.each do |attendance|
  attribute = attributes.sample
  score = rand(1..5)
  rating = Rating.find_or_initialize_by(
    user: attendance.user,
    exercise_class: attendance.exercise_class
  )
  rating.update(score: score, exercise_class_attribute: attribute)
  puts "- #{attendance.user.name} | #{attendance.exercise_class.name} | #{attribute.name}: #{score}"
end
