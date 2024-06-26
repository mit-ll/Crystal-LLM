require "test_helper"

class TemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @template = templates(:one)
  end

  test "should get index" do
    get templates_url
    assert_response :success
  end

  test "should get new" do
    get new_template_url
    assert_response :success
  end

  test "should create template" do
    assert_difference("Template.count") do
      post templates_url, params: { template: { question_id: @template.question_id, template_text: @template.template_text, user_id: @template.user_id } }
    end

    assert_redirected_to template_url(Template.last)
  end

  test "should show template" do
    get template_url(@template)
    assert_response :success
  end

  test "should get edit" do
    get edit_template_url(@template)
    assert_response :success
  end

  test "should update template" do
    patch template_url(@template), params: { template: { question_id: @template.question_id, template_text: @template.template_text, user_id: @template.user_id } }
    assert_redirected_to template_url(@template)
  end

  test "should destroy template" do
    assert_difference("Template.count", -1) do
      delete template_url(@template)
    end

    assert_redirected_to templates_url
  end
end
