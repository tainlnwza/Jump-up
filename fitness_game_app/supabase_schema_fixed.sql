-- =============================================
-- Gamified Fitness App - Database Schema (FIXED)
-- Supabase PostgreSQL
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- USERS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE NOT NULL,
  email TEXT,
  created_at TIMESTAMP DEFAULT NOW(),

  -- Gamification
  level INTEGER DEFAULT 1,
  exp INTEGER DEFAULT 0,
  coins INTEGER DEFAULT 0,
  daily_streak INTEGER DEFAULT 0,
  last_login_date DATE,

  -- Onboarding/Profile data
  fitness_goal TEXT,
  age INTEGER,
  weight_kg DECIMAL,
  height_cm DECIMAL,
  body_shape TEXT,
  physical_limitations TEXT[],
  available_equipment TEXT[],
  preferred_workout_time TIME,

  -- Active program
  following_program_id UUID,
  personalized_build JSONB
);

-- =============================================
-- EXPERT PROGRAMS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS expert_programs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  duration_weeks INTEGER,
  exercises JSONB NOT NULL,
  thumbnail_url TEXT,
  video_urls TEXT[],
  image_urls TEXT[],
  followers_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- WORKOUT SESSIONS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS workout_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  session_type TEXT CHECK (session_type IN ('game', 'workout')),
  started_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,

  -- Results
  exp_earned INTEGER DEFAULT 0,
  coins_earned INTEGER DEFAULT 0,
  poses_completed JSONB,

  -- Game specific
  boss_defeated BOOLEAN,

  -- Workout specific
  program_id UUID REFERENCES expert_programs(id) ON DELETE SET NULL,
  exercises_completed JSONB
);

-- =============================================
-- ACHIEVEMENTS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  unlock_criteria JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS user_achievements (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, achievement_id)
);

-- =============================================
-- SHOP ITEMS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS shop_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  item_type TEXT CHECK (item_type IN ('profile_decoration', 'mascot_skin', 'mascot_accessory')),
  price_coins INTEGER NOT NULL,
  image_url TEXT,
  is_available BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS user_inventory (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  item_id UUID REFERENCES shop_items(id) ON DELETE CASCADE,
  purchased_at TIMESTAMP DEFAULT NOW(),
  is_equipped BOOLEAN DEFAULT false,
  PRIMARY KEY (user_id, item_id)
);

-- =============================================
-- QUESTS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS quests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  quest_type TEXT CHECK (quest_type IN ('daily', 'weekly', 'special')),
  requirements JSONB NOT NULL,
  rewards JSONB NOT NULL,
  expires_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_quest_progress (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  quest_id UUID REFERENCES quests(id) ON DELETE CASCADE,
  progress JSONB,
  completed_at TIMESTAMP,
  PRIMARY KEY (user_id, quest_id)
);

-- =============================================
-- INDEXES
-- =============================================
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_expert_programs_creator_id ON expert_programs(creator_id);
CREATE INDEX IF NOT EXISTS idx_expert_programs_created_at ON expert_programs(created_at DESC);

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE expert_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_quest_progress ENABLE ROW LEVEL SECURITY;

-- Users: Can only view/edit own data
DROP POLICY IF EXISTS "Users can view own data" ON users;
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (firebase_uid = auth.uid()::text);

DROP POLICY IF EXISTS "Users can update own data" ON users;
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (firebase_uid = auth.uid()::text);

DROP POLICY IF EXISTS "Users can insert own data" ON users;
CREATE POLICY "Users can insert own data"
  ON users FOR INSERT
  WITH CHECK (true);

-- Expert Programs: Public read, only creators can edit
DROP POLICY IF EXISTS "Anyone can view programs" ON expert_programs;
CREATE POLICY "Anyone can view programs"
  ON expert_programs FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can create programs" ON expert_programs;
CREATE POLICY "Users can create programs"
  ON expert_programs FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Creators can edit own programs" ON expert_programs;
CREATE POLICY "Creators can edit own programs"
  ON expert_programs FOR UPDATE
  USING (creator_id IN (SELECT id FROM users WHERE firebase_uid = auth.uid()::text));

DROP POLICY IF EXISTS "Creators can delete own programs" ON expert_programs;
CREATE POLICY "Creators can delete own programs"
  ON expert_programs FOR DELETE
  USING (creator_id IN (SELECT id FROM users WHERE firebase_uid = auth.uid()::text));

-- Workout Sessions: Users can only see own sessions
DROP POLICY IF EXISTS "Users can view own sessions" ON workout_sessions;
CREATE POLICY "Users can view own sessions"
  ON workout_sessions FOR SELECT
  USING (user_id IN (SELECT id FROM users WHERE firebase_uid = auth.uid()::text));

DROP POLICY IF EXISTS "Users can insert own sessions" ON workout_sessions;
CREATE POLICY "Users can insert own sessions"
  ON workout_sessions FOR INSERT
  WITH CHECK (true);

-- User Achievements: Users can only see own achievements
DROP POLICY IF EXISTS "Users can view own achievements" ON user_achievements;
CREATE POLICY "Users can view own achievements"
  ON user_achievements FOR SELECT
  USING (user_id IN (SELECT id FROM users WHERE firebase_uid = auth.uid()::text));

DROP POLICY IF EXISTS "System can insert achievements" ON user_achievements;
CREATE POLICY "System can insert achievements"
  ON user_achievements FOR INSERT
  WITH CHECK (true);

-- User Inventory: Users can only see own inventory
DROP POLICY IF EXISTS "Users can view own inventory" ON user_inventory;
CREATE POLICY "Users can view own inventory"
  ON user_inventory FOR SELECT
  USING (user_id IN (SELECT id FROM users WHERE firebase_uid = auth.uid()::text));

DROP POLICY IF EXISTS "Users can manage own inventory" ON user_inventory;
CREATE POLICY "Users can manage own inventory"
  ON user_inventory FOR ALL
  USING (user_id IN (SELECT id FROM users WHERE firebase_uid = auth.uid()::text));

-- User Quest Progress: Users can only see own progress
DROP POLICY IF EXISTS "Users can view own quest progress" ON user_quest_progress;
CREATE POLICY "Users can view own quest progress"
  ON user_quest_progress FOR SELECT
  USING (user_id IN (SELECT id FROM users WHERE firebase_uid = auth.uid()::text));

DROP POLICY IF EXISTS "Users can update own quest progress" ON user_quest_progress;
CREATE POLICY "Users can update own quest progress"
  ON user_quest_progress FOR ALL
  USING (user_id IN (SELECT id FROM users WHERE firebase_uid = auth.uid()::text));

-- =============================================
-- FUNCTIONS
-- =============================================

-- Function to add exp and coins to user
CREATE OR REPLACE FUNCTION add_exp_and_coins(
  user_id_param UUID,
  exp_amount INTEGER,
  coins_amount INTEGER
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE users
  SET
    exp = exp + exp_amount,
    coins = coins + coins_amount
  WHERE id = user_id_param;
END;
$$;

-- =============================================
-- SEED DATA: Initial Achievements
-- =============================================
INSERT INTO achievements (name, description, icon_url, unlock_criteria) VALUES
('First Victory', 'Win your first boss battle', null, '{"type": "boss_victories", "count": 1}'),
('First Workout', 'Complete your first workout', null, '{"type": "workouts_completed", "count": 1}'),
('Getting Started', 'Reach level 2', null, '{"type": "level", "value": 2}'),
('Dedicated', 'Maintain a 5-day streak', null, '{"type": "daily_streak", "count": 5}'),
('Level 10', 'Reach level 10', null, '{"type": "level", "value": 10}'),
('100 Battles', 'Complete 100 boss battles', null, '{"type": "boss_battles", "count": 100}')
ON CONFLICT DO NOTHING;

-- =============================================
-- SEED DATA: Sample Shop Items
-- =============================================
INSERT INTO shop_items (name, description, item_type, price_coins, image_url) VALUES
('Golden Border', 'Stylish golden profile border', 'profile_decoration', 100, null),
('Silver Badge', 'Silver achievement badge', 'profile_decoration', 50, null),
('Fire Mascot', 'Fiery red mascot skin', 'mascot_skin', 200, null),
('Ice Mascot', 'Cool blue mascot skin', 'mascot_skin', 200, null),
('Sunglasses', 'Cool sunglasses accessory', 'mascot_accessory', 75, null),
('Crown', 'Royal crown accessory', 'mascot_accessory', 150, null)
ON CONFLICT DO NOTHING;

-- =============================================
-- SEED DATA: Sample Daily Quest
-- =============================================
INSERT INTO quests (title, description, quest_type, requirements, rewards, expires_at) VALUES
('Daily Warrior', 'Complete 3 boss battles today', 'daily', '{"type": "complete_battles", "count": 3}', '{"exp": 150, "coins": 75}', NOW() + INTERVAL '1 day'),
('Fitness Enthusiast', 'Complete 2 workouts today', 'daily', '{"type": "complete_workouts", "count": 2}', '{"exp": 200, "coins": 100}', NOW() + INTERVAL '1 day')
ON CONFLICT DO NOTHING;
