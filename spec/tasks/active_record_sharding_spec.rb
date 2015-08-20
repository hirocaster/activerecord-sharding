require 'rake'

describe 'Tasks :active_record_sharding' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require './../lib/tasks/active_record_sharding'
    Rake::Task.define_task(:environment)
  end

  before(:each) do
    @rake[task].reenable
  end

  describe 'info' do
    let(:task) { 'active_record_sharding:info' }

    it 'show cluster infomation to STDOUT' do
      expect { @rake[task].invoke }.to output(/test_user_001/).to_stdout
    end
  end
end
