Pod::Spec.new do |s|

  s.name          = "iDroidLayout"
  s.version       = "0.0.1"
  s.summary       = "iDroid-Layout is a port of Androids layout system and its drawable and resources framework to iOS."

  s.description   = <<-DESC
The main reason for this project is to learn more about the Android layout system and how it works.
Another reason is the lack of a advanced layout system in iOS ( **Update:** this is not true anymore for iOS >= 6 because of the introduction of auto layout). Currently it is a pain to build maintainable UI code in iOS. You have the choice between doing your layout in interface builder which is great for static, but not powerful enough for dynamic content, or doing all in code which is difficult to maintain.
In Android layouts can be defined in XML. Views automatically adjust their size while taking into account their content requirements and their parents' size restrictions.
                   DESC

  s.homepage      = "https://github.com/tomquist/iDroidLayout"
  s.screenshots   = "https://raw.githubusercontent.com/tomquist/iDroidLayout/master/Documentation/layout_example.png"
  s.license       = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.author        = { "Tom Quist" => "tom@quist.de" }

  s.platform      = :ios, "6.0"
  s.source        = { :git => "https://github.com/tomquist/iDroidLayout.git", :tag => "0.0.1" }
  non_arc_files   = 'iDroidLayout/Utils/NSObject+IDL_KVOObserver.m'
  s.source_files  = 'iDroidLayout', 'iDroidLayout/**/*.{h,m}'
  s.exclude_files = non_arc_files
  s.framework     = 'QuartzCore', 'UIKit', 'CoreGraphics'
  s.requires_arc  = true

  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = non_arc_files
  end

  s.dependency 'TBXML', '~> 1.5'
end
