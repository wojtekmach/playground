defmodule Mix.Tasks.Playground.Uninstall do
  use Mix.Task

  @shortdoc "Remove playground from your Elixir installation"

  @moduledoc """
  Remove playground from your Elixir installation"
  """

  @impl true
  def run([]) do
    dir = [:code.lib_dir(:elixir), "..", "playground"] |> Path.join() |> Path.expand()
    remove_directory(dir)
    remove_directory(Playground.tmp_dir())
  end

  defp remove_directory(dir) do
    log(:yellow, "removing", dir)
    File.rm_rf!(dir)
  end

  defp log(color, command, message) do
    Mix.shell().info([color, "* #{command} ", :reset, message])
  end
end
