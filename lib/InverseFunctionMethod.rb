class InverseFunctionMethod
  def self.calculate(sigma)
    random = rand(0.0..1.0)
    sigma * Math.sqrt(-2 * Math.log(random))
  end
end