module TomTom
  class Matrix
    class Point
      attr_reader :coordinates, :id

      def initialize(coordinates, id)
        @coordinates = coordinates
        @id = id
      end

      def ==(other)
        other.is_a?(self.class) &&
          @coordinates == other.coordinates &&
          @id == other.id
      end
    end
  end
end
