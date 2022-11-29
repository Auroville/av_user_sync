# AVUserSync

`av_accounts` is a project that enables OAuth for Aurovilians to be able login into Auroville products and services

`profiles` is a microservice of Auronet - an intranet used by Aurovilians. Users can maintain their public profile information.

AVUserSync is a library that can be installed to sync Auroville user data in your database from two sources, namely, `av_accounts` and `profiles`.

## Installation
Due to security reasons of the users of both sources, It's best to always sync in production or staging and not in development environment. 

This project **is not** available as a package in hex. For this library to only sync in production, you need to install from the Github installer by adding `av_user_sync` to your list of dependencies in `mix.exs` like below:
```elixir
def deps do
  {:av_user_sync, github: "auroville/av_user_sync", runtime: Mix.env() == :prod}
end
```

## Configuration
In your `config/runtime.exs`, you need to configure repos of the source databases:
```elixir
config :av_user_sync, AVUserSync.AVAccounts.Repo,
  url: AV_ACCOUNTS_DB_URL

config :av_user_sync, AVUserSync.AVProfile.Repo,
  url: AV_PROFILE_DB_URL
```

You also need to configure the repo and schema to sync user data in your database. So, in your `config/config.exs`:
```elixir
config :av_user_sync,
  otp_app: :your_app,
  repo: YourEctoRepo,
  schema: YourEctoSchma
```

To be able to be sync, the data structure of user in your database should follow like below:
- `id` - Primay ID (binary)
- `username` - String
- `email` - String
- `asyncto_id` - String
- `display_name` - String
- `community` - String
- `phone` - String
- `about` - Text
- `profile_picture` - String

Also, you need to add the `AVUserSync.Periodically` to the supervision tree in order to sync every 10 mins.
```elixir
def start(_type, _args) do
  children = [
    ...
    AVUserSync.Periodically
  ]

  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```

Voila!!! You can sit back and watch your users getting synced from the two sources

## Mix tasks
The goal of these mix tasks is to enable easy setup of your application to start syncing. Please go through the rest of it as you may find them very helpful.

#### `mix av_user_sync.gen.schema`
The main functions of this command is to
- generate schema file corresponding to the data structure of user
- also generates a migration file corresponding to the data structure schema

This command accepts only two arguments and they are
 1. schema module name
 1. table name
 
Below is just an example of how you can use this command:
```console
mix av_user_sync.gen.schema Shared.User av_users
```

Alternatively, you can also run the command without any arguments. Running without any arguments just assumes schema module name to be `Accounts.User` and the table name to be `users`. So, running the command like below is also valid:
```console
mix av_user_sync.gen.schema
```

#### `mix av_user_sync.gen.seed`
As you already know, this library only helps in syncing the user data and that too is only recommended in production. What if you want to interact with the user data? How will you test with an actual user from your local environment?

Running the command will create 3 test users. The user data will actually match with the two sources of data and it means that you can test out interactions that require users from your local enivronment.

This command doesn't require any arguments for it to work. But you need to have the configuration which configures both repo and schma of your app. Once you have the configuration ready, you can run it like below:
```console
mix av_user_sync.gen.seed
```

## Contributing to AVUserSync
For working with development environment, it's always better to clone this repository and work with it. In Elixir/Phoenix, add the `av_user_sync` in `mix.exs` with the path installer rather than github installer like above:
```elixir
def deps do
  {:av_user_sync, path: "../av_user_sync"}
end
```

The source databases for development are already configured in `config/dev.exs` of the AVUserSync library. From the root directory of the library, you need to run the command:
```
mix ecto.create
```
This will create empty source databases for you to get started with testing. You need to dump the databases with production/staging data into the two local databases:
1. `av_profile_dev`
2. `av_accounts_dev`

Please contact the Talam team at [talamsupport@auroville.org.in](mailto:talamsupport@auroville.org.in)

Projects in elixir do not load configurations from dependencies. So, you also need to configure the two repos in application you are working with:
```elixir
config :av_user_sync, AVUserSync.AVProfile.Repo,
  database: "av_profile_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true

config :av_user_sync, AVUserSync.AVAccounts.Repo,
  database: "av_accounts_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true
```

That is it!!! You are now all set to start working on the library.
