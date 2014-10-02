Boomerangfsm
============

Example
------
    iex> alias BoomerangFSM.Player
    nil
    iex> {:ok, player1} = Player.start_link name: "Bob"
    {:ok, #PID<0.95.0>}
    iex> {:ok, player2} = Player.start_link name: "Julia", opponent: player1
    {:ok, #PID<0.97.0>}
    iex> Player.add_opponent player1, player2
    :ok
    iex> Player.state player1
    {:ready,
     %BoomerangFSM.Player{boomerang_flight_time: 1000, name: "Bob",
      opponent: #PID<0.97.0>, wait_to_catch_time: 6000}}
    iex> Player.give_boomerang player1
    :ok
    iex> Player.state player1
    {:ready_to_throw,
     %BoomerangFSM.Player{boomerang_flight_time: 1000, name: "Bob",
      opponent: #PID<0.97.0>, wait_to_catch_time: 6000}}
    iex> Player.throw_boomerang player1
    :ok
    iex> Player.state player1
    {:ready,
     %BoomerangFSM.Player{boomerang_flight_time: 1000, name: "Bob",
      opponent: #PID<0.132.0>, wait_to_catch_time: 6000}}
    iex> Player.state player2
    {:ready_to_throw,
     %BoomerangFSM.Player{boomerang_flight_time: 1000, name: "Julia",
      opponent: #PID<0.130.0>, wait_to_catch_time: 6000}}
