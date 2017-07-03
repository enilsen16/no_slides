defmodule NoSlides.Mixfile do
  use Mix.Project

  def project do
    [
      app: :no_slides,
      version: "0.1.0",
      elixir: "~> 1.6-dev",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:riak_core, :logger],
      mod: {NoSlides.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:riak_core, path: "/Users/erik/Projects/riak_core"},
      {:riak_ensemble, github: "lasp-lang/riak_ensemble", branch: "develop", override: true},
      {:eleveldb, "~>2.2.20", override: true},
      {:lager, "~>3.2", override: true},
      {:acceptor_pool,"~>1.0.0-rc.0", override: true},
      {:cuttlefish, github: "lasp-lang/cuttlefish", branch: "develop", override: true},
      {:poolboy, github: "basho/poolboy", branch: "develop", override: true},
      {:clique, "~>3.0", override: true},
      {:parse_trans, "~>3.0", override: true}
    ]
  end
end
