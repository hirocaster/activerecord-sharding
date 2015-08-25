require 'rake'

describe 'Tasks :active_record_sharding' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require './../lib/tasks/activerecord-sharding'
    Rake::Task.define_task(:environment)
  end

  before(:each) do
    @rake[task].reenable
  end

  context 'for sharding clusters' do
    describe 'info' do
      let(:task) { 'active_record:sharding:info' }

      it 'show cluster infomation to STDOUT' do
        expect { @rake[task].invoke }.to output(/test_user_001/).to_stdout
      end
    end

    describe 'setup' do
      let(:task) { 'active_record:sharding:setup' }

      before do
        allow(ActiveRecord::Tasks::DatabaseTasks).to receive(:create).and_return(nil)
        allow(ActiveRecord::Tasks::DatabaseTasks).to receive(:load_schema).and_return(nil)
      end

      it 'Setup all cluster databases' do
        expect(@rake[task].invoke[0]).to be_a Proc
      end
    end

    describe 'drop_all' do
      let(:task) { 'active_record:sharding:drop_all' }

      before do
        allow(ActiveRecord::Tasks::DatabaseTasks).to receive(:drop).and_return(nil)
      end

      it 'Drop all cluster databases' do
        expect(@rake[task].invoke[0]).to be_a Proc
      end
    end
  end
  context 'for sequencers' do
    describe 'setup' do
      let(:task) { 'active_record:sharding:sequencer:setup' }

      before do
        allow(ActiveRecord::Sharding::DatabaseTasks).to receive(:execute).and_return(nil)
      end

      it 'Setup all sequencers databases' do
        expect(@rake[task].invoke[0]).to be_a Proc
      end
    end

    describe 'drop_all' do
      let(:task) { 'active_record:sharding:sequencer:drop_all' }

      before do
        allow(ActiveRecord::Tasks::DatabaseTasks).to receive(:drop).and_return(nil)
      end

      it 'Drop all sequencers databases' do
        expect(@rake[task].invoke[0]).to be_a Proc
      end
    end
  end
end
