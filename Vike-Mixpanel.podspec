Pod::Spec.new do |s|

s.name         = "Vike-Mixpanel"
s.version      = "0.1.4.3"
s.summary      = "Mixpanel integration for Vike's' analytics library"
s.homepage     = "https://github.com/nemezis16/Vike"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Roman Osadchuk" => "roman.osadchuk@thinkmobiles.com" }
s.platform     = :ios, "8.3"
s.source       = { :git => "https://github.com/nemezis16/Vike.git", :tag => "0.1.4.3" }
s.source_files  = "VikeMixpanel/*.{h,m}"
s.requires_arc = true

s.subspec "Mixpanel" do |ss|
ss.dependency 'Mixpanel', '~> 2.9.9'
end

s.subspec "Vike" do |ss|
ss.dependency 'Vike'
end

end