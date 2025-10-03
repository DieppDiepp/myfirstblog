/*
  # Create Blog and Projects Schema

  ## Overview
  This migration sets up the database structure for a personal blog and portfolio website.
  It creates tables for blog posts and projects, with proper security policies.

  ## New Tables
  
  ### `blog_posts`
  Stores all blog articles with their content and metadata.
  - `id` (uuid, primary key) - Unique identifier for each post
  - `title` (text) - The blog post title
  - `slug` (text, unique) - URL-friendly version of the title
  - `content` (text) - The full blog post content (supports Markdown)
  - `excerpt` (text) - Short summary/preview of the post
  - `published` (boolean) - Whether the post is visible to public
  - `created_at` (timestamptz) - When the post was created
  - `updated_at` (timestamptz) - Last modification time

  ### `projects`
  Stores portfolio projects to showcase work.
  - `id` (uuid, primary key) - Unique identifier for each project
  - `title` (text) - Project name
  - `description` (text) - Detailed project description
  - `technologies` (text array) - List of technologies used
  - `github_url` (text) - Link to GitHub repository (optional)
  - `demo_url` (text) - Link to live demo (optional)
  - `image_url` (text) - Project thumbnail/screenshot (optional)
  - `display_order` (integer) - Order for displaying projects
  - `published` (boolean) - Whether the project is visible to public
  - `created_at` (timestamptz) - When the project was added

  ## Security
  
  ### Row Level Security (RLS)
  Both tables have RLS enabled with restrictive policies:
  - Public users can only READ published content
  - All write operations require authentication (for admin access)
  
  ### Policies Created
  1. `blog_posts`:
     - "Anyone can view published posts" - Public read access to published posts only
     - "Authenticated users can insert posts" - Only authenticated users can create posts
     - "Authenticated users can update posts" - Only authenticated users can edit posts
     - "Authenticated users can delete posts" - Only authenticated users can delete posts
  
  2. `projects`:
     - "Anyone can view published projects" - Public read access to published projects only
     - "Authenticated users can insert projects" - Only authenticated users can create projects
     - "Authenticated users can update projects" - Only authenticated users can edit projects
     - "Authenticated users can delete projects" - Only authenticated users can delete projects

  ## Notes
  - Blog content supports Markdown formatting
  - Posts use slugs for SEO-friendly URLs
  - Projects can be reordered using display_order
  - Draft posts/projects (published=false) are hidden from public
*/

-- Create blog_posts table
CREATE TABLE IF NOT EXISTS blog_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text UNIQUE NOT NULL,
  content text NOT NULL,
  excerpt text NOT NULL,
  published boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create projects table
CREATE TABLE IF NOT EXISTS projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  technologies text[] DEFAULT '{}',
  github_url text,
  demo_url text,
  image_url text,
  display_order integer DEFAULT 0,
  published boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Blog posts policies
CREATE POLICY "Anyone can view published posts"
  ON blog_posts FOR SELECT
  USING (published = true);

CREATE POLICY "Authenticated users can insert posts"
  ON blog_posts FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update posts"
  ON blog_posts FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete posts"
  ON blog_posts FOR DELETE
  TO authenticated
  USING (true);

-- Projects policies
CREATE POLICY "Anyone can view published projects"
  ON projects FOR SELECT
  USING (published = true);

CREATE POLICY "Authenticated users can insert projects"
  ON projects FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update projects"
  ON projects FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete projects"
  ON projects FOR DELETE
  TO authenticated
  USING (true);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS blog_posts_published_idx ON blog_posts(published, created_at DESC);
CREATE INDEX IF NOT EXISTS blog_posts_slug_idx ON blog_posts(slug);
CREATE INDEX IF NOT EXISTS projects_published_order_idx ON projects(published, display_order);