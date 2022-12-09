module DistributionModule

  def pdf_function(x, alpha, beta)
    ((beta ** alpha.to_f) / Math.gamma(alpha)) * ((1.to_f / x) ** (alpha + 1)) * Math.exp(-beta.to_f / x)
  end

  def mean(a, b)
    if a > 1
      b.to_f / (a - 1)
    end
  end

  def mode(a, b)
    b.to_f / (a + 1)
  end

  def variance(a, b)
    if a > 2
      (b ** 2) / (((a - 1) ** 2) * (a - 2))
    end
  end

  def entropy(a, b)
    a + Math.log(b * Math.gamma(a)) - (1 + a) * ksi(a)
  end

  def ksi(a)
    Math.log(a) - 1.to_f / (2 * a)
  end

  def get_absolute(func, min, max, step)
    result = []
    (min..max).step(step).each { |i|
      result << func.call(i)
    }
    result
  end

  def maximum_value(values)
    y_max = -1000
    values.each { |i|
      if y_max < i
        y_max = i
      end
    }
    y_max
  end

  def deviation(a, b, generation_count)
    if a > 2
      Math.sqrt(variance(a, b) / generation_count)
    end
  end
end

module NeymanModule
  def neyman(func, maximum, left, right)
    while true
      x = left + rand * (right - left)
      y = rand * maximum

      if func.call(x) > y
        return x
      end
    end
  end

  def get_neumann(count, func, max_val, left, right)
    result = []
    (0..count).each do
      result << neyman(func, max_val, left, right)
    end
    result.sort
  end
end

module MetropolisModule
  def metropolis(func, left, right, prev_x)
    delta = (right - left) / 3
    x1 = prev_x + delta * (-1 + 2 * rand)

    previous_x_calculation = func.call(prev_x)
    alpha = func.call(x1) / (previous_x_calculation === 0 ? 1 : previous_x_calculation)

    if alpha >= 1.0 || alpha > rand
      return x1
    end

    prev_x
  end

  def get_metropolis(count, func, left, right)
    x = rand * right
    res = []
    (0..count).each do |i|
      x = metropolis(func, left, right, x)
      if i > 100 && x > 0 && x <= right
        res << x
      end
    end
    res.sort
  end
end

module InverseModule
  include DistributionModule

  def inverse(a)
    a * Math.sqrt(-2 * Math.log(rand))
  end

  def get_inverse(count, left, a, b)
    res = []
    i = 0
    while i < count do
      x = inverse(a)
      if x > left
        res << x
        i += 1
      end
    end
    res.sort
  end
end

module VisualizationModule

  def answer(min, max, step, listX)
    res = []
    a = 0
    j = 0
    (min...max).step(step).each do |i|
      y = 0
      if j != listX.count
        j = a
        (j...listX.count).each { |l|
          if listX[l] < i + step
            y += 1
          else
            a = l
            break
          end
        }
        if y != 0
          y /= (step * listX.count)
          res << y
        end
      end
    end
    res
  end
end

module GeneratorModule
  def generate(method, step, limit, count)
    frequencies = []
    sum = 0
    sum_squares = 0

    ((0 + step)..limit).step(step).each do |currentStep|
      current_success_method_results = 0
      previous_step = currentStep - step

      (0..count).each do
        method_result = method.call
        sum += method_result
        sum_squares += method_result ** 2

        if method_result > previous_step and method_result <= currentStep
          current_success_method_results += 1
        end
      end

      frequencies.push(current_success_method_results.to_f / count)
    end

    {
      'frequencies' => frequencies,
      'sum' => sum,
      'sum_squares' => sum_squares,
    }
  end
end
