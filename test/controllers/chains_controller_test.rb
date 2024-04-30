require "test_helper"

class ChainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chain = chains(:one)
  end

  test "should get index" do
    get chains_url
    assert_response :success
  end

  test "should get new" do
    get new_chain_url
    assert_response :success
  end

  test "should create chain" do
    assert_difference("Chain.count") do
      post chains_url, params: { chain: { chain_order: @chain.chain_order, user_id: @chain.user_id } }
    end

    assert_redirected_to chain_url(Chain.last)
  end

  test "should show chain" do
    get chain_url(@chain)
    assert_response :success
  end

  test "should get edit" do
    get edit_chain_url(@chain)
    assert_response :success
  end

  test "should update chain" do
    patch chain_url(@chain), params: { chain: { chain_order: @chain.chain_order, user_id: @chain.user_id } }
    assert_redirected_to chain_url(@chain)
  end

  test "should destroy chain" do
    assert_difference("Chain.count", -1) do
      delete chain_url(@chain)
    end

    assert_redirected_to chains_url
  end
end
