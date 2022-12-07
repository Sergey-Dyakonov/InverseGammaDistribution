class ProbabilityDensityFunction
  def self.solve(sigma, x)
    (x.to_f / (sigma ** 2)) * Math.exp((-(x ** 2)).to_f / (2 * sigma ** 2))
  end

  def self.absolute(pdf, min, max, step)
    result = []
    (min..max).step(step).each { |i|
      result << pdf.call(i)
    }
    result
  end

  def self.mode(sigma)
    sigma
  end

  def self.maximum_value(pdf_values)
    y_max = -1000
    pdf_values.each { |i|
      if y_max < i
        y_max = i
      end
    }
    y_max
  end

  def self.mean(sigma)
    sigma * Math.sqrt(Math::PI / 2)
  end

  def self.variance(sigma)
    ((4 - Math::PI) / 2) * sigma ** 2
  end

  def self.deviation(sigma, generation_count)
    variance = ProbabilityDensityFunction.variance(sigma)
    Math.sqrt(variance / generation_count)
  end

  def self.answer_for_diagram(min, max, step, listX)
    res= []
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
