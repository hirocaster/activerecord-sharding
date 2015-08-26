describe ActiveRecord::Sharding::AbstractRepository do
  describe "#generate_class_name" do
    let!(:repository) do
      Class.new(ActiveRecord::Sharding::AbstractRepository) do
        def initialize
          generate_class_name "test"
        end
      end
    end

    it "raise NotImplementedError" do
      expect { repository.new }.to raise_error NotImplementedError
    end
  end
end
