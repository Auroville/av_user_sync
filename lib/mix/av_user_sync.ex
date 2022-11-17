defmodule Mix.AVUserSync do

    @doc """
  Converts a string to camel case.

  Takes an optional `:lower` flag to return lowerCamelCase.

  ## Examples

      iex> Phoenix.Naming.camelize("my_app")
      "MyApp"

      iex> Phoenix.Naming.camelize("my_app", :lower)
      "myApp"

  In general, `camelize` can be thought of as the reverse of
  `underscore`, however, in some cases formatting may be lost:

      Phoenix.Naming.underscore "SAPExample"  #=> "sap_example"
      Phoenix.Naming.camelize   "sap_example" #=> "SapExample"

  """
  def camelize(value), do: Macro.camelize(value)

  def camelize("", :lower), do: ""
  def camelize(<<?_, t :: binary>>, :lower) do
    camelize(t, :lower)
  end
  def camelize(<<h, _t :: binary>> = value, :lower) do
    <<_first, rest :: binary>> = camelize(value)
    <<to_lower_char(h)>> <> rest
  end

  defp to_lower_char(char) when char in ?A..?Z, do: char + 32
  defp to_lower_char(char), do: char

  @doc """
  Returns the OTP context app.
  """
  def context_app do
    this_app = otp_app()

    case fetch_context_app(this_app) do
      {:ok, app} -> app
      :error -> this_app
    end
  end

  @doc """
  Returns the context app path prefix to be used in generated context files.
  """
  def context_app_path(ctx_app, rel_path) when is_atom(ctx_app) do
    this_app = otp_app()

    if ctx_app == this_app do
      rel_path
    else
      app_path =
        case Application.get_env(this_app, :generators)[:context_app] do
          {^ctx_app, path} -> Path.relative_to_cwd(path)
          _ -> mix_app_path(ctx_app, this_app)
        end
      Path.join(app_path, rel_path)
    end
  end

  @doc """
  Returns the OTP app from the Mix project configuration.
  """
  def otp_app do
    Mix.Project.config() |> Keyword.fetch!(:app)
  end

  @doc """
  Returns the context module base name based on the configuration value.

      config :my_app
        namespace: My.App

  """
  def context_base(ctx_app) do
    app_base(ctx_app)
  end

  @doc """
  Returns the context lib path to be used in generated context files.
  """
  def context_lib_path(ctx_app, rel_path) when is_atom(ctx_app) do
    context_app_path(ctx_app, Path.join(["lib", to_string(ctx_app), rel_path]))
  end

  @doc """
  The paths to look for template files for generators.

  Defaults to checking the current app's `priv` directory,
  and falls back to AVUserSync's `priv` directory.
  """
  def generator_paths do
    ["./", :av_user_sync]
  end

  @doc """
  Prompts to continue if any files exist.
  """
  def prompt_for_conflicts(generator_files) do
    file_paths =
      Enum.flat_map(generator_files, fn
        {:new_eex, _, _path} -> []
        {_kind, _, path} -> [path]
      end)

    case Enum.filter(file_paths, &File.exists?(&1)) do
      [] -> :ok
      conflicts ->
        Mix.shell().info"""
        The following files conflict with new files to be generated:

        #{Enum.map_join(conflicts, "\n", &"  * #{&1}")}

        See the --web option to namespace similarly named resources
        """
        unless Mix.shell().yes?("Proceed with interactive overwrite?") do
          System.halt()
        end
    end
  end

  @doc """
  Copies files from source dir to target dir
  according to the given map.

  Files are evaluated against EEx according to
  the given binding.
  """
  def copy_from(apps, source_dir, binding) do

    # for {format, source_file_path, target} <- mapping do


    #   case format do
    #     :text -> Mix.Generator.create_file(target, File.read!(source))
    #     :eex  -> Mix.Generator.create_file(target, EEx.eval_file(source, binding))
    #     :new_eex ->
    #       if File.exists?(target) do
    #         :ok
    #       else
    #         Mix.Generator.create_file(target, EEx.eval_file(source, binding))
    #       end
    #   end
    # end
  end

  defp to_app_source(path, source_dir) when is_binary(path),  do: Path.join(path, source_dir)
  defp to_app_source(app, source_dir) when is_atom(app), do: Application.app_dir(app, source_dir)


  defp app_base(app) do
    case Application.get_env(app, :namespace, app) do
      ^app -> app |> to_string() |> camelize()
      mod  -> mod |> inspect()
    end
  end

  defp mix_app_path(app, this_otp_app) do
    case Mix.Project.deps_paths() do
      %{^app => path} ->
        Path.relative_to_cwd(path)
      deps ->
        Mix.raise """
        no directory for context_app #{inspect app} found in #{this_otp_app}'s deps.

        Ensure you have listed #{inspect app} as an in_umbrella dependency in mix.exs:

            def deps do
              [
                {:#{app}, in_umbrella: true},
                ...
              ]
            end

        Existing deps:

            #{inspect Map.keys(deps)}

        """
    end
  end

  defp fetch_context_app(this_otp_app) do
    case Application.get_env(this_otp_app, :generators)[:context_app] do
      nil ->
        :error
      false ->
        Mix.raise """
        no context_app configured for current application #{this_otp_app}.

        Add the context_app generators config in config.exs, or pass the
        --context-app option explicitly to the generators. For example:

        via config:

            config :#{this_otp_app}, :generators,
              context_app: :some_app

        via cli option:

            mix phx.gen.[task] --context-app some_app

        Note: cli option only works when `context_app` is not set to `false`
        in the config.
        """
      {app, _path} ->
        {:ok, app}
      app ->
        {:ok, app}
    end
  end
end
