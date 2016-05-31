Pod::Spec.new do |s|

s.name         = "Vike-Crashlytics"
s.version      = "0.1.4.3"
s.summary      = "Crashlytics integration for Vike's' analytics library"
s.homepage     = "https://github.com/nemezis16/Vike"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Roman Osadchuk" => "roman.osadchuk@thinkmobiles.com" }
s.platform     = :ios, "8.3"
s.source       = { :git => "https://github.com/nemezis16/Vike.git", :tag => "0.1.4.3" }
s.source_files  = "VikeCrashlytics/*.{h,m}"
s.requires_arc = true

s.subspec "Fabric" do |ss|
ss.dependency 'Fabric', '~> 1.6.7'
end

s.subspec "Crashlytics" do |ss|
ss.dependency 'Crashlytics', '~> 3.7.0'
end

s.subspec "Vike" do |ss|
ss.dependency 'Vike'
end

end