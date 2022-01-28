defmodule LivebookHelpers.MixProject do
  use Mix.Project

  @version "0.0.3"
  @source_url "https://github.com/Adzz/livebook_helpers"
  def project do
    [
      app: :livebook_helpers,
      version: @version,
      elixir: "~> 1.13",
      package: package(),
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      source_url: @source_url,
      deps: deps(),
      docs: [
        extras: ["README.md"],
        main: "readme",
      ]
    ]
  end

  defp package() do
    [licenses: ["Apache 2.0"], links: %{"GitHub" => @source_url}]
  end

  defp description() do
    "Helper functions related to Livebook."
  end

  defp elixirc_paths(:test) do
    ["lib", "test/test_modules"]
  end

  defp elixirc_paths(:dev) do
    ["lib", "test/test_modules"]
  end

  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false}
    ]
  end
end
