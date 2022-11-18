# AVUserSync

`av_accounts` is a project that enables OAuth for Aurovilians to be able login into Auroville products and services

`profiles` is a microservice of Auronet - an intranet used by Aurovilians. Users can maintain their public profile information.

AVUserSync is a library that can be installed to sync Auroville user data in your database from two sources, namely, `av_accounts` and `profiles`.

## Installation
Due to security reasons of the users of both sources, It's best to always sync in production or staging and not development. 

This project is available as a [package in hex](). In order for this library to only sync in production, you need to install the hex package by adding `av_user_sync` to your list of dependencies in `mix.exs`:
```elixir
def deps do
  {:av_user_sync, "~> 0.1.0", runtime: Mix.env() == :prod}
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


## Mix tasks

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

Alternatively, you can also run the command without any arguments. Running withouth any arguments just assumes schema module name to be `Accounts.User` and the table name to be `users`. So, running the command like below is also valid:
```console
mix av_user_sync.gen.schema
```

#### `mix av_user_sync.gen.seed`
As you already know, this library only helps in syncing the user data and that too is only recommended in production. What if you want to interact with the user data? How will you test with an actual user from your local environment?

Running the command will create 10 test users. The user data will actually match with the two sources of data and it means that you can test out interactions that require users from your local enivronment.


This command doesn't require any arguments for it to work. But you need to have the configuration which configures both repo and schma of your app. Once you have the configuration ready, you can run it like below:
```console
mix av_user_sync.gen.seed
```