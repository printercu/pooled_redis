RSpec.describe PooledRedis do
  context '.extend_rails' do
    subject { -> { described_class.extend_rails } }
    before do
      expect(defined?(Rails)).to be_falsy
      subject.call # ensure it doesnt fail
      module Rails; end # stub
    end

    it 'adds methods to rails' do
      subject.call
      expect(Rails).to respond_to(:redis_pool, :redis)
    end
  end

  describe '#redis_pool' do
    subject { instance.redis_pool }
    let(:instance) { double(redis_config: redis_config).tap { |x| x.extend described_class } }
    let(:redis_config) { {} }

    its(:class) { should be ConnectionPool }
    its('checkout.class') { should be Redis }

    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby'
      context 'on mri when hiredis is available' do
        its('checkout.client.driver.name') { should eq 'Redis::Connection::Hiredis' }
      end
    end

    context 'when config contains :namespace' do
      before do
        # Redis::Namespace must not use Redis.current
        expect(Redis).to_not receive(:current)
        expect(Redis).to receive(:new).and_call_original
      end

      let(:redis_config) { {namespace: 'test_ns'} }
      its('checkout.class') { should be Redis::Namespace }
      its('checkout.namespace') { should eq 'test_ns' }
    end

    context 'when config contains :block' do
      let(:redis_config) { {block: -> { block_result } } }
      let(:block_result) { Object.new }
      its('checkout.class') { should eq block_result.class }
      its('checkout') { should be block_result }
    end

    context 'calling multiple times' do
      subject { -> { instance.redis_pool } }
      let(:original_value) { subject.call }
      its(:call) { should be original_value }
    end
  end
end
