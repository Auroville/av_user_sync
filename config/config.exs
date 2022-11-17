import Config

config :av_user_sync,
  namespace: AVUserSync

import_config "#{Mix.env()}.exs"
