require_relative '../../lib/MethodCalculationUtils'
require_relative '../../lib/Modules.rb'
include DistributionModule
include NeymanModule
include MetropolisModule
include InverseModule
include VisualizationModule
include GeneratorModule

class DistributionController < ApplicationController
  def index
    generation_count = params['generation-count']
    max_x = params['right-boundary']
    min_x = 0
    alpha = params['alpha']
    beta = params['beta']
    step = 0.1

    if generation_count && max_x && alpha
      generation_count = generation_count.to_i
      max_x = max_x.to_f
      alpha = alpha.to_f
      beta = beta.to_f
    else
      return
    end

    if generation_count < 1 || max_x <= 0 || beta <= 0 || alpha <= 0
      return
    end

    total_count = generations_count(max_x, step, generation_count)

    pdf_lambda = -> (x) { pdf_function(x, alpha, beta) }
    answer_lambda = ->(values) { answer(min_x, max_x, step, values) }

    pdf_values = get_absolute(pdf_lambda, min_x, max_x, step)

    pdf_mode = mode(alpha, beta)
    pdf_mean = mean(alpha, beta)
    pdf_variance = variance(alpha, beta)
    pdf_deviation = deviation(alpha, beta, generation_count)
    pdf_maximum_value = maximum_value(pdf_values)

    neumann_values = get_neumann(generation_count, pdf_lambda, pdf_maximum_value, min_x, max_x)
    neumann_method = answer_lambda.call(neumann_values)

    metropolis_values = get_metropolis(generation_count, pdf_lambda, min_x, max_x)
    metropolis_method = answer_lambda.call(metropolis_values)

    inverse_values = get_inverse(generation_count, min_x, alpha, beta)
    inverse_method = answer_lambda.call(inverse_values)

    neumann_method_lambda = -> () { neyman(pdf_lambda, pdf_maximum_value, 0, max_x) }
    previous_x_result = pdf_mode
    metropolis_method_lambda = -> () {
      calculation_result = metropolis(pdf_lambda, min_x, max_x, previous_x_result)
      previous_x_result = calculation_result
      calculation_result
    }

    inverse_lambda = -> () { inverse(alpha) }
    generate_lambda = -> (func){generate(func, step, max_x, generation_count)}

    neumann_method_data = generate_lambda.call(neumann_method_lambda)
    metropolis_method_data = generate_lambda.call(metropolis_method_lambda)
    inverse_data = generate_lambda.call(inverse_lambda)

    neumann_method_expected = MethodCalculationUtils.get_mean(total_count, neumann_method_data['sum'])
    metropolis_method_expected = MethodCalculationUtils.get_mean(total_count, metropolis_method_data['sum'])
    inverse_expected = MethodCalculationUtils.get_mean(total_count, inverse_data['sum'])

    neumann_method_variance = MethodCalculationUtils.get_variance(total_count, neumann_method_data['sum'], neumann_method_data['sum_squares'])
    metropolis_method_variance = MethodCalculationUtils.get_variance(total_count, metropolis_method_data['sum'], metropolis_method_data['sum_squares'])
    inverse_method_variance = MethodCalculationUtils.get_variance(total_count, inverse_data['sum'], inverse_data['sum_squares'])

    neumann_method_deviation = MethodCalculationUtils.get_deviation(total_count, neumann_method_data['sum'], neumann_method_data['sum_squares'])
    metropolis_method_deviation = MethodCalculationUtils.get_deviation(total_count, metropolis_method_data['sum'], metropolis_method_data['sum_squares'])
    inverse_deviation = MethodCalculationUtils.get_deviation(total_count, inverse_data['sum'], inverse_data['sum_squares'])

    @calculation_result = {
      'options' => {
        'generationCount' => generation_count,
        'max_x' => max_x,
        'step' => step,
        'alpha' => alpha,
        'beta' => beta,
      },
      'pdfMaxValue' => pdf_maximum_value,
      'pdfMeanValue' => pdf_mean,
      'pdfVarianceValue' => pdf_variance,
      'pdfDeviationValue' => pdf_deviation,
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

  def generations_count(max, step, n)
    (max / step) * n
  end
end
