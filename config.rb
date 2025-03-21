require 'lib/article_helpers'
require 'pry'
helpers ArticleHelpers

activate :syntax do |syntax|
  syntax.css_class = ""
end
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

page '/', layout: 'home_page_layout'
page '/blog.html', layout: 'blog_layout'
page '/photos.html', layout: 'blog_layout'
page '/talks.html', layout: 'post_layout'

activate :external_pipeline,
         name: 'esbuild',
         command: build? ? 'npm run build' : 'npm run start',
         source: './dist',
         latency: 1

activate :blog do |blog|
  blog.prefix = 'blog'
  blog.layout = 'post_layout'
end

activate :directory_indexes

configure :build do
  activate :minify_html
end

activate :deploy do |deploy|
  deploy.deploy_method = :rsync
  deploy.host = 'michalzajac.me'
  deploy.path = '/srv/www/michalzajac.me'
  deploy.build_before = true
end
