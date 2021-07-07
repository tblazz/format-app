require "test_helper"

class DbfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dbfile = dbfiles(:one)
  end

  test "should get index" do
    get dbfiles_url
    assert_response :success
  end

  test "should get new" do
    get new_dbfile_url
    assert_response :success
  end

  test "should create dbfile" do
    assert_difference('Dbfile.count') do
      post dbfiles_url, params: { dbfile: {  } }
    end

    assert_redirected_to dbfile_url(Dbfile.last)
  end

  test "should show dbfile" do
    get dbfile_url(@dbfile)
    assert_response :success
  end

  test "should get edit" do
    get edit_dbfile_url(@dbfile)
    assert_response :success
  end

  test "should update dbfile" do
    patch dbfile_url(@dbfile), params: { dbfile: {  } }
    assert_redirected_to dbfile_url(@dbfile)
  end

  test "should destroy dbfile" do
    assert_difference('Dbfile.count', -1) do
      delete dbfile_url(@dbfile)
    end

    assert_redirected_to dbfiles_url
  end
end
