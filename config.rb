###
# Page options, layouts, aliases and proxies
###

with_layout :guide do
  page "/docs/getting-started/*"
end

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

activate :directory_indexes

activate :syntax
set :markdown_engine, :kramdown

# Methods defined in the helpers block are available in templates
helpers do
end

set :css_dir,     'css'
set :js_dir,      'js'
set :images_dir,  'img'

after_configuration do
  sprockets.append_path File.join(File.dirname(__FILE__), "vendor/css")
  sprockets.append_path File.join(File.dirname(__FILE__), "vendor/js")
  sprockets.append_path File.join(File.dirname(__FILE__), "vendor/img")
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

