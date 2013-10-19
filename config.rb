require "slim"

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

with_layout :guide do
  page "/getting-started/*"
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

activate :syntax
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true

# Methods defined in the helpers block are available in templates
helpers do
  def current_page?(page)
    page.sub(%r{^/}, '') == request["path"]
  end

  def guide_nav(title, page)
    path = "/getting-started/#{page}.html"

    if current_page?(path)
      %{<span class="glyphicon glyphicon-bookmark"></span> } + title
    else
      link_to(title, path)
    end
  end

  def guide_sections
    [ [ "introduction", "Introduction" ],
      [ "installing", "Installing Test Kitchen" ],
      [ "getting-help", "Getting Help" ],
      [ "creating-cookbook", "Creating a Cookbook" ],
      [ "writing-recipe", "Writing a Recipe" ],
      [ "running-converge", "Running Kitchen Converge" ],
      [ "manually-verifying", "Manually Verifying" ],
      [ "writing-test", "Writing a Test" ],
      [ "running-verify", "Running Kitchen Verify" ],
      [ "running-test", "Running Kitchen Test" ],
      [ "adding-platform", "Adding a Platform"  ],
      [ "fixing-converge", "Fixing Converge" ],
      [ "adding-dependency", "Adding a Dependency" ],
    ]
  end

  def guide_index
    page = File.basename(request["path"]).sub(%r{\.html$}, '')
    guide_sections.index { |s| s.first == page }
  end

  def guide_progress
    ((guide_index + 1.0) / guide_sections.size) * 100
  end
end

set :css_dir, 'css'

set :js_dir, 'js'

set :images_dir, 'img'

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

