#!/usr/bin/env ruby

require "fileutils"
require "json"
require "kramdown"
require "time"

ROOT = File.expand_path("..", __dir__)
SOURCE = File.join(ROOT, "blog_backup.json")
DEST = File.join(ROOT, "content", "posts", "imported")

def html_like?(content)
  text = content.to_s.lstrip
  text.start_with?("<") || text.match?(/<(p|div|blockquote|ul|ol|li|figure|img|h[1-6]|pre|table|iframe)\b/i)
end

def body_html(item)
  content = item.fetch("content").to_s
  html = html_like?(content) ? content : Kramdown::Document.new(content, input: "GFM").to_html
  html = html.gsub(%r{<img\b[^>]*src=["']file:///Users/brant/Library/Caches/TemporaryItems/moz-screenshot-2\.png["'][^>]*>\s*}i, "")
  html.gsub(%r{<p>\s*</p>}i, "")
end

def safe_filename(item)
  slug = item["slug"].to_s.strip
  fallback = "typlog-#{item.fetch("id")}"
  name = slug.empty? ? fallback : slug
  name.gsub(/[^A-Za-z0-9._-]+/, "-").gsub(/-+/, "-").gsub(/\A-|-+\z/, "")
end

def output_path(item)
  if item["path_info"].to_s.strip.empty?
    File.join(DEST, "drafts", "#{safe_filename(item)}.html")
  else
    parts = item["path_info"].split("/").reject(&:empty?)
    dir = File.join(DEST, *parts[0...-1])
    File.join(dir, "#{parts[-1]}.html")
  end
end

def front_matter(item)
  published = item["published_at"].to_s.strip
  created = item["created_at"].to_s.strip
  date = published.empty? ? created : published
  authors = item.fetch("authors", [])
  primary_author = authors.find { |author| author["role"] == "primary" } || authors.first

  data = {
    "title" => item.fetch("title"),
    "date" => Time.parse(date).iso8601,
    "lastmod" => Time.parse(item.fetch("updated_at")).iso8601,
    "draft" => item["status"] != "published",
    "slug" => item["slug"],
    "type" => "posts",
    "author" => primary_author && primary_author["name"],
    "tags" => item.fetch("tags", []),
    "typlog" => item.reject { |key, _| key == "content" }
  }

  unless item["path_info"].to_s.strip.empty?
    data["url"] = item["path_info"].sub(%r{/?\z}, "/")
  end

  subtitle = item["subtitle"].to_s.strip
  data["description"] = subtitle unless subtitle.empty?
  data.compact
end

backup = JSON.parse(File.read(SOURCE))
items = backup.fetch("items")

FileUtils.rm_rf(DEST)

items.each do |item|
  path = output_path(item)
  FileUtils.mkdir_p(File.dirname(path))
  front = JSON.pretty_generate(front_matter(item))
  File.write(path, "#{front}\n\n#{body_html(item).strip}\n")
end

published = items.count { |item| item["status"] == "published" }
drafts = items.length - published
markdown = items.count { |item| item["format"] == "markdown" }

puts "Imported #{items.length} posts into #{DEST}"
puts "Published: #{published}, drafts: #{drafts}, markdown sources converted or preserved as HTML: #{markdown}"
