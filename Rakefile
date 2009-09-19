require 'erb'
def calculate_minor_version
  matching_versions = File.readlines('build/debian/changelog').grep(/opensprints \(#{ENV['VERSION']}-.*\) unstable; urgency=low/)
  minors = matching_versions.map do |version| 
    (/opensprints \(#{ENV['VERSION']}-(.*)\) unstable; urgency=low/).match(version)[1]
  end

  minors.map(&:to_i).max
end 
OPENSPRINTS_VERSION = "#{ENV['VERSION']}-#{calculate_minor_version}"
CHANGELOG_TEMPLATE = ERB.new(<<END)
opensprints (<%= OPENSPRINTS_VERSION %>) unstable; urgency=low

  <%= message %>

 -- Evan Farrar <evan@opensprints.org>  <%= Time.now.strftime("%a, %d %b %Y %R:%S %z") %>
END



def message
  "Changed some stuff"
end

task :update_changelog => :check_version_provided do
  old_changelog = File.read("build/debian/changelog")
  OPENSPRINTS_VERSION = "#{ENV['VERSION']}-#{(calculate_minor_version||0)+1}"
  changelog = CHANGELOG_TEMPLATE.result + old_changelog
  File.open("build/debian/changelog", "w") {|f| f << changelog }
  print "Changelogged..."
end

task :build => :check_version_provided do
  here = Dir.pwd
  `rm -rf /tmp/build` if File.exists?('/tmp/build')
  `cp -L -R build /tmp/build`
  Dir.chdir('/tmp/build')
  `debuild --no-tgz-check`
  Dir.chdir(here)
  print "Packaged..."
end

task :upload => :check_version_provided do
  `scp /tmp/opensprints_#{OPENSPRINTS_VERSION}_i386.deb opensprints.org:/home/efarrar/packages.opensprints.org/debian/dists/jaunty/opensprints/binary-i386/`
  print 'Uploaded...'
end

task :release do
  `ssh opensprints.org -C 'cd /home/efarrar/packages.opensprints.org/debian; dpkg-scanpackages dists/jaunty/opensprints/binary-i386/ /dev/null | gzip -9c > dists/jaunty/opensprints/binary-i386/Packages.gz'`
  puts 'Released!'
end

task :check_version_provided do
  abort("Sorry, need to provide a major version number") unless ENV['VERSION']
end

task :package => [:update_changelog, :build, :upload, :release] do
  puts "Finished version #{OPENSPRINTS_VERSION}"
end

task :build_deb => [:update_changelog, :build] do
  puts "Finished version #{OPENSPRINTS_VERSION}"
end
