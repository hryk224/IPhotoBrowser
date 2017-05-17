Pod::Spec.new do |s|
  s.name         = "IPhotoBrowser"
  s.version      = "0.1.3"
  s.summary      = "A simple iOS Instagram photo browser written in Swift."
  s.homepage     = "https://github.com/longhoang2984/LHIPhotoBrowser"
  s.screenshots  = "https://github.com/hryk224/IPhotoBrowser/wiki/images/sample1.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "hyyk224" => "hryk224@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/longhoang2984/LHIPhotoBrowser.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/*.{h,swift}"
  s.frameworks = "UIKit", "Photos"
  s.requires_arc = true
end
