context 'remote is specified in legacy manner' do
  it 'raises an error' do
    sphere = Biosphere::Resources::Sphere.new('test1')
    config = OpenStruct.new cookbooks_repo: '/dev/null/remote', cookbooks_path: 'subdirectory'
    instance = described_class.new sphere: sphere, config: config

    expect(Biosphere::Log).to_not receive(:debug)
    expect(Biosphere::Log).to_not receive(:info)

    errors = []
    expect(Biosphere::Log).to receive(:error).twice do |*args, &block|
      expect(args).to be_empty
      errors << block.call
      if errors.size == 1
        expect(errors.last).to eq 'Your sphere.yml cannot specify both `cookbooks_repo:` and `cookbooks_path:`'.red
      end
      expect(errors.last).to eq 'Please rename `cookbooks_path:` to `cookbooks_repo_subdir:`'.red if errors.size == 2
    end

    expect { instance.call }.to raise_error Biosphere::Errors::SphereConfigDeprecation
  end
end
