defmodule Mix.Tasks.Playground.Install do
  use Mix.Task

  @shortdoc "Copy playground into your Elixir installation"

  @moduledoc """
  Copy playground into your Elixir installation"
  """

  @vsn Mix.Project.config()[:version]

  @impl true
  def run([]) do
    dir = "playground-#{@vsn}"
    src_ebin = Path.join([Mix.path_for(:archives), dir, dir, "ebin"])

    dst_ebin =
      [:code.lib_dir(:elixir), "..", "playground", "ebin"]
      |> Path.join()
      |> Path.expand()

    for path <- ~w(Elixir.Playground.beam playground.app) do
      Mix.Generator.copy_file(Path.join(src_ebin, path), Path.join(dst_ebin, path))
    end
  end
end
