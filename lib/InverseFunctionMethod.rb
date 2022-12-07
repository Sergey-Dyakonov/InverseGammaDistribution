class InverseFunctionMethod
  def self.calculate(sigma)
    sigma * Math.sqrt(-2 * Math.log(rand))
  end

  def self.get_values(count, left_boundary, sigma)
    res = []
    i = 0
    while i < count do
      x = calculate(sigma)
      if x > left_boundary
        res << x
        i += 1
      end
    end
    res.sort
  end
end