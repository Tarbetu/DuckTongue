defmodule DuckTongue.MixProject do
  use Mix.Project

  def project do
    [
      app: :duck_tongue,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: DuckTongue.CLI]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:amnesia, "~> 0.2.8"}
    ]
  end
end

mnesia_dir = System.get_env("DUCK_MNESIA")

if mnesia_dir do
  :application.set_env(:mnesia, :dir, ~c"#{mnesia_dir}")
end