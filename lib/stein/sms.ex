defmodule Stein.SMS do
  @moduledoc """
  An extension to Stein that handles SMS
  """

  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(config = %Stein.SMS.Development{}) do
    children = [
      {Stein.SMS.Config, config},
      {Stein.SMS.Cache, config.cache}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def init(config = %Stein.SMS.Twilio{}) do
    children = [
      {Stein.SMS.Config, config},
      {Stein.SMS.Cache, config.cache},
      {Finch, name: config.finch_name}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
