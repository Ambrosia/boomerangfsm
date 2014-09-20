defmodule BoomerangFSM.Player do
  @behaviour :gen_fsm

  @derive [Access]
  defstruct name: nil, opponent: nil
  alias __MODULE__

  # Public
  def state(pid) do
    :sys.get_state pid
  end

  def add_opponent(pid, opponent_pid) do
    :gen_fsm.send_event(pid, {:add_opponent, opponent_pid})
  end

  # State machine
  def awaiting_opponent({:add_opponent, opponent}, state) do
    state = %{state | opponent: opponent}
    {:next_state, :ready, state}
  end

  def awaiting_opponent(_, state) do
    {:next_state, :awaiting_opponent, state}
  end

  def ready(_, state) do
    {:next_state, :ready, state}
  end

  # OTP stuff
  def start_link(args \\ []) do
    :gen_fsm.start_link(__MODULE__, args, [])
  end

  def init(args) do
    state = %Player{
      name: Keyword.get(args, :name),
      opponent: Keyword.get(args, :opponent)
    }

    case state.opponent do
      nil -> {:ok, :awaiting_opponent, state}
      _   -> {:ok, :ready, state}
    end
  end
end
