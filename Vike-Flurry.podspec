Pod::Spec.new do |s|

s.name         = "Vike-Flurry"
s.version      = "0.1.4"
s.summary      = "Flurry integration for Vike's' analytics library"
s.homepage     = "https://github.com/nemezis16/Vike"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Roman Osadchuk" => "roman.osadchuk@thinkmobiles.com" }
s.platform     = :ios, "8.3"
s.source       = { :git => "https://github.com/nemezis16/Vike.git", :tag => "0.1.4" }
s.source_files  = "VikeFlurry/*.{h,m}"
s.requires_arc = true

s.subspec "Flurry" do |ss|
ss.dependency 'Flurry' '~> 7.6.3'
end

end