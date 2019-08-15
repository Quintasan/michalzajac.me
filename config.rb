require 'lib/article_helpers'
require 'pry'
helpers ArticleHelpers

page "/", layout: "home_page_layout"
page "/blog.html", layout: "post_layout"
page "/talks.html", layout: "post_layout"

activate :external_pipeline,
  name: :broccoli,
  command: (build? ? 'yarn broccoli build tmp/assets' : 'yarn broccoli serve --output-path=tmp/assets'),
  source: "tmp/assets",
  latency: 2

activate :blog do |blog|
  blog.prefix = "blog"
  blog.layout = "post_layout"
end

activate :deploy do |deploy|
  deploy.deploy_method = :rsync
  deploy.host = "michalzajac.me"
  deploy.path = "/srv/www/michalzajac.me"
  deploy.build_before = true
end
