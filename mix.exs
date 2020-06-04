defmodule SocketDrano.MixProject do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :socket_drano,
      version: "#{@version}",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: preferred_cli_env(),
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp preferred_cli_env do
    [
      docs: :docs,
      "coveralls.json": :test
    ]
  end

  defp docs do
    [
      main: "SocketDrano",
      canonical: "http://hexdocs.pm/socket_drano",
      source_url: "https://github.com/bryannaegele/socket_drano",
      source_ref: "v#{@version}"
    ]
  end

  defp description do
    """
    Provides a mechanism to gracefully drain Phoenix socket connections.
    """
  end

  defp package do
    [
      maintainers: ["Bryan Naegele"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/bryannaegele/socket_drano"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, ">= 1.4.7", optional: true},
      {:ranch, ">= 1.7.0", optional: true},
      {:telemetry, "~> 0.4", optional: true},
      {:ex_doc, "~> 0.21", only: [:dev, :docs]}
    ]
  end
end
