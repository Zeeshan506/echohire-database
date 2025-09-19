-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ==============================
-- Users Table
-- ==============================
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    clerk_id TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    role TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- For fuzzy search
CREATE INDEX idx_users_full_name_trgm ON users USING gin (full_name gin_trgm_ops);

-- ==============================
-- Candidates Table
-- ==============================
CREATE TABLE candidates (
    id BIGSERIAL PRIMARY KEY,
    clerk_id TEXT NOT NULL,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    resume_json JSONB DEFAULT '{}'::jsonb,
    current_title TEXT DEFAULT 'Current Title',
    year_experience SMALLINT DEFAULT 0,
    education_level TEXT DEFAULT 'High School',
    career_stage TEXT DEFAULT 'Student',
    awards TEXT[] DEFAULT ARRAY[]::TEXT[],
    publications TEXT[] DEFAULT ARRAY[]::TEXT[],
    ai_summary TEXT DEFAULT '',
    strengths JSONB,
    parsed_skills JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    first_login BOOLEAN DEFAULT TRUE
);

-- ==============================
-- Recruiters Table
-- ==============================
CREATE TABLE recruiters (
    id BIGSERIAL PRIMARY KEY,
    clerk_id TEXT NOT NULL UNIQUE,
    company_name TEXT DEFAULT 'Company Name',
    designation TEXT DEFAULT 'Designation',
    department TEXT DEFAULT 'department',
    recruiter_type TEXT DEFAULT 'not specified',
    recruiter_bio TEXT DEFAULT 'this individual hasn''t had time to add a bio',
    linkedin_url TEXT DEFAULT 'none added',
    recruiter_preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE
);

-- ==============================
-- Job Catalog Table
-- ==============================
CREATE TABLE job_catalog (
    id BIGSERIAL PRIMARY KEY,
    slug TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    job_metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- For fuzzy search
CREATE INDEX idx_job_catalog_slug_trgm ON job_catalog USING gin (slug gin_trgm_ops);
CREATE INDEX idx_job_catalog_title_trgm ON job_catalog USING gin (title gin_trgm_ops);

-- ==============================
-- Skills Table
-- ==============================
CREATE TABLE skills (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- For fuzzy search
CREATE INDEX idx_skills_name_trgm ON skills USING gin (name gin_trgm_ops);

-- ==============================
-- Job Catalog ↔ Skills (M2M)
-- ==============================
CREATE TABLE job_catalog_skills (
    job_catalog_id BIGINT NOT NULL REFERENCES job_catalog(id) ON DELETE CASCADE,
    skill_id BIGINT NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    PRIMARY KEY (job_catalog_id, skill_id)
);

-- ==============================
-- Jobs Table
-- ==============================
CREATE TABLE jobs (
    id BIGSERIAL PRIMARY KEY,
    recruiter_id BIGINT NOT NULL REFERENCES recruiters(id) ON DELETE CASCADE,
    job_catalog_id BIGINT NOT NULL REFERENCES job_catalog(id) ON DELETE CASCADE,
    status TEXT,
    location TEXT,
    employment_type TEXT,
    salary_range TEXT,
    application_deadline TIMESTAMPTZ,
    experience_level TEXT,
    benefits TEXT,
    company_website TEXT,
    contact_email TEXT,
    custom_requirements JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================
-- Jobs ↔ Skills (M2M)
-- ==============================
CREATE TABLE job_skills (
    job_id BIGINT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    skill_id BIGINT NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    PRIMARY KEY (job_id, skill_id)
);

-- ==============================
-- Applications Table
-- ==============================
CREATE TABLE applications (
    id BIGSERIAL PRIMARY KEY,
    candidate_id BIGINT NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    job_id BIGINT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'applied',
    applied_at TIMESTAMPTZ DEFAULT NOW(),
    cover_letter TEXT,
    custom_responses JSONB DEFAULT '{}'::jsonb,
    recruiter_feedback TEXT,
    ai_match_score BIGINT,
    stage TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================
-- Bookmarks Table
-- ==============================
CREATE TABLE bookmarks (
    id BIGSERIAL PRIMARY KEY,
    candidate_id BIGINT NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    job_id BIGINT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    bookmark_type TEXT DEFAULT 'saved',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_candidate_job_bookmark UNIQUE (candidate_id, job_id)
);
