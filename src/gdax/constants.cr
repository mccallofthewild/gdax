module GDAX
  
  # The environment variable used to define the `GDAX` environment.
  PRODUCTION_ENV_VAR_NAME = "GDAX_ENV"

  # `true` if environment variable, `GDAX_ENV` is `production`. `false` otherwise.
  GDAX_ENV_PRODUCTION = ENV[PRODUCTION_ENV_VAR_NAME]? && ENV[PRODUCTION_ENV_VAR_NAME].downcase == "production".downcase

end
