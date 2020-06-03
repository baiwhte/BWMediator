Pod::Spec.new do |s|
  s.name     = 'BWMediator'
  s.version  = '0.1.0'
  s.license  = 'MIT'
  s.summary  = '.'
  s.homepage = 'https://github.com/baiwhte/BWMediator'
  s.authors  = { 'baiwhte' => 'baiwhte@163.com' }
  s.source   = { :git => 'https://github.com/baiwhte/BWMediator.git', :tag => s.version }

  s.ios.deployment_target = '10.0'

  spec.public_header_files = 'BWMediator/{BWMediator,BWScheduler,BWMediatorNil}.h'
  s.source_files = 'BWMediator/*.{h,m,swift}'

  s.requires_arc = true
  spec.swift_version = '5.0'
end
