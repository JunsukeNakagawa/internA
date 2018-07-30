require 'test_helper'

class WorksControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get works_new_url
    assert_response :success
  end

end
