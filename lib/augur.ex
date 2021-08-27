defmodule Augur do
  @moduledoc """
  An extension to Stein that handles SMS
  """

  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(config = %Augur.Development{}) do
    children = [
      {Augur.Config, config},
      {Augur.Cache, config.cache}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def init(config = %Augur.Twilio{}) do
    children = [
      {Augur.Config, config},
      {Augur.Cache, config.cache},
      {Finch, name: config.finch_name}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
