require "test_helper"

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get upload" do
    get main_upload_url
    assert_response :success
  end

  test "should get edit" do
    get main_edit_url
    assert_response :success
  end

  test "should get download" do
    get main_download_url
    assert_response :success
  end
end
