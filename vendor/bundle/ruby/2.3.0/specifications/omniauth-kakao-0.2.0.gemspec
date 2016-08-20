# -*- encoding: utf-8 -*-
# stub: omniauth-kakao 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-kakao"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Shayne Sung-Hee Kang"]
  s.date = "2016-08-08"
  s.description = "OmniAuth strategy for Kakao(http://developers.kakao.com/)"
  s.email = ["shayne.kang@gmail.com"]
  s.homepage = "https://github.com/shaynekang/omniauth-kakao"
  s.licenses = ["MIT"]
  s.rubyforge_project = "omniauth-kakao"
  s.rubygems_version = "2.5.1"
  s.summary = "OmniAuth strategy for Kakao"

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<omniauth>, ["~> 1.0"])
      s.add_runtime_dependency(%q<omniauth-oauth2>, ["~> 1.3.1"])
      s.add_development_dependency(%q<rspec>, [">= 2.14.1", "~> 2.14"])
      s.add_development_dependency(%q<guard-rspec>, [">= 4.2.8", "~> 4.2"])
      s.add_development_dependency(%q<fakeweb>, [">= 1.3.0", "~> 1.3"])
    else
      s.add_dependency(%q<omniauth>, ["~> 1.0"])
      s.add_dependency(%q<omniauth-oauth2>, ["~> 1.3.1"])
      s.add_dependency(%q<rspec>, [">= 2.14.1", "~> 2.14"])
      s.add_dependency(%q<guard-rspec>, [">= 4.2.8", "~> 4.2"])
      s.add_dependency(%q<fakeweb>, [">= 1.3.0", "~> 1.3"])
    end
  else
    s.add_dependency(%q<omniauth>, ["~> 1.0"])
    s.add_dependency(%q<omniauth-oauth2>, ["~> 1.3.1"])
    s.add_dependency(%q<rspec>, [">= 2.14.1", "~> 2.14"])
    s.add_dependency(%q<guard-rspec>, [">= 4.2.8", "~> 4.2"])
    s.add_dependency(%q<fakeweb>, [">= 1.3.0", "~> 1.3"])
  end
end
