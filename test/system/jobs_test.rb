require "application_system_test_case"

class JobsTest < ApplicationSystemTestCase
  setup do
    @job = jobs(:one)
  end

  test "visiting the index" do
    visit jobs_url
    assert_selector "h1", text: "Jobs"
  end

  test "should create job" do
    visit jobs_url
    click_on "New job"

    fill_in "Created at", with: @job.created_at
    check "Is done" if @job.is_done
    check "Is running" if @job.is_running
    fill_in "Model", with: @job.model_id
    fill_in "Question", with: @job.question_id
    fill_in "Run time", with: @job.run_time
    fill_in "Start time", with: @job.start_time
    fill_in "Template", with: @job.template_id
    fill_in "User", with: @job.user_id
    click_on "Create Job"

    assert_text "Job was successfully created"
    click_on "Back"
  end

  test "should update Job" do
    visit job_url(@job)
    click_on "Edit this job", match: :first

    fill_in "Created at", with: @job.created_at
    check "Is done" if @job.is_done
    check "Is running" if @job.is_running
    fill_in "Model", with: @job.model_id
    fill_in "Question", with: @job.question_id
    fill_in "Run time", with: @job.run_time
    fill_in "Start time", with: @job.start_time
    fill_in "Template", with: @job.template_id
    fill_in "User", with: @job.user_id
    click_on "Update Job"

    assert_text "Job was successfully updated"
    click_on "Back"
  end

  test "should destroy Job" do
    visit job_url(@job)
    click_on "Destroy this job", match: :first

    assert_text "Job was successfully destroyed"
  end
end
