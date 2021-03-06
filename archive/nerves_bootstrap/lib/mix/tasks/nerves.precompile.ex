defmodule Mix.Tasks.Nerves.Precompile do
  use Mix.Task
  alias Nerves.Env

  def run(_args) do
    Mix.shell.info "Nerves Precompile Start"
    System.put_env("NERVES_PRECOMPILE", "1")
    Mix.Tasks.Deps.Compile.run ["nerves_system"]
    Env.initialize

    case Mix.Task.run "deps.check", ["--no-compile"] do
      :noop -> :ok
      _ -> Mix.Task.reenable "deps.check"
    end

    if Env.stale? do
      Mix.Tasks.Deps.Compile.run [Env.system.app, "--include-children"]
    else
      Mix.shell.info "Nerves Env current"
    end

    System.put_env("NERVES_PRECOMPILE", "0")
    Mix.Tasks.Nerves.Loadpaths.run "nerves.loadpaths"
    Mix.Task.reenable "deps.precompile"
    Mix.shell.info "Nerves Precompile End"
  end
end
