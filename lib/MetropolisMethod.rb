class MetropolisMethod
  def self.calculate(function_callback, left_boundary, right_boundary, previous_x)
    delta = (right_boundary - left_boundary) / 3
    x1 = previous_x + delta * (-1 + 2 * rand)

    previous_x_calculation = function_callback.call(previous_x)
    alpha = function_callback.call(x1) / (previous_x_calculation === 0 ? 1 : previous_x_calculation)

    if alpha >= 1.0 || alpha > rand
      return x1
    end

    previous_x
  end

  def self.get_values(count, func, left_boundary, right_boundary)
    x = rand * right_boundary
    res = []
    (0..count).each do |i|
      x = calculate(func, left_boundary, right_boundary, x)
      if i > 100 && x > 0 && x <= right_boundary
        res << x
      end
    end
    res.sort
  end
end