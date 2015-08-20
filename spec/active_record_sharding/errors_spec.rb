describe ActiveRecordSharding::Error do
  it 'is defined class' do
    expect(described_class).to be_a Class
  end

  it 'kind of StandardError' do
    expect(described_class.new).to be_kind_of StandardError
  end
end
