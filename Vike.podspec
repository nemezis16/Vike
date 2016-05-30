Pod::Spec.new do |s|

  s.name         = "Vike"
  s.version      = "0.1.2"
  s.summary      = "A library that gives you single sign to most popular analytics, like Flurry, Mixpanel, GoogleAnalytics, etc."
  s.homepage     = "https://github.com/nemezis16/Vike"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Roman Osadchuk" => "roman.osadchuk@thinkmobiles.com" }
  s.social_media_url   = "https://www.facebook.com/roman.osadchuk.7"
  s.platform     = :ios, "8.3"
  s.source       = { :git => "https://github.com/nemezis16/Vike.git", :tag => "0.1.2" }
  s.source_files  = "Classes/*.{h,m}"
  s.requires_arc = true
  s.dependency 'AWSCore'
  s.dependency 'AWSCognito'
  s.dependency 'AWSKinesis'

end
