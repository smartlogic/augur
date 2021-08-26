defmodule Stein.SMS.Config do
  @moduledoc """
  Configuration cache for Stein.SMS

  Start with the configuration that should be generally used in your
  application. It will be stored in `:persistent_term` for quick access.
  """

  use GenServer

  def get() do
    :persistent_term.get(__MODULE__)
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @impl true
  def init(config) do
    {:ok, config, {:continue, :cache_config}}
  end

  @impl true
  def handle_continue(:cache_config, state) do
    :persistent_term.put(__MODULE__, state)

    {:noreply, state}
  end
end
