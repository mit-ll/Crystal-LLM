require "application_system_test_case"

class InteractionsTest < ApplicationSystemTestCase
  setup do
    @interaction = interactions(:one)
  end

  test "visiting the index" do
    visit interactions_url
    assert_selector "h1", text: "Interactions"
  end

  test "should create interaction" do
    visit interactions_url
    click_on "New interaction"

    fill_in "Bandit guard closest approach", with: @interaction.bandit_guard_closest_approach
    fill_in "Closest approach speed", with: @interaction.closest_approach_speed
    fill_in "Closest approach time", with: @interaction.closest_approach_time
    fill_in "Created at", with: @interaction.created_at
    fill_in "Cumulative sun blocking reward", with: @interaction.cumulative_sun_blocking_reward
    fill_in "Elapsed time", with: @interaction.elapsed_time
    fill_in "Evader fuel usage", with: @interaction.evader_fuel_usage
    fill_in "Expected deltav at final time", with: @interaction.expected_deltav_at_final_time
    fill_in "Guard fuel usage", with: @interaction.guard_fuel_usage
    fill_in "Kspdg version", with: @interaction.kspdg_version
    fill_in "Lady guard closest approach", with: @interaction.lady_guard_closest_approach
    fill_in "Maximum sun blocking reward", with: @interaction.maximum_sun_blocking_reward
    fill_in "Minimum position velocity product", with: @interaction.minimum_position_velocity_product
    fill_in "Minimum sun blocking reward", with: @interaction.minimum_sun_blocking_reward
    fill_in "Pursuer fuel usage", with: @interaction.pursuer_fuel_usage
    fill_in "Quasi checksum", with: @interaction.quasi_checksum
    fill_in "Scenario", with: @interaction.scenario_id
    fill_in "Team", with: @interaction.team_id
    fill_in "Weighted score", with: @interaction.weighted_score
    click_on "Create Interaction"

    assert_text "Interaction was successfully created"
    click_on "Back"
  end

  test "should update Interaction" do
    visit interaction_url(@interaction)
    click_on "Edit this interaction", match: :first

    fill_in "Bandit guard closest approach", with: @interaction.bandit_guard_closest_approach
    fill_in "Closest approach speed", with: @interaction.closest_approach_speed
    fill_in "Closest approach time", with: @interaction.closest_approach_time
    fill_in "Created at", with: @interaction.created_at
    fill_in "Cumulative sun blocking reward", with: @interaction.cumulative_sun_blocking_reward
    fill_in "Elapsed time", with: @interaction.elapsed_time
    fill_in "Evader fuel usage", with: @interaction.evader_fuel_usage
    fill_in "Expected deltav at final time", with: @interaction.expected_deltav_at_final_time
    fill_in "Guard fuel usage", with: @interaction.guard_fuel_usage
    fill_in "Kspdg version", with: @interaction.kspdg_version
    fill_in "Lady guard closest approach", with: @interaction.lady_guard_closest_approach
    fill_in "Maximum sun blocking reward", with: @interaction.maximum_sun_blocking_reward
    fill_in "Minimum position velocity product", with: @interaction.minimum_position_velocity_product
    fill_in "Minimum sun blocking reward", with: @interaction.minimum_sun_blocking_reward
    fill_in "Pursuer fuel usage", with: @interaction.pursuer_fuel_usage
    fill_in "Quasi checksum", with: @interaction.quasi_checksum
    fill_in "Scenario", with: @interaction.scenario_id
    fill_in "Team", with: @interaction.team_id
    fill_in "Weighted score", with: @interaction.weighted_score
    click_on "Update Interaction"

    assert_text "Interaction was successfully updated"
    click_on "Back"
  end

  test "should destroy Interaction" do
    visit interaction_url(@interaction)
    click_on "Destroy this interaction", match: :first

    assert_text "Interaction was successfully destroyed"
  end
end
