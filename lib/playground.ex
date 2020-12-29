defmodule Playground do
  @doc false
  def tmp_dir() do
    Path.join(System.tmp_dir(), "elixir_playground")
  end

  @doc false
  def enabled?() do
    List.keyfind(Application.started_applications(), :mix, 0) == nil
  end

  def start(deps) when is_list(deps) do
    unless enabled?() do
      raise "cannot use within a Mix project"
    end

    namespace = "default"
    md5 = :erlang.md5(inspect(Enum.sort(deps)))
    dirname = namespace <> Base.encode16(md5)
    project_path = Path.join([tmp_dir(), dirname])

    if File.dir?(project_path) do
      :ok
    else
      File.mkdir_p!(project_path)
      app = :"playground_#{namespace}"
      module = :"Elixir.Playground#{Macro.camelize(namespace)}"

      # TODO: instead of writing mix.exs, do everything in memory. For some reason,
      # while then deps.get works, compile does not do anything.
      File.cd!(project_path, fn ->
        File.write!("mix.exs", mix_project(app, module, deps))

        mix(~w(deps.get))
        mix(~w(compile))
      end)
    end

    for path <- Path.wildcard("#{project_path}/_build/prod/**/ebin") do
      app = path |> Path.split() |> Enum.at(-2) |> String.to_atom()

      true = Code.append_path(path)
      {:ok, _} = Application.ensure_all_started(app)
    end

    :ok
  end

  defp mix(args) do
    {_, 0} =
      System.cmd("mix", args,
        env: %{"MIX_ENV" => "prod"},
        into: IO.stream(:stdio, :line)
      )
  end

  defp mix_project(app, module, deps) do
    deps =
      for dep <- deps do
        case dep do
          dep when is_atom(dep) ->
            {dep, ">= 0.0.0"}

          dep ->
            dep
        end
      end

    module = Module.concat(module, MixProject)

    """
    defmodule #{inspect(module)} do
      use Mix.Project

      def project do
        [
          app: #{inspect(app)},
          version: "0.1.0",
          deps: #{inspect(deps)}
        ]
      end
    end
    """
  end
end
