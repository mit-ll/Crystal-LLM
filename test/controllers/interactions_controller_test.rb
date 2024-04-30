require "test_helper"

class InteractionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @interaction = interactions(:one)
  end

  test "should get index" do
    get interactions_url
    assert_response :success
  end

  test "should get new" do
    get new_interaction_url
    assert_response :success
  end

  test "should create interaction" do
    assert_difference("Interaction.count") do
      post interactions_url, params: { interaction: { bandit_guard_closest_approach: @interaction.bandit_guard_closest_approach, closest_approach_speed: @interaction.closest_approach_speed, closest_approach_time: @interaction.closest_approach_time, created_at: @interaction.created_at, cumulative_sun_blocking_reward: @interaction.cumulative_sun_blocking_reward, elapsed_time: @interaction.elapsed_time, evader_fuel_usage: @interaction.evader_fuel_usage, expected_deltav_at_final_time: @interaction.expected_deltav_at_final_time, guard_fuel_usage: @interaction.guard_fuel_usage, kspdg_version: @interaction.kspdg_version, lady_guard_closest_approach: @interaction.lady_guard_closest_approach, maximum_sun_blocking_reward: @interaction.maximum_sun_blocking_reward, minimum_position_velocity_product: @interaction.minimum_position_velocity_product, minimum_sun_blocking_reward: @interaction.minimum_sun_blocking_reward, pursuer_fuel_usage: @interaction.pursuer_fuel_usage, quasi_checksum: @interaction.quasi_checksum, scenario_id: @interaction.scenario_id, team_id: @interaction.team_id, weighted_score: @interaction.weighted_score } }
    end

    assert_redirected_to interaction_url(Interaction.last)
  end

  test "should show interaction" do
    get interaction_url(@interaction)
    assert_response :success
  end

  test "should get edit" do
    get edit_interaction_url(@interaction)
    assert_response :success
  end

  test "should update interaction" do
    patch interaction_url(@interaction), params: { interaction: { bandit_guard_closest_approach: @interaction.bandit_guard_closest_approach, closest_approach_speed: @interaction.closest_approach_speed, closest_approach_time: @interaction.closest_approach_time, created_at: @interaction.created_at, cumulative_sun_blocking_reward: @interaction.cumulative_sun_blocking_reward, elapsed_time: @interaction.elapsed_time, evader_fuel_usage: @interaction.evader_fuel_usage, expected_deltav_at_final_time: @interaction.expected_deltav_at_final_time, guard_fuel_usage: @interaction.guard_fuel_usage, kspdg_version: @interaction.kspdg_version, lady_guard_closest_approach: @interaction.lady_guard_closest_approach, maximum_sun_blocking_reward: @interaction.maximum_sun_blocking_reward, minimum_position_velocity_product: @interaction.minimum_position_velocity_product, minimum_sun_blocking_reward: @interaction.minimum_sun_blocking_reward, pursuer_fuel_usage: @interaction.pursuer_fuel_usage, quasi_checksum: @interaction.quasi_checksum, scenario_id: @interaction.scenario_id, team_id: @interaction.team_id, weighted_score: @interaction.weighted_score } }
    assert_redirected_to interaction_url(@interaction)
  end

  test "should destroy interaction" do
    assert_difference("Interaction.count", -1) do
      delete interaction_url(@interaction)
    end

    assert_redirected_to interactions_url
  end
end
