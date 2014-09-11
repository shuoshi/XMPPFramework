Pod::Spec.new do |s|
s.name = 'XMPPFramework'
s.version = '3.6.6'

s.osx.deployment_target = '10.7'
s.ios.deployment_target = '6.0'

s.platform = :osx, '10.7'
s.platform = :ios, '6.0'

s.ios.frameworks = 'UIKit', 'Foundation'
s.osx.frameworks = 'Cocoa'

s.license = { :type => 'BSD', :file => 'copying.txt' }
s.summary = 'An XMPP Framework in Objective-C for the Mac / iOS development community.'
s.homepage = 'https://github.com/processOne/XMPPFramework'
s.author = { 'Robbie Hanson' => 'robbiehanson@deusty.com' }
s.source = { :git => 'https://github.com/processOne/XMPPFramework.git', :tag => s.version }
s.resources = [ '**/*.{xcdatamodel,xcdatamodeld}']

s.description = 'XMPPFramework provides a core implementation of RFC-3920 (the xmpp standard), along with
the tools needed to read & write XML. It comes with multiple popular extensions (XEPs),
all built atop a modular architecture, allowing you to plug-in any code needed for the job.
Additionally the framework is massively parallel and thread-safe. Structured using GCD,
this framework performs    well regardless of whether it\'s being run on an old iPhone, or
on a 12-core Mac Pro. (And it won\'t block the main thread... at all).'

s.requires_arc = true

# XMPPFramework.h is used internally in the framework to let modules know
# what other optional modules are available. Since we don't know yet which
# subspecs have been selected, include all of them wrapped in defines which
# will be set by the relevant subspecs.

s.prepare_command = <<-'END'
echo '#import "XMPP.h"' > XMPPFramework.h
grep '#define _XMPP_' -r /Extensions \
| tr '-' '_' \
| perl -pe 's/Extensions\/([A-z0-9_]*)\/([A-z]*.h).*/\n#ifdef HAVE_XMPP_SUBSPEC_\U\1\n\E#import "\2"\n#endif/' \
>> XMPPFramework.h
END

s.preserve_path = 'module/module.modulemap'
#s.module_map = 'module/module.modulemap'

s.subspec 'Core' do |core|
core.source_files = ['XMPPFramework.h', 'Core/**/*.{h,m}', 'Vendor/libidn/*.h', 'Authentication/**/*.{h,m}', 'Categories/**/*.{h,m}', 'Utilities/**/*.{h,m}']
core.vendored_libraries = 'Vendor/libidn/libidn.a'
core.libraries = 'xml2', 'resolv'
core.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(inherited) $(SDKROOT)/usr/include/libxml2 $(PODS_ROOT)/XMPPFramework/module $(SDKROOT)/usr/include/libresolv',
'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/XMPPFramework/Vendor/libidn"', 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES', 'OTHER_LDFLAGS' => '"-lxml2"', 'ENABLE_BITCODE' => 'NO'
}
core.dependency 'CocoaLumberjack','~>1.9'
core.dependency 'CocoaAsyncSocket','~>7.4.1'
core.ios.dependency 'XMPPFramework/KissXML'
end

s.subspec 'Authentication' do |ss|
ss.dependency 'XMPPFramework/Core'
end

s.subspec 'Categories' do |ss|
ss.dependency 'XMPPFramework/Core'
end

s.subspec 'Utilities' do |ss|
ss.dependency 'XMPPFramework/Core'
end

s.subspec 'KissXML' do |ss|
ss.source_files = ['Vendor/KissXML/**/*.{h,m}', 'module/module.modulemap']
ss.libraries = 'xml2','resolv'
ss.xcconfig = {
'HEADER_SEARCH_PATHS' => '$(inherited) $(SDKROOT)/usr/include/libxml2 $(PODS_ROOT)/XMPPFramework/module $(SDKROOT)/usr/include/libresolv'
}
end

s.subspec 'BandwidthMonitor' do |ss|
ss.source_files = 'Extensions/BandwidthMonitor/**/*.{h,m}'
ss.dependency 'XMPPFramework/Core'
ss.prefix_header_contents = "#define HAVE_XMPP_SUBSPEC_#{name.upcase.sub('-', '_')}"
end

s.subspec 'CoreDataStorage' do |ss|
ss.source_files = ['Extensions/CoreDataStorage/**/*.{h,m}', 'Extensions/XEP-0203/NSXMLElement+XEP_0203.h']
ss.dependency 'XMPPFramework/Core'
ss.prefix_header_contents = "#define HAVE_XMPP_SUBSPEC_#{name.upcase.sub('-', '_')}"
ss.framework = 'CoreData'
end

s.subspec 'GoogleSharedStatus' do |ss|
ss.source_files = 'Extensions/GoogleSharedStatus/**/*.{h,m}'
ss.dependency 'XMPPFramework/Core'
ss.prefix_header_contents = "#define HAVE_XMPP_SUBSPEC_#{name.upcase.sub('-', '_')}"
end

s.subspec 'ProcessOne' do |ss|
ss.source_files = 'Extensions/ProcessOne/**/*.{h,m}'
ss.dependency 'XMPPFramework/Core'
ss.prefix_header_contents = "#define HAVE_XMPP_SUBSPEC_#{name.upcase.sub('-', '_')}"
