#
# Be sure to run `pod lib lint PXMultiForwarder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PXMultiForwarder"
  s.version          = "0.1.0"
  s.summary          = "An object wrapper that forwards messages to multiple objects."
  s.description      = <<-DESC
                       PXMultiForwarder lets you wrap multiple objects and send messages to all of them as if you were working with one.
                       DESC
  s.homepage         = "https://github.com/pixio/PXMultiForwarder"
  s.license          = 'MIT'
  s.author           = { "Spencer Phippen" => "spencer.phippen@gmail.com" }
  s.source           = { :git => "https://github.com/pixio/PXMultiForwarder.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/PXMultiForwarder.{h,m}'
  s.public_header_files = 'Pod/Classes/PXMultiForwarder.h'
  s.resource_bundles = {
    'PXMultiForwarder' => ['Pod/Assets/*.png']
  }
end
