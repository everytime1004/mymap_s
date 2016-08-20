# -*- encoding: utf-8 -*-
# stub: devise_token_auth 0.1.38 ruby lib

Gem::Specification.new do |s|
  s.name = "devise_token_auth"
  s.version = "0.1.38"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lynn Hurley"]
  s.date = "2016-07-11"
  s.description = "For use with client side single page apps such as the venerable https://github.com/lynndylanhurley/ng-token-auth."
  s.email = ["lynn.dylan.hurley@gmail.com"]
  s.homepage = "http://github.com/lynndylanhurley/devise_token_auth"
  s.licenses = ["WTFPL"]
  s.rubygems_version = "2.5.1"
  s.summary = "Token based authentication for rails. Uses Devise + OmniAuth."

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["< 6"])
      s.add_runtime_dependency(%q<devise>, ["<= 4.2", "> 3.5.2"])
      s.add_development_dependency(%q<sqlite3>, ["~> 1.3"])
      s.add_development_dependency(%q<pg>, [">= 0"])
      s.add_development_dependency(%q<mysql2>, [">= 0"])
    else
      s.add_dependency(%q<rails>, ["< 6"])
      s.add_dependency(%q<devise>, ["<= 4.2", "> 3.5.2"])
      s.add_dependency(%q<sqlite3>, ["~> 1.3"])
      s.add_dependency(%q<pg>, [">= 0"])
      s.add_dependency(%q<mysql2>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, ["< 6"])
    s.add_dependency(%q<devise>, ["<= 4.2", "> 3.5.2"])
    s.add_dependency(%q<sqlite3>, ["~> 1.3"])
    s.add_dependency(%q<pg>, [">= 0"])
    s.add_dependency(%q<mysql2>, [">= 0"])
  end
end
