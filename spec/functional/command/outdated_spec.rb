require File.expand_path('../../../spec_helper', __FILE__)

module Pod
  describe Command::Outdated do
    extend SpecHelper::TemporaryRepos

    it "tells the user that no Podfile was found in the current working dir" do
      exception = lambda { run_command('outdated', '--no-repo-update') }.should.raise Informative
      exception.message.should.include "No `Podfile' found in the current working directory."
    end

    it "tells the user that no Lockfile was found in the current working dir" do
      file = temporary_directory + 'Podfile'
      File.open(file, 'w') {|f| f.write('platform :ios') }
      Dir.chdir(temporary_directory) do
        exception = lambda { run_command('outdated', '--no-repo-update') }.should.raise Informative
        exception.message.should.include "No `Podfile.lock' found in the current working directory"
      end
    end

    it 'tells the user only about podspecs that have no parent' do
      spec = Specification.new(nil, 'BlocksKit')
      subspec = Specification.new(spec, 'UIKit')
      set = mock
      set.stubs(:versions).returns(['2.0'])
      set.stubs(:specification).returns(spec)
      subset = mock
      subset.stubs(:specification).returns(subspec)
      subset.stubs(:versions).returns(['2.0'])
      version = mock
      version.stubs(:version).returns('1.0')
      Command::Outdated.any_instance.stubs(:spec_sets).returns([set, subset])
      Command::Outdated.any_instance.stubs(:lockfile).returns(version)
      run_command('outdated', '--no-repo-update')
      UI.output.should.not.include('UIKit')
    end

    it 'tells the user about deprecated pods' do
      spec = Specification.new(nil, 'AFNetworking')
      spec.deprecated_in_favor_of = 'BlocksKit'
      Command::Outdated.any_instance.stubs(:deprecated_pods).returns([spec])
      Command::Outdated.any_instance.stubs(:updates).returns([])
      run_command('outdated', '--no-repo-update')
      UI.output.should.include('in favor of BlocksKit')
    end
  end
end

