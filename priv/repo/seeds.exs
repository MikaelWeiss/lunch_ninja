# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LunchNinja.Repo.insert!(%LunchNinja.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias LunchNinja.Repo
alias LunchNinja.Organizations.{School, TimeSlot}
alias LunchNinja.Accounts.User

# Clear existing data (for development only)
Repo.delete_all(TimeSlot)
Repo.delete_all(User)
Repo.delete_all(School)

# Create Schools
stanford =
  Repo.insert!(%School{
    name: "Stanford University",
    slug: "stanford",
    contact_email: "admin@stanford.edu"
  })

mit =
  Repo.insert!(%School{
    name: "MIT",
    slug: "mit",
    contact_email: "admin@mit.edu"
  })

# Create Time Slots for Stanford
Repo.insert!(%TimeSlot{
  school_id: stanford.id,
  name: "Early Lunch",
  start_time: ~T[11:30:00],
  end_time: ~T[12:30:00],
  active: true
})

Repo.insert!(%TimeSlot{
  school_id: stanford.id,
  name: "Late Lunch",
  start_time: ~T[12:30:00],
  end_time: ~T[13:30:00],
  active: true
})

# Create Time Slots for MIT
Repo.insert!(%TimeSlot{
  school_id: mit.id,
  name: "Lunch Block 1",
  start_time: ~T[12:00:00],
  end_time: ~T[13:00:00],
  active: true
})

Repo.insert!(%TimeSlot{
  school_id: mit.id,
  name: "Lunch Block 2",
  start_time: ~T[13:00:00],
  end_time: ~T[14:00:00],
  active: true
})

# Create Users for Stanford
Repo.insert!(%User{
  email: "admin@stanford.edu",
  name: "Sarah Admin",
  role: :admin,
  school_id: stanford.id
})

Repo.insert!(%User{
  email: "prof.johnson@stanford.edu",
  name: "Prof. Michael Johnson",
  role: :teacher,
  school_id: stanford.id
})

Repo.insert!(%User{
  email: "prof.williams@stanford.edu",
  name: "Prof. Emily Williams",
  role: :teacher,
  school_id: stanford.id
})

Repo.insert!(%User{
  email: "alice@stanford.edu",
  name: "Alice Chen",
  role: :student,
  school_id: stanford.id
})

Repo.insert!(%User{
  email: "bob@stanford.edu",
  name: "Bob Martinez",
  role: :student,
  school_id: stanford.id
})

Repo.insert!(%User{
  email: "charlie@stanford.edu",
  name: "Charlie Davis",
  role: :student,
  school_id: stanford.id
})

# Create Users for MIT
Repo.insert!(%User{
  email: "admin@mit.edu",
  name: "John Admin",
  role: :admin,
  school_id: mit.id
})

Repo.insert!(%User{
  email: "prof.smith@mit.edu",
  name: "Prof. Robert Smith",
  role: :teacher,
  school_id: mit.id
})

Repo.insert!(%User{
  email: "prof.brown@mit.edu",
  name: "Prof. Lisa Brown",
  role: :teacher,
  school_id: mit.id
})

Repo.insert!(%User{
  email: "dave@mit.edu",
  name: "Dave Wilson",
  role: :student,
  school_id: mit.id
})

Repo.insert!(%User{
  email: "eve@mit.edu",
  name: "Eve Taylor",
  role: :student,
  school_id: mit.id
})

IO.puts("Seeds completed successfully!")
IO.puts("Created 2 schools, 11 users, and 4 time slots")
