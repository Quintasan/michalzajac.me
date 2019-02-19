page "/", layout: "home_page_layout"
page "/blog.html", layout: "post_layout"
page "/talks.html", layout: "post_layout"

activate :asset_hash

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

activate :blog do |blog|
  blog.prefix = "blog"
  blog.layout = "post_layout"
end

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :minify_html
end

activate :deploy do |deploy|
  deploy.deploy_method = :rsync
  deploy.host = "michalzajac.me"
  deploy.path = "/srv/www/michalzajac.me"
  deploy.build_before = true
end
