# These configurations actually won't get loaded into parent app's configurations
import Config

config :av_user_sync,
  namespace: AVUserSync

import_config "#{Mix.env()}.exs"
