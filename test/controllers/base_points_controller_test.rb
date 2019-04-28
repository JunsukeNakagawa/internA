require 'test_helper'

class BasePointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @base_point = base_points(:one)
  end

  test "should get index" do
    get base_points_url
    assert_response :success
  end

  test "should get new" do
    get new_base_point_url
    assert_response :success
  end

  test "should create base_point" do
    assert_difference('BasePoint.count') do
      post base_points_url, params: { base_point: { attendance_state: @base_point.attendance_state, name: @base_point.name, number: @base_point.number } }
    end

    assert_redirected_to base_point_url(BasePoint.last)
  end

  test "should show base_point" do
    get base_point_url(@base_point)
    assert_response :success
  end

  test "should get edit" do
    get edit_base_point_url(@base_point)
    assert_response :success
  end

  test "should update base_point" do
    patch base_point_url(@base_point), params: { base_point: { attendance_state: @base_point.attendance_state, name: @base_point.name, number: @base_point.number } }
    assert_redirected_to base_point_url(@base_point)
  end

  test "should destroy base_point" do
    assert_difference('BasePoint.count', -1) do
      delete base_point_url(@base_point)
    end

    assert_redirected_to base_points_url
  end
end
