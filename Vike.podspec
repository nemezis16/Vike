Pod::Spec.new do |s|

  s.name         = "Vike"
  s.version      = "0.1.3"
  s.summary      = "A library that gives you single sign to most popular analytics, like Flurry, Mixpanel, GoogleAnalytics, etc."
  s.homepage     = "https://github.com/nemezis16/Vike"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Roman Osadchuk" => "roman.osadchuk@thinkmobiles.com" }
  s.platform     = :ios, "8.3"
  s.source       = { :git => "https://github.com/nemezis16/Vike.git", :tag => "0.1.3" }
  s.source_files  = "VikeTestProject/Vike/Classes/*.{h,m}"
  s.requires_arc = true

s.subspec "AWSCognito" do |ss|
ss.dependency 'AWSCognito'
end

s.subspec "AWSKinesis" do |ss|
ss.dependency 'AWSKinesis'
end

s.subspec "AWSCore" do |ss|
ss.dependency 'AWSCore'
end

end
