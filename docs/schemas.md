## Schemas

School
- id: UUID
- name: text

User
- id: UUID
- name: text
- email: text
- school: fkey
- role: enum (student, professor, admin)