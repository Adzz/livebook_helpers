defmodule LivebookHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :livebook_helpers,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  defp elixirc_paths(:test) do
    ["lib", "test/test_modules"]
  end

  defp elixirc_paths(:dev) do
    ["lib", "test/test_modules"]
  end

  defp elixirc_paths(_), do: ["lib"]
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:data_schema, ">0.0.0"}
    ]
  end
end
