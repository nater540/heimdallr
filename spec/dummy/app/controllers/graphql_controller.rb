class GraphqlController < ApplicationController
  before_action :heimdallr_authorize!

  def execute
    query_string = params[:query]
    variables    = ensure_hash(params[:variables])

    result = DummySchema.execute(
      query_string,
      variables: variables,
      context: {
        token: heimdallr_token
      }
    )
    render json: result
  end

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end
end
