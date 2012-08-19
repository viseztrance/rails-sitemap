# Sitemap

A simple ruby on rails sitemap generator.

## Instalation

Install the gem:

```ruby
gem install sitemap
```

Or as a plugin:

```ruby
rails plugin install git://github.com/viseztrance/rails-sitemap.git
```

Then create the initial config file:

```ruby
rails g sitemap:install
```

## Usage

In your sitemap config file, paths can be indexed as follows:

```ruby
Sitemap::Generator.instance.load :host => "mywebsite.com" do
  path :root, :priority => 1
  path :faq, :priority => 0.5, :change_frequency => "weekly"
  literal "/my_blog" #helpful for vanity urls layering search results
  resources :activities, :params => { :format => "html" }
  resources :articles, :objects => proc { Article.published }
end
```

Please read the docs for a more comprehensive list of options.

Building the sitemap:

```ruby
rake sitemap:generate
```

By default the sitemap gets saved in the current application root path. You can change the save path by passing a LOCATION environment variable or using a configuration option:

```ruby
Sitemap.configure do |config|
  config.save_path = "/home/user/apps/my-app/shared"
end
```

Ping search engines:

```ruby
rake sitemap:ping
```

## Setting defaults

You may change the defaults for either *params* or *search* options as follows:

```ruby
Sitemap.configure do |config|
  config.params_format = "html"
  config.search_change_frequency = "monthly"
end
```

## Large sites

Google imposes a limit of 50000 entries per sitemap and maximum size of 10 MB. To comply with these rules,
sitemaps having over 10.000 urls are being split into multiple files. You can change this value by overriding the max urls value:

```ruby
Sitemap.configure do |config|
  config.max_urls = 50000
end
```

## License

This package is licensed under the MIT license and/or the Creative
Commons Attribution-ShareAlike.