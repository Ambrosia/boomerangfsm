defmodule BoomerangFSM.Player do
  @wait_to_catch_time 6000
  @boomerang_flight_time 1000

  @behaviour :gen_fsm

  @derive [Access]
  defstruct [
    name: nil,
    opponent: nil,
    wait_to_catch_time: @wait_to_catch_time,
    boomerang_flight_time: @boomerang_flight_time
  ]

  alias __MODULE__

  # Public
  def state(pid) do
    :sys.get_state pid
  end

  def add_opponent(pid, opponent_pid) do
    :gen_fsm.send_event(pid, {:add_opponent, opponent_pid})
  end

  def give_boomerang(pid), do: :gen_fsm.send_event(pid, :give_boomerang)

  def throw_boomerang(pid) do
    :gen_fsm.send_event(pid, :throw_boomerang)

    {_, state} = Player.state pid
    :timer.sleep @boomerang_flight_time
    case :random.uniform do
      # other player catches boomerang
      num when num < 0.33 -> :gen_fsm.send_event(state.opponent, :caught_boomerang)
      # boomerang returns to this player
      num when num < 0.67 -> :gen_fsm.send_event(pid, :caught_boomerang)
      # boomerang was dropped, lost or shot by a ufo
      _ -> :ok
    end
  end

  def throw_boomerang(pid, test: :boomerang_lost), do: :gen_fsm.send_event(pid, :throw_boomerang)
  def throw_boomerang(pid, test: :boomerang_return) do
    :gen_fsm.send_event(pid, :throw_boomerang)
    {_, state} = Player.state pid
    :timer.sleep state.boomerang_flight_time
    :gen_fsm.send_event(pid, :caught_boomerang)
  end
  def throw_boomerang(pid, test: :boomerang_opponent) do
    :gen_fsm.send_event(pid, :throw_boomerang)
    {_, state} = Player.state pid
    :timer.sleep state.boomerang_flight_time
    :gen_fsm.send_event(state.opponent, :caught_boomerang)
  end

  # State machine
  def awaiting_opponent({:add_opponent, opponent}, state) do
    {:next_state, :ready, %{state | opponent: opponent}}
  end

  def awaiting_opponent(_, state) do
    {:next_state, :awaiting_opponent, state}
  end

  def ready(:give_boomerang, state), do: {:next_state, :ready_to_throw, state}
  def ready(:catch!, state) do
    {:next_state, :ready_to_catch, state, state.wait_to_catch_time}
  end

  def ready_to_throw(:throw_boomerang, state) do
    :gen_fsm.send_event(state.opponent, :catch!)
    {:next_state, :ready_to_catch, state, state.wait_to_catch_time}
  end

  def ready_to_catch(:caught_boomerang, state), do: {:next_state, :ready_to_throw, state}
  def ready_to_catch(:timeout, state), do: {:next_state, :ready, state}

  # OTP stuff
  def start_link(args \\ []) do
    :gen_fsm.start_link(__MODULE__, args, [])
  end

  def init(args) do
    :random.seed :erlang.now

    state = %Player{
      name: Keyword.get(args, :name),
      opponent: Keyword.get(args, :opponent),
      wait_to_catch_time: Keyword.get(args, :wait_to_catch_time, @wait_to_catch_time),
      boomerang_flight_time: Keyword.get(args, :boomerang_flight_time, @boomerang_flight_time)
    }

    case state.opponent do
      nil -> {:ok, :awaiting_opponent, state}
      _   -> {:ok, :ready, state}
    end
  end
end
