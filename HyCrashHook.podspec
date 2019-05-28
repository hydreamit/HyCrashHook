Pod::Spec.new do |s|
s.name         = 'HyCrashHook'
s.version      = '1.0.1'
s.summary      = 'Hook Crash Keep Procedures Away from Running'
s.homepage     = 'https://github.com/hydreamit/HyCrashHook'
s.license      = 'MIT'
s.authors      = {'Hy' => 'hydreamit@163.com'}
s.platform     = :ios, '9.0'
s.source       = {:git => 'https://github.com/hydreamit/HyCrashHook.git', :tag => s.version}
s.source_files = 'HyCrashHook/**/*.{h,m}'
s.framework    = 'Foundation'
s.requires_arc = false
s.requires_arc = ['HyCrashHook/*', 'HyCrashHook/Category/*']
end
