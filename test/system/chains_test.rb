require "application_system_test_case"

class ChainsTest < ApplicationSystemTestCase
  setup do
    @chain = chains(:one)
  end

  test "visiting the index" do
    visit chains_url
    assert_selector "h1", text: "Chains"
  end

  test "should create chain" do
    visit chains_url
    click_on "New chain"

    fill_in "Chain order", with: @chain.chain_order
    fill_in "User", with: @chain.user_id
    click_on "Create Chain"

    assert_text "Chain was successfully created"
    click_on "Back"
  end

  test "should update Chain" do
    visit chain_url(@chain)
    click_on "Edit this chain", match: :first

    fill_in "Chain order", with: @chain.chain_order
    fill_in "User", with: @chain.user_id
    click_on "Update Chain"

    assert_text "Chain was successfully updated"
    click_on "Back"
  end

  test "should destroy Chain" do
    visit chain_url(@chain)
    click_on "Destroy this chain", match: :first

    assert_text "Chain was successfully destroyed"
  end
end
