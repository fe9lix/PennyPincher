Pod::Spec.new do |s|
  s.name             = "PennyPincher"
  s.version          = "0.1.0"
  s.summary          = "Gesture recognizer based on the PennyPincher algorithm."
  s.description      = <<-DESC
                        Gesture recognizer based on the PennyPincher algorithm.
                       DESC
  s.homepage         = "https://github.com/fe9lix/PennyPincher"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = "fe9lix"
  s.source           = { :git => "https://github.com/fe9lix/PennyPincher.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PennyPincher' => ['Pod/Assets/*.png']
  }
end
