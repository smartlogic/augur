defmodule Augur.MixProject do
  use Mix.Project

  def project do
    [
      app: :augur,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: "Text messaging library that is service based.",
      package: package(),
      docs: docs(),
      deps: deps()
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
      {:credo, "~> 1.1", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:finch, "~> 0.8"},
      {:jason, "~> 1.0"},
      {:plug, "~> 1.12"}
    ]
  end

  defp package() do
    %{
      maintainers: ["Eric Oestrich"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/smartlogic/augur"
      }
    }
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md"
      ]
    ]
  end
end
