defmodule BoomerangFSM.PlayerTest do
  use ExUnit.Case, async: true

  alias BoomerangFSM.Player

  @wait_to_catch_time 1000
  @boomerang_flight_time 200

  test "start_link arguments work correctly" do
    assert {:ok, player1} = Player.start_link name: "Player 1"
    assert {:ok, player2} = Player.start_link name: "Player 2", opponent: player1

    assert {:awaiting_opponent, %Player{name: "Player 1"}} = Player.state player1
    assert {:ready, %Player{opponent: ^player1}} = Player.state player2
  end

  test "players can be assigned to each other" do
    {player1, player2} = create_two_players |> assign_players_to_each_other

    assert {:ready, %Player{opponent: ^player2}} = Player.state player1
    assert {:ready, %Player{opponent: ^player1}} = Player.state player2
  end

  test "player cannot be given a boomerang if they don't have an opponent" do
    {player1, player2} = create_two_players
    Player.give_boomerang player1

    refute {:ready, _} = Player.state player1
  end

  test "a player becomes ready to throw when given a boomerang" do
    {player1, player2} = create_two_players |> assign_players_to_each_other

    Player.give_boomerang player1
    assert {:ready_to_throw, _} = Player.state player1
  end

  test "players become ready to catch after one throws a boomerang" do
    {player1, player2} = create_two_players |> assign_players_to_each_other
    Player.give_boomerang player1
    Player.throw_boomerang player1, test: :boomerang_lost

    assert {:ready_to_catch, _} = Player.state player1
    assert {:ready_to_catch, _} = Player.state player2
  end

  test "a player will give up on waiting to catch after a while" do
    {player1, player2} = create_two_players |> assign_players_to_each_other
    Player.give_boomerang player1
    Player.throw_boomerang player1, test: :boomerang_lost

    :timer.sleep 50
    assert {:ready_to_catch, _} = Player.state player2
    :timer.sleep @wait_to_catch_time + 200
    assert {:ready, _} = Player.state player2
  end

  test "a player is ready to throw again after they throw the boomerang and it returns" do
    {player1, player2} = create_two_players |> assign_players_to_each_other
    Player.give_boomerang player1
    Player.throw_boomerang player1, test: :boomerang_return

    :timer.sleep @boomerang_flight_time + 200
    assert {:ready_to_throw, _} = Player.state player1
    :timer.sleep @wait_to_catch_time
    assert {:ready, _} = Player.state player2
  end

  test "a player's opponent is ready to throw after they catch a thrown boomerang" do
    {player1, player2} = create_two_players |> assign_players_to_each_other
    Player.give_boomerang player1
    Player.throw_boomerang player1, test: :boomerang_opponent

    :timer.sleep @boomerang_flight_time + 200
    assert {:ready_to_throw, _} = Player.state player2
    :timer.sleep @wait_to_catch_time
    assert {:ready, _} = Player.state player1
  end

  defp create_two_players do
    {:ok, player1} = Player.start_link [
      name: "Player 1",
      wait_to_catch_time: @wait_to_catch_time,
      boomerang_flight_time: @boomerang_flight_time
    ]
    {:ok, player2} = Player.start_link [
      name: "Player 2",
      wait_to_catch_time: @wait_to_catch_time,
      boomerang_flight_time: @boomerang_flight_time
    ]
    {player1, player2}
  end

  defp assign_players_to_each_other({player1, player2}) do
    Player.add_opponent player1, player2
    Player.add_opponent player2, player1
    {player1, player2}
  end
end
