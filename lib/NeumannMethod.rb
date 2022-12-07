class NeumannMethod
  def self.calculate(function_callback, maximum_value, left_boundary, right_boundary)
    while true
      x = left_boundary + rand * (right_boundary - left_boundary)
      y = rand * maximum_value

      if function_callback.call(x) > y
        return x
      end
    end
  end

  def self.get_values(count, func, max_val, left, right)
    result = []
    (0..count).each do
      result << calculate(func, max_val, left, right)
    end
    result.sort
  end
end