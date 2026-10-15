-- ========================================================
-- Team-AR: Complete Database Schema for V2 (Workouts, Diet & Logs)
-- Target Supabase Project: exiovcdrkakpwpvuplzb
-- ========================================================

-- 1. جدول الجلسات التدريبية المباشرة (Workout Sessions)
CREATE TABLE IF NOT EXISTS public.workout_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    workout_day_id INTEGER,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. جدول تسجيل الجولات (Set Logs)
CREATE TABLE IF NOT EXISTS public.set_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL,
    exercise_name TEXT,
    set_number INTEGER NOT NULL,
    weight_kg DECIMAL(6,2) NOT NULL,
    reps INTEGER NOT NULL,
    feeling INTEGER CHECK (feeling IN (1,2,3,4)),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. جدول تسجيل الوجبات اليومية (Meal Logs)
CREATE TABLE IF NOT EXISTS public.meal_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    meal_id INTEGER NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, meal_id, date)
);

-- 4. جدول إعدادات التنبيهات (Reminder Settings)
CREATE TABLE IF NOT EXISTS public.reminder_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    meal_reminders JSONB DEFAULT '{}'::jsonb,
    quiet_hours_start TEXT DEFAULT '23:00',
    quiet_hours_end TEXT DEFAULT '07:00',
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. جدول خطط التمارين والجداول (Workouts)
CREATE TABLE IF NOT EXISTS public.workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coach_id TEXT NOT NULL,
    trainee_id TEXT NOT NULL,
    title TEXT NOT NULL,
    target_muscles TEXT[] DEFAULT '{}',
    pdf_attachment_url TEXT,
    intro_video_url TEXT,
    scheduled_date DATE DEFAULT CURRENT_DATE,
    day_of_week TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. جدول تفاصيل التمارين داخل الجدول (Exercises)
CREATE TABLE IF NOT EXISTS public.exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    video_guide_url TEXT,
    technical_tip TEXT,
    target_sets INT NOT NULL DEFAULT 3,
    target_reps_range TEXT NOT NULL DEFAULT '8-10',
    rest_seconds INT NOT NULL DEFAULT 120,
    rir INT NOT NULL DEFAULT 2,
    tempo TEXT NOT NULL DEFAULT '3-2-2',
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. جدول سجلات التمارين للمتدربين (Exercise Logs)
CREATE TABLE IF NOT EXISTS public.exercise_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID REFERENCES public.exercises(id) ON DELETE SET NULL,
    trainee_id TEXT NOT NULL,
    date TIMESTAMPTZ NOT NULL DEFAULT now(),
    effort_rating TEXT DEFAULT 'moderate',
    coach_feedback_notes TEXT,
    completed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. جدول سجلات الجولات التفاعلية (Exercise Set Logs)
CREATE TABLE IF NOT EXISTS public.exercise_set_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_log_id UUID NOT NULL REFERENCES public.exercise_logs(id) ON DELETE CASCADE,
    set_number INT NOT NULL,
    weight NUMERIC(6,2) NOT NULL DEFAULT 0.0,
    weight_unit TEXT NOT NULL DEFAULT 'kg',
    reps INT NOT NULL DEFAULT 0,
    is_completed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 9. جدول الأنظمة الغذائية (Diet Plans)
CREATE TABLE IF NOT EXISTS public.diet_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trainee_id TEXT NOT NULL,
    coach_id TEXT NOT NULL,
    plan_type TEXT NOT NULL DEFAULT 'Moderate Carb Day',
    target_calories NUMERIC(8,2) NOT NULL DEFAULT 2000.0,
    target_protein NUMERIC(6,2) NOT NULL DEFAULT 150.0,
    target_carbs NUMERIC(6,2) NOT NULL DEFAULT 200.0,
    target_fats NUMERIC(6,2) NOT NULL DEFAULT 60.0,
    water_target_liters NUMERIC(4,2) NOT NULL DEFAULT 4.0,
    coach_instructions TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 10. جدول الوجبات (Meals)
CREATE TABLE IF NOT EXISTS public.meals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    diet_plan_id UUID NOT NULL REFERENCES public.diet_plans(id) ON DELETE CASCADE,
    meal_type TEXT NOT NULL,
    total_calories NUMERIC(8,2) NOT NULL DEFAULT 0.0,
    total_protein NUMERIC(6,2) NOT NULL DEFAULT 0.0,
    total_carbs NUMERIC(6,2) NOT NULL DEFAULT 0.0,
    total_fats NUMERIC(6,2) NOT NULL DEFAULT 0.0,
    cooking_video_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 11. جدول مكونات الوجبة (Meal Ingredients)
CREATE TABLE IF NOT EXISTS public.meal_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_id UUID NOT NULL REFERENCES public.meals(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    quantity_unit TEXT NOT NULL,
    calories NUMERIC(6,2) NOT NULL DEFAULT 0.0,
    icon_key TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 12. جدول متابعة استهلاك المتدرب للوجبات (Trainee Meal Logs)
CREATE TABLE IF NOT EXISTS public.trainee_meal_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_id UUID NOT NULL REFERENCES public.meals(id) ON DELETE CASCADE,
    trainee_id TEXT NOT NULL,
    logged_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_consumed BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ========================================================
-- الفهارس لتحسين سرعة الاستعلام (Indexes)
-- ========================================================
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user ON public.workout_sessions(user_id, date);
CREATE INDEX IF NOT EXISTS idx_set_logs_session ON public.set_logs(session_id);
CREATE INDEX IF NOT EXISTS idx_meal_logs_user_date ON public.meal_logs(user_id, date);
CREATE INDEX IF NOT EXISTS idx_set_logs_exercise ON public.set_logs(exercise_id);
CREATE INDEX IF NOT EXISTS idx_workouts_trainee ON public.workouts(trainee_id);
CREATE INDEX IF NOT EXISTS idx_workouts_coach ON public.workouts(coach_id);
CREATE INDEX IF NOT EXISTS idx_exercises_workout ON public.exercises(workout_id);
CREATE INDEX IF NOT EXISTS idx_exercise_logs_trainee ON public.exercise_logs(trainee_id);
CREATE INDEX IF NOT EXISTS idx_exercise_set_logs_log ON public.exercise_set_logs(exercise_log_id);
CREATE INDEX IF NOT EXISTS idx_diet_plans_trainee ON public.diet_plans(trainee_id);
CREATE INDEX IF NOT EXISTS idx_meals_plan ON public.meals(diet_plan_id);

-- ========================================================
-- تفعيل أمان الصفوف (Row Level Security - RLS)
-- ========================================================
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.set_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminder_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_set_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diet_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trainee_meal_logs ENABLE ROW LEVEL SECURITY;

-- ========================================================
-- سياسات الوصول (RLS Policies) المتوافقة مع anonKey في تطبيق الهاتف
-- ========================================================
DO $$
BEGIN
    DROP POLICY IF EXISTS "allow_all_workout_sessions" ON public.workout_sessions;
    CREATE POLICY "allow_all_workout_sessions" ON public.workout_sessions FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "allow_all_set_logs" ON public.set_logs;
    CREATE POLICY "allow_all_set_logs" ON public.set_logs FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "allow_all_meal_logs" ON public.meal_logs;
    CREATE POLICY "allow_all_meal_logs" ON public.meal_logs FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "allow_all_reminder_settings" ON public.reminder_settings;
    CREATE POLICY "allow_all_reminder_settings" ON public.reminder_settings FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access to workouts" ON public.workouts;
    CREATE POLICY "Public access to workouts" ON public.workouts FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access to exercises" ON public.exercises;
    CREATE POLICY "Public access to exercises" ON public.exercises FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access to exercise_logs" ON public.exercise_logs;
    CREATE POLICY "Public access to exercise_logs" ON public.exercise_logs FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access to exercise_set_logs" ON public.exercise_set_logs;
    CREATE POLICY "Public access to exercise_set_logs" ON public.exercise_set_logs FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access to diet_plans" ON public.diet_plans;
    CREATE POLICY "Public access to diet_plans" ON public.diet_plans FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access to meals" ON public.meals;
    CREATE POLICY "Public access to meals" ON public.meals FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access to meal_ingredients" ON public.meal_ingredients;
    CREATE POLICY "Public access to meal_ingredients" ON public.meal_ingredients FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access to trainee_meal_logs" ON public.trainee_meal_logs;
    CREATE POLICY "Public access to trainee_meal_logs" ON public.trainee_meal_logs FOR ALL USING (true) WITH CHECK (true);
END $$;
