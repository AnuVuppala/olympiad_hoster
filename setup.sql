-- Run this in Supabase SQL Editor

create table if not exists schools (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  code text unique not null,
  district text not null,
  state text default 'Telangana',
  status text default 'ACTIVE',
  created_at timestamptz default now()
);

create table if not exists users (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  roll_no text not null,
  class int not null,
  password text not null,
  role text default 'STUDENT',
  activated boolean default true,
  school_id uuid references schools(id),
  parent_email text,
  parent_phone text,
  created_at timestamptz default now(),
  unique(school_id, roll_no)
);

create table if not exists questions (
  id uuid default gen_random_uuid() primary key,
  class int not null,
  topic text not null,
  difficulty text default 'MEDIUM',
  text text not null,
  option_a text not null,
  option_b text not null,
  option_c text not null,
  option_d text not null,
  correct int not null,
  approved boolean default true,
  created_at timestamptz default now()
);

create table if not exists quiz_sessions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id),
  school_id uuid references schools(id),
  round text not null,
  class int not null,
  district text not null,
  status text default 'IN_PROGRESS',
  score int default 0,
  strike_count int default 0,
  current_q int default 0,
  total_ms bigint default 0,
  started_at timestamptz default now(),
  completed_at timestamptz,
  unique(user_id, round)
);

create table if not exists answers (
  id uuid default gen_random_uuid() primary key,
  session_id uuid references quiz_sessions(id),
  user_id uuid references users(id),
  question_id uuid references questions(id),
  chosen int,
  is_correct boolean default false,
  response_ms int default 0,
  points int default 0,
  answered_at timestamptz default now(),
  unique(session_id, question_id)
);

create table if not exists reconnect_logs (
  id uuid default gen_random_uuid() primary key,
  session_id uuid references quiz_sessions(id),
  user_id uuid references users(id),
  reason text not null,
  ip_before text,
  ip_after text,
  cleared boolean default false,
  created_at timestamptz default now()
);

-- Enable Row Level Security but allow all for now (you can tighten later)
alter table schools enable row level security;
alter table users enable row level security;
alter table questions enable row level security;
alter table quiz_sessions enable row level security;
alter table answers enable row level security;
alter table reconnect_logs enable row level security;

create policy "allow all" on schools for all using (true) with check (true);
create policy "allow all" on users for all using (true) with check (true);
create policy "allow all" on questions for all using (true) with check (true);
create policy "allow all" on quiz_sessions for all using (true) with check (true);
create policy "allow all" on answers for all using (true) with check (true);
create policy "allow all" on reconnect_logs for all using (true) with check (true);

-- Seed: demo school
insert into schools (name, code, district) values
  ('Delhi Public School Hyderabad', 'SCH-2847', 'Hyderabad'),
  ('Hyderabad Public School', 'SCH-1093', 'Hyderabad')
on conflict (code) do nothing;

-- Seed: company admin (password: admin123)
insert into users (name, roll_no, class, password, role, activated, school_id)
select 'Company Admin', 'ADMIN001', 0, 'admin123', 'COMPANY_ADMIN', true, id
from schools where code = 'SCH-2847'
on conflict do nothing;

-- Seed: school admin (password: school123)
insert into users (name, roll_no, class, password, role, activated, school_id)
select 'School Admin', 'SADMIN001', 0, 'school123', 'SCHOOL_ADMIN', true, id
from schools where code = 'SCH-2847'
on conflict do nothing;

-- Seed: demo student (password: quiz8018)
insert into users (name, roll_no, class, password, role, activated, school_id, parent_email, parent_phone)
select 'Arjun Kumar', '2024-05-018', 5, 'quiz8018', 'STUDENT', true, id, 'parent@example.com', '+919000000000'
from schools where code = 'SCH-2847'
on conflict do nothing;

-- Seed: sample questions Class 5
insert into questions (class, topic, difficulty, text, option_a, option_b, option_c, option_d, correct) values
(5,'Science','EASY','Which gas do plants absorb during photosynthesis?','Oxygen','Nitrogen','Carbon Dioxide','Hydrogen',2),
(5,'Geography','EASY','What is the capital of Telangana?','Warangal','Nizamabad','Karimnagar','Hyderabad',3),
(5,'History','MEDIUM','In which year did India gain independence?','1945','1947','1950','1948',1),
(5,'Science','EASY','Which planet is closest to the Sun?','Venus','Mars','Earth','Mercury',3),
(5,'Sports','EASY','How many players are in a cricket team?','10','12','9','11',3),
(5,'History','MEDIUM','Who is known as the Father of the Nation in India?','Nehru','Bose','Gandhi','Patel',2),
(5,'Science','MEDIUM','What is the chemical symbol for Gold?','Go','Gd','Ag','Au',3),
(5,'Geography','MEDIUM','Which is the longest river in India?','Yamuna','Brahmaputra','Godavari','Ganga',3),
(5,'Science','MEDIUM','How many bones are in an adult human body?','206','196','210','186',0),
(5,'History','MEDIUM','Who wrote the Indian national anthem?','Bankim Chandra','Sarojini Naidu','Subramania Bharati','Rabindranath Tagore',3),
(5,'Geography','EASY','What is the largest ocean on Earth?','Atlantic','Indian','Arctic','Pacific',3),
(5,'Science','EASY','What is the closest star to Earth?','Sirius','Proxima Centauri','Betelgeuse','The Sun',3),
(5,'Sports','MEDIUM','Who has scored the most international centuries in cricket?','Sourav Ganguly','Virat Kohli','Sachin Tendulkar','Rahul Dravid',2),
(5,'Geography','MEDIUM','Which is the smallest state in India by area?','Sikkim','Goa','Tripura','Meghalaya',1),
(5,'History','HARD','In which year was the Indian Constitution adopted?','1947','1948','1950','1952',2),
(5,'Science','MEDIUM','Which planet has the most moons?','Jupiter','Uranus','Neptune','Saturn',3),
(5,'Geography','EASY','What is the capital of India?','Mumbai','Kolkata','Chennai','New Delhi',3),
(5,'History','MEDIUM','Who was the first Prime Minister of India?','Sardar Patel','B.R. Ambedkar','Jawaharlal Nehru','Rajendra Prasad',2),
(5,'Science','HARD','What is the speed of light approximately?','3 lakh km/s','1 lakh km/s','5 lakh km/s','2 lakh km/s',0),
(5,'Sports','MEDIUM','In which sport is the Durand Cup awarded?','Cricket','Hockey','Football','Badminton',2),
(5,'Geography','MEDIUM','Which is the largest desert in the world?','Gobi','Sahara','Thar','Arabian',1),
(5,'History','MEDIUM','Who invented the telephone?','Edison','Tesla','Marconi','Graham Bell',3),
(5,'Science','EASY','What is the boiling point of water?','90°C','80°C','110°C','100°C',3),
(5,'Geography','HARD','What is the capital of Australia?','Sydney','Melbourne','Brisbane','Canberra',3),
(5,'History','MEDIUM','Which country gifted the Statue of Liberty to the USA?','UK','France','Germany','Spain',1),
(5,'Science','MEDIUM','Which vitamin is produced by sunlight?','Vitamin A','Vitamin C','Vitamin D','Vitamin B12',2),
(5,'Sports','HARD','How many gold medals did India win at the 2020 Tokyo Olympics?','0','1','2','3',1),
(5,'Geography','MEDIUM','How many states does India have?','28','27','29','30',0),
(5,'History','EASY','What does the Ashoka Chakra on the Indian flag represent?','Peace','Strength','Law of Dharma','Unity',2),
(5,'Science','MEDIUM','Which organ in the human body produces insulin?','Liver','Kidney','Heart','Pancreas',3)
on conflict do nothing;
