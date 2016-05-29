Pod::Spec.new do |s|

  s.name         = "Vike"
  s.version      = "0.1"
  s.summary      = "A library that gives you single sign to most popular analytics, like Flurry, Mixpanel, GoogleAnalytics, etc."
  s.homepage     = "https://github.com/nemezis16/Vike"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Roman Osadchuk" => "roman.osadchuk@thinkmobiles.com" }
  s.social_media_url   = "https://www.facebook.com/roman.osadchuk.7"
  s.platform     = :ios, "9.3.2"
  s.source       = { :git => "https://github.com/nemezis16/Vike.git", :tag => "0.1" }
  s.source_files  = "*"  
  s.requires_arc = true

end
