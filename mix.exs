defmodule Zdb.Mixfile do
  use Mix.Project
  @version "0.0.1"
  def project do
    [app: :zdb,
     version: @version,
     elixir: "~> 1.0",
     name: "Zdb",
     description: " elixir library for dynamodb ",
     package: package,
     source_url: "https://github.com/jschoch/zdb",
     homepage_url: "http://stink.net/zdb",
     docs: [source_ref: "v#{@version}",
            source_url: "https://github.com/jschoch/zdb"] ,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger,:erlcloud]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:erlcloud, github: "gleber/erlcloud"},
     {:ex_doc, "~> 0.6.2", only: :dev},
     {:earmark, ">= 0.0.0",only: :dev},
     {:timex, "~> 0.13.4"},
     {:ndecode,github: "jschoch/ndecode"},
     {:poison, "~> 1.3.1"}
    ]
  end
    defp package do
    [contributors: ["Jesse Schoch"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/jschoch/zdb"}]
  end
  #defp docs do
    #{ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
    #IO.puts "ref: #{inspect ref}"
    #[source_ref: ref,
     ##main: "overview",
     #readme: true]
  #end
end
