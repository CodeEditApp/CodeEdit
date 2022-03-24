Pod::Spec.new do |s|
	s.name = 'Preferences'
	s.version = '2.5.0'
	s.summary = 'Add a preferences window to your macOS app in minutes'
	s.license = 'MIT'
	s.homepage = 'https://github.com/sindresorhus/Preferences'
	s.social_media_url = 'https://twitter.com/sindresorhus'
	s.authors = { 'Sindre Sorhus' => 'sindresorhus@gmail.com' }
	s.source = { :git => 'https://github.com/sindresorhus/Preferences.git', :tag => "v#{s.version}" }
	s.source_files = 'Sources/**/*.swift'
	s.swift_version = '5.4'
	s.platform = :macos, '10.10'
end
