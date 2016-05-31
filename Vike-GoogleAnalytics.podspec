Pod::Spec.new do |s|

s.name         = "Vike-GoogleAnalytics"
s.version      = "0.1.4.3"
s.summary      = "GoogleAnalytics integration for Vike's' analytics library"
s.homepage     = "https://github.com/nemezis16/Vike"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Roman Osadchuk" => "roman.osadchuk@thinkmobiles.com" }
s.platform     = :ios, "8.3"
s.source       = { :git => "https://github.com/nemezis16/Vike.git", :tag => "0.1.4.3" }
s.source_files  = "VikeGoogleAnalytics/*.{h,m}"
s.requires_arc = true

s.subspec "Google" do |ss|
ss.dependency 'Google/Analytics', '~> 3.0.3'
end

s.subspec "Vike" do |ss|
ss.dependency 'Vike'
end

end