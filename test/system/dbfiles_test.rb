require "application_system_test_case"

class DbfilesTest < ApplicationSystemTestCase
  setup do
    @dbfile = dbfiles(:one)
  end

  test "visiting the index" do
    visit dbfiles_url
    assert_selector "h1", text: "Dbfiles"
  end

  test "creating a Dbfile" do
    visit dbfiles_url
    click_on "New Dbfile"

    click_on "Create Dbfile"

    assert_text "Dbfile was successfully created"
    click_on "Back"
  end

  test "updating a Dbfile" do
    visit dbfiles_url
    click_on "Edit", match: :first

    click_on "Update Dbfile"

    assert_text "Dbfile was successfully updated"
    click_on "Back"
  end

  test "destroying a Dbfile" do
    visit dbfiles_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Dbfile was successfully destroyed"
  end
end
