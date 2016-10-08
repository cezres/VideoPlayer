Pod::Spec.new do |s|

s.name         = 'VideoPlayer'
s.version      = '0.1.0'
s.summary      = '视频播放器，基于ijkplayer简单封装一下。'
s.homepage     = 'https://github.com/cezres/VideoPlayer'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.author       = { 'cezres' => 'cezres@163.com' }

s.platform     = :ios, '8.0'
s.source       = { :git => 'https://github.com/cezres/VideoPlayer.git', :tag => s.version }
s.source_files = 'VideoPlayer/**/*.{h,m}'
s.requires_arc = true
s.public_header_files = 'VideoPlayer/**/*.h'


s.resources           = 'VideoPlayer/Icon.bundle'

s.vendored_frameworks = 'VideoPlayer/IJKMediaPlayer.framework'

end

