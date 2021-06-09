defmodule Werewolf.Mixfile do
  use Mix.Project

  def project do
    [
      app: :werewolf,
      version: "0.1.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Werewolf.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:exconstructor, "~> 1.2.3"}
    ]
  end
end
