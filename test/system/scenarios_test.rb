require "application_system_test_case"

class ScenariosTest < ApplicationSystemTestCase
  setup do
    @scenario = scenarios(:one)
  end

  test "visiting the index" do
    visit scenarios_url
    assert_selector "h1", text: "Scenarios"
  end

  test "should create scenario" do
    visit scenarios_url
    click_on "New scenario"

    fill_in "Description", with: @scenario.description
    check "Has guard" if @scenario.has_guard
    check "Is sun blocking" if @scenario.is_sun_blocking
    fill_in "Scenario name", with: @scenario.scenario_name
    fill_in "Scenario title", with: @scenario.scenario_title
    click_on "Create Scenario"

    assert_text "Scenario was successfully created"
    click_on "Back"
  end

  test "should update Scenario" do
    visit scenario_url(@scenario)
    click_on "Edit this scenario", match: :first

    fill_in "Description", with: @scenario.description
    check "Has guard" if @scenario.has_guard
    check "Is sun blocking" if @scenario.is_sun_blocking
    fill_in "Scenario name", with: @scenario.scenario_name
    fill_in "Scenario title", with: @scenario.scenario_title
    click_on "Update Scenario"

    assert_text "Scenario was successfully updated"
    click_on "Back"
  end

  test "should destroy Scenario" do
    visit scenario_url(@scenario)
    click_on "Destroy this scenario", match: :first

    assert_text "Scenario was successfully destroyed"
  end
end
