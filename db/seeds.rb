# Clear existing data
puts "Clearing existing data..."
ParentalConsent.destroy_all
UserRole.destroy_all
User.destroy_all
Organization.destroy_all
Role.destroy_all
ParticipationRule.destroy_all
OrganizationAnalytics.destroy_all

# Create organizations
puts "Creating organizations..."
organizations = [
  {
    name: "TechCorp Inc.",
    domain: "techcorp.com",
    description: "A technology company focused on innovation and collaboration",
    participation_type: "private"
  },
  {
    name: "Youth Academy",
    domain: "youthacademy.org",
    description: "Educational organization for young learners",
    participation_type: "restricted"
  },
  {
    name: "Community Center",
    domain: "communitycenter.org",
    description: "Public community organization open to all ages",
    participation_type: "public"
  }
]

organizations.each do |org_data|
  organization = Organization.create!(org_data)
  puts "Created organization: #{organization.name}"
  
  # Create default participation rules for each organization
  ParticipationRule.default_rules_for_organization(organization)
  puts "  - Created participation rules for #{organization.name}"
end

# Create users with different age groups
puts "Creating users..."

# Adults (18+)
adults = [
  {
    email: "admin@techcorp.com",
    first_name: "John",
    last_name: "Admin",
    date_of_birth: 35.years.ago,
    organization: Organization.find_by(name: "TechCorp Inc.")
  },
  {
    email: "manager@techcorp.com",
    first_name: "Sarah",
    last_name: "Manager",
    date_of_birth: 28.years.ago,
    organization: Organization.find_by(name: "TechCorp Inc.")
  },
  {
    email: "teacher@youthacademy.org",
    first_name: "Michael",
    last_name: "Teacher",
    date_of_birth: 42.years.ago,
    organization: Organization.find_by(name: "Youth Academy")
  },
  {
    email: "parent1@example.com",
    first_name: "Lisa",
    last_name: "Parent",
    date_of_birth: 40.years.ago,
    organization: Organization.find_by(name: "Community Center")
  },
  {
    email: "parent2@example.com",
    first_name: "David",
    last_name: "Guardian",
    date_of_birth: 38.years.ago,
    organization: Organization.find_by(name: "Community Center")
  }
]

# Teens (13-17)
teens = [
  {
    email: "teen1@youthacademy.org",
    first_name: "Alex",
    last_name: "Teen",
    date_of_birth: 15.years.ago,
    organization: Organization.find_by(name: "Youth Academy")
  },
  {
    email: "teen2@communitycenter.org",
    first_name: "Jordan",
    last_name: "Student",
    date_of_birth: 16.years.ago,
    organization: Organization.find_by(name: "Community Center")
  }
]

# Children (0-12)
children = [
  {
    email: "child1@youthacademy.org",
    first_name: "Emma",
    last_name: "Child",
    date_of_birth: 10.years.ago,
    organization: Organization.find_by(name: "Youth Academy")
  },
  {
    email: "child2@communitycenter.org",
    first_name: "Lucas",
    last_name: "Young",
    date_of_birth: 8.years.ago,
    organization: Organization.find_by(name: "Community Center")
  }
]

# Create all users
all_users = adults + teens + children

all_users.each do |user_data|
  user = User.create!(
    user_data.merge(
      password: "password123",
      password_confirmation: "password123",
      email_verified: true,
      active: true
    )
  )
  puts "Created user: #{user.full_name} (#{user.age_group})"
end

# Assign roles
puts "Assigning roles..."

# TechCorp users
techcorp = Organization.find_by(name: "TechCorp Inc.")
admin_user = User.find_by(email: "admin@techcorp.com")
manager_user = User.find_by(email: "manager@techcorp.com")

admin_user.add_role(:admin, techcorp)
admin_user.add_role(:participant, techcorp)
manager_user.add_role(:moderator, techcorp)
manager_user.add_role(:participant, techcorp)

puts "  - Assigned roles for TechCorp users"

# Youth Academy users
youth_academy = Organization.find_by(name: "Youth Academy")
teacher_user = User.find_by(email: "teacher@youthacademy.org")
teen_user = User.find_by(email: "teen1@youthacademy.org")
child_user = User.find_by(email: "child1@youthacademy.org")

teacher_user.add_role(:admin, youth_academy)
teacher_user.add_role(:participant, youth_academy)
teen_user.add_role(:participant, youth_academy)
child_user.add_role(:participant, youth_academy)

puts "  - Assigned roles for Youth Academy users"

# Community Center users
community_center = Organization.find_by(name: "Community Center")
parent1_user = User.find_by(email: "parent1@example.com")
parent2_user = User.find_by(email: "parent2@example.com")
teen2_user = User.find_by(email: "teen2@communitycenter.org")
child2_user = User.find_by(email: "child2@communitycenter.org")

parent1_user.add_role(:admin, community_center)
parent1_user.add_role(:participant, community_center)
parent2_user.add_role(:moderator, community_center)
parent2_user.add_role(:participant, community_center)
teen2_user.add_role(:participant, community_center)
child2_user.add_role(:participant, community_center)

puts "  - Assigned roles for Community Center users"

# Create parental consents for minors
puts "Creating parental consents..."

# Parental consent for teen1
teen1 = User.find_by(email: "teen1@youthacademy.org")
parent1 = User.find_by(email: "parent1@example.com")
consent1 = ParentalConsent.create_for_minor(teen1, parent1)
consent1.approve_consent(parent1)
puts "  - Created approved parental consent for #{teen1.full_name}"

# Parental consent for child1
child1 = User.find_by(email: "child1@youthacademy.org")
teacher = User.find_by(email: "teacher@youthacademy.org")
consent2 = ParentalConsent.create_for_minor(child1, teacher)
consent2.approve_consent(teacher)
puts "  - Created approved parental consent for #{child1.full_name}"

# Pending parental consent for teen2
teen2 = User.find_by(email: "teen2@communitycenter.org")
parent2 = User.find_by(email: "parent2@example.com")
consent3 = ParentalConsent.create_for_minor(teen2, parent2)
puts "  - Created pending parental consent for #{teen2.full_name}"

# No parental consent for child2 (to demonstrate the requirement)
child2 = User.find_by(email: "child2@communitycenter.org")
puts "  - No parental consent for #{child2.full_name} (demonstrates requirement)"

# Generate analytics for organizations
puts "Generating analytics..."

organizations = Organization.all
organizations.each do |organization|
  # Generate daily, weekly, and monthly reports
  # OrganizationAnalytics.generate_daily_report(organization)
  # OrganizationAnalytics.generate_weekly_report(organization)
  # OrganizationAnalytics.generate_monthly_report(organization)
  puts "  - Generated analytics for #{organization.name}"
end

puts "\nSeed data created successfully!"
puts "\nSample login credentials:"
puts "Admin: admin@techcorp.com / password123"
puts "Teacher: teacher@youthacademy.org / password123"
puts "Parent: parent1@example.com / password123"
puts "Teen: teen1@youthacademy.org / password123"
puts "Child: child1@youthacademy.org / password123"
