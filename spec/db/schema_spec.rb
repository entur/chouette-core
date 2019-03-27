RSpec.describe ActiveRecord::Schema do
  it "uses type `bigint` for primary and foreign keys" do
    expect('db/schema.rb').to use_bigint_keys
  end
end


RSpec::Matchers.define :use_bigint_keys do
  match do |filename|
    @original = ""
    @expected = ""

    File.open(filename, 'r') do |f|
      f.each_line do |line|
        expected_line = line

        # Primary key
        if line =~ /create_table\sid:/ &&
          !(line =~ /id: \s+ (?: :bigserial | false)/x)
          expected_line = line.sub(/(create_table\s"\w+",\s)/, '\1id: :bigserial, ')
        end

        # Foreign key
        if line =~ /t\.integer\s+"\w+_id"/ &&
          !(line =~ /limit: 8/)
          expected_line = line.sub(/(t.integer\s+"\w+")/, '\1, limit: 8')
        end

        @original += line
        @expected += expected_line
      end
    end

    @original == @expected
  end

  failure_message do |filename|
    <<-EOS
expected #{filename.inspect} to use bigint keys
Diff: #{diff}
    EOS
  end

  def diff
    RSpec::Support::Differ.new(
      color: RSpec::Matchers.configuration.color?
    ).diff_as_string(@original, @expected)
  end
end
