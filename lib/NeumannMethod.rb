class NeumannMethod
  def self.calculate(function_callback, maximum_value, right_boundary)
    while true
      x = rand(0.0..1.0) * right_boundary
      y = rand(0.0..1.0) * maximum_value

      if function_callback.call(x) > y
        return x
      end
    end
  end

  def self.get_values(count, func, max_val, right)
    result = []
    (0..count).each do
      y = calculate(func, max_val, right)
      result << y
    end
    result.sort
  end
end