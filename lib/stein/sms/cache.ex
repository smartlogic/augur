defmodule Stein.SMS.Cache do
  @moduledoc """
  A development cache for text messages that were sent
  """

  use GenServer

  require Logger

  defstruct message_ets_key: :stein_sms_message_cache,
            name: __MODULE__,
            thread_ets_key: :stein_sms_threads_cache

  alias Stein.SMS.Thread

  def cache(config, text_message) do
    GenServer.call(config.name, {:cache, text_message})
  end

  def text_messages(config) do
    config.message_ets_key
    |> keys()
    |> Enum.map(fn key ->
      {:ok, text_message} = get(config.message_ets_key, key)
      text_message
    end)
    |> Enum.sort_by(fn text_message -> text_message.sent_at end)
    |> Enum.reverse()
  end

  def threads(config) do
    config.thread_ets_key
    |> keys()
    |> Enum.map(fn involved ->
      {:ok, thread_id} = get(config.thread_ets_key, involved)
      %Thread{id: thread_id, involved: involved}
    end)
  end

  def thread(config, thread_id) do
    messages =
      Enum.filter(text_messages(config), fn text_message ->
        text_message.thread_id == thread_id
      end)

    Thread.messages_to_thread(thread_id, messages)
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
    :ets.new(state.thread_ets_key, [:set, :protected, :named_table])
    :ets.new(state.message_ets_key, [:set, :protected, :named_table])

    {:noreply, state}
  end

  @impl true
  def handle_call({:cache, text_message}, _from, state) do
    {:ok, thread_id} = cache_thread(state, text_message)
    text_message = %{text_message | thread_id: thread_id}

    Logger.info("Caching sent text - #{inspect(text_message)}")

    :ets.insert(state.message_ets_key, {text_message.id, text_message})

    {:reply, :ok, state}
  end

  defp cache_thread(state, text_message) do
    involved = MapSet.new([text_message.from, text_message.to])

    case :ets.lookup(state.thread_ets_key, involved) do
      [{_involved, thread_id}] ->
        {:ok, thread_id}

      [] ->
        thread_id = Thread.generate_id()
        :ets.insert(state.thread_ets_key, {involved, thread_id})

        {:ok, thread_id}
    end
  end
end
