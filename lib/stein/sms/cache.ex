defmodule Stein.SMS.Cache do
  @moduledoc """
  A development cache for text messages that were sent
  """

  use GenServer

  defstruct ets_key: :stein_sms_cache, name: __MODULE__

  require Logger

  def cache(config, text_message) do
    GenServer.call(config.name, {:cache, text_message})
  end

  def text_messages(config) do
    Enum.map(keys(config.ets_key), fn key ->
      {:ok, text_message} = get(config.ets_key, key)
      text_message
    end)
  end

  @doc false
  def get(ets_key, key) do
    case :ets.lookup(ets_key, key) do
      [{^key, value}] ->
        {:ok, value}

      _ ->
        {:error, :not_found}
    end
  end

  @doc false
  def keys(ets_key) do
    key = :ets.first(ets_key)
    keys(key, [], ets_key)
  end

  def keys(:"$end_of_table", accumulator, _ets_key), do: accumulator

  def keys(current_key, accumulator, ets_key) do
    next_key = :ets.next(ets_key, current_key)
    keys(next_key, [current_key | accumulator], ets_key)
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: config.name)
  end

  @impl true
  def init(config) do
    {:ok, config, {:continue, :start_cache}}
  end

  @impl true
  def handle_continue(:start_cache, state) do
    :ets.new(state.ets_key, [:set, :protected, :named_table])

    {:noreply, state}
  end

  @impl true
  def handle_call({:cache, text_message}, _from, state) do
    Logger.info("Caching sent text - #{inspect(text_message)}")

    :ets.insert(state.ets_key, {text_message.id, text_message})

    {:reply, :ok, state}
  end
end
