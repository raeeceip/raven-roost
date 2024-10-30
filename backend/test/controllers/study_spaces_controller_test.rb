require "test_helper"

class StudySpacesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get study_spaces_index_url
    assert_response :success
  end

  test "should get show" do
    get study_spaces_show_url
    assert_response :success
  end

  test "should get search" do
    get study_spaces_search_url
    assert_response :success
  end

  test "should get toggle_favorite" do
    get study_spaces_toggle_favorite_url
    assert_response :success
  end
end
