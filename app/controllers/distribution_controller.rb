require_relative '../../lib/ProbabilityDensityFunction'
require_relative '../../lib/GeneratorCore'
require_relative '../../lib/NeumannMethod'
require_relative '../../lib/MetropolisMethod'
require_relative '../../lib/InverseFunctionMethod'
require_relative '../../lib/MethodCalculationUtils'

class DistributionController < ApplicationController
  def index
    generation_count = params['generation-count']
    max_x = params['right-boundary']
    min_x = 0
    sigma = params['sigma']
    step = 0.1

    if generation_count && max_x && sigma
      generation_count = generation_count.to_i
      max_x = max_x.to_f
      sigma = sigma.to_f
    else
      return
    end

    if generation_count < 1 || max_x <= 0 || sigma <= 0
      return
    end

    generator = GeneratorCore.new(max_x, step, generation_count)
    total_generations_count = generator.get_total_generations_count

    pdf_calculation_lambda = -> (x) { ProbabilityDensityFunction.solve(sigma, x) }
    pdf_values = ProbabilityDensityFunction.absolute(pdf_calculation_lambda, min_x, max_x, step)

    pdf_mode_value = ProbabilityDensityFunction.mode(sigma)
    pdf_mean_value = ProbabilityDensityFunction.mean(sigma)
    pdf_variance_value = ProbabilityDensityFunction.variance(sigma)
    pdf_deviation_value = ProbabilityDensityFunction.deviation(sigma, total_generations_count)
    pdf_maximum_value = ProbabilityDensityFunction.maximum_value(pdf_values)

    neumann_values = NeumannMethod.get_values(generation_count, pdf_calculation_lambda, pdf_maximum_value, min_x, max_x)
    neumann_method = ProbabilityDensityFunction.answer_for_diagram(min_x, max_x, step, neumann_values)

    metropolis_values = MetropolisMethod.get_values(generation_count, pdf_calculation_lambda, min_x, max_x)
    metropolis_method = ProbabilityDensityFunction.answer_for_diagram(min_x, max_x, step, metropolis_values)

    inverse_values = InverseFunctionMethod.get_values(generation_count, min_x, sigma)
    inverse_method = ProbabilityDensityFunction.answer_for_diagram(min_x, max_x, step, inverse_values)

    neumann_method_lambda = -> () { NeumannMethod.calculate(pdf_calculation_lambda, pdf_maximum_value, 0, max_x) }
    previous_x_result = pdf_mode_value
    metropolis_method_lambda = -> () {
      calculation_result = MetropolisMethod.calculate(pdf_calculation_lambda, min_x, max_x, previous_x_result)
      previous_x_result = calculation_result
      calculation_result
    }

    inverse_lambda = -> () { InverseFunctionMethod.calculate(sigma) }

    neumann_method_data = generator.generate(neumann_method_lambda)
    metropolis_method_data = generator.generate(metropolis_method_lambda)
    inverse_data = generator.generate(inverse_lambda)

    methods_calculation = MethodCalculationUtils.new

    neumann_method_expected = methods_calculation.get_mean(
      total_generations_count,
      neumann_method_data['sum'],
      )
    metropolis_method_expected = methods_calculation.get_mean(
      total_generations_count,
      metropolis_method_data['sum'],
      )
    inverse_expected = methods_calculation.get_mean(
      total_generations_count,
      inverse_data['sum'],
      )

    neumann_method_variance = methods_calculation.get_variance(
      total_generations_count,
      neumann_method_data['sum'],
      neumann_method_data['sum_squares'],
      )
    metropolis_method_variance = methods_calculation.get_variance(
      total_generations_count,
      metropolis_method_data['sum'],
      metropolis_method_data['sum_squares'],
      )
    inverse_method_variance = methods_calculation.get_variance(
      total_generations_count,
      inverse_data['sum'],
      inverse_data['sum_squares'],
      )

    neumann_method_deviation = methods_calculation.get_deviation(
      total_generations_count,
      neumann_method_data['sum'],
      neumann_method_data['sum_squares'],
      )
    metropolis_method_deviation = methods_calculation.get_deviation(
      total_generations_count,
      metropolis_method_data['sum'],
      metropolis_method_data['sum_squares'],
      )
    inverse_deviation = methods_calculation.get_deviation(
      total_generations_count,
      inverse_data['sum'],
      inverse_data['sum_squares'],
      )

    @calculation_result = {
      'options' => {
        'generationCount' => generation_count,
        'max_x' => max_x,
        'step' => step,
        'sigma' => sigma,
      },
      'pdfMaxValue' => pdf_maximum_value,
      'pdfMeanValue' => pdf_mean_value,
      'pdfVarianceValue' => pdf_variance_value,
      'pdfDeviationValue' => pdf_deviation_value,
      'absoluteMethod' => pdf_values,
      'neumannMethod' => neumann_method,
      'metropolisMethod' => metropolis_method,
      'inverseMethod' => inverse_method,
      'neumannMethodExpectedValue' => neumann_method_expected,
      'metropolisMethodExpectedValue' => metropolis_method_expected,
      'inverseMethodExpectedValue' => inverse_expected,
      'neumannMethodVariance' => neumann_method_variance,
      'metropolisMethodVariance' => metropolis_method_variance,
      'inverseMethodVariance' => inverse_method_variance,
      'neumannMethodDeviation' => neumann_method_deviation,
      'metropolisMethodDeviation' => metropolis_method_deviation,
      'inverseMethodDeviation' => inverse_deviation,
    }
  end
end
