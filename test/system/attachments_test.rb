require "application_system_test_case"

class AttachmentsTest < ApplicationSystemTestCase
  setup do
    @attachment = attachments(:one)
  end

  test "visiting the index" do
    visit attachments_url
    assert_selector "h1", text: "Attachments"
  end

  test "should create attachment" do
    visit attachments_url
    click_on "New attachment"

    fill_in "Content type", with: @attachment.content_type
    fill_in "Contents", with: @attachment.contents
    fill_in "Created at", with: @attachment.created_at
    fill_in "File name", with: @attachment.file_name
    fill_in "File path", with: @attachment.file_path
    fill_in "File type", with: @attachment.file_type
    click_on "Create Attachment"

    assert_text "Attachment was successfully created"
    click_on "Back"
  end

  test "should update Attachment" do
    visit attachment_url(@attachment)
    click_on "Edit this attachment", match: :first

    fill_in "Content type", with: @attachment.content_type
    fill_in "Contents", with: @attachment.contents
    fill_in "Created at", with: @attachment.created_at
    fill_in "File name", with: @attachment.file_name
    fill_in "File path", with: @attachment.file_path
    fill_in "File type", with: @attachment.file_type
    click_on "Update Attachment"

    assert_text "Attachment was successfully updated"
    click_on "Back"
  end

  test "should destroy Attachment" do
    visit attachment_url(@attachment)
    click_on "Destroy this attachment", match: :first

    assert_text "Attachment was successfully destroyed"
  end
end
