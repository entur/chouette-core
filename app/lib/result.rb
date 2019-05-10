# A value wrapper adding status information to any value
# Status can be :ok or :error, we are thusly implementing
# what is expressed in Elixir/Erlang as result tuples and
# in Haskell as `Data.Either`
class Result

  attr_reader :status, :value
  
  class << self
    def ok value
      make :ok, value
    end
    def error value
      make :error, value
    end

    def new *args
      raise NoMethodError, "No default constructor for #{self}"
    end

    private
    def make status, value
      allocate.tap do | o |
        o.instance_exec do
          @status = status
          @value  = value
        end
      end
    end
  end

  def ok?; status == :ok end

  def == other
    other.kind_of?(self.class) && other.status == status && other.value == value
  end
end
