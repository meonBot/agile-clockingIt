require File.dirname(__FILE__) + '/../test_helper'

class ApplicationControllerTest < ActionController::TestCase
  tests ActivitiesController

  fixtures :users, :companies, :customers, :tasks, :projects, :milestones, :work_logs

  def setup
    login
  end

  test "should get current_user" do
     get :index
     assert_equal users(:admin), @controller.current_user
  end

  test "user 1 should be admin" do
     get :index
     assert assigns(:current_user).admin?
  end

  test "user 2 should NOT be admin" do
    user = users(:fudge)
    user.company.create_default_statuses

    @request.session[:user_id] = user.id
    get :index
    assert !assigns(:current_user).admin?
  end

  test "parse_time should handle 1w2d3h4m" do
     get :index
     assert_equal 200040, @controller.parse_time("1w2d3h4m")
     assert_equal 240, @controller.parse_time("4m")
     assert_equal 27000, @controller.parse_time("1d")
  end

  test "clients menu item should show for non admin users with read client option" do
    user = users(:admin)
    user.update_attributes(:read_clients => true, :option_externalclients => true)
    user.admin=false
    user.save!
    get :index
    assert_response :success
    assert_tag(:a, :attributes => { :href => "/clients/list" })
  end

  test "clients menu item should not show for non admin users without read client option" do
    user = users(:admin)
    user.update_attributes(:read_clients => false, :option_externalclients => true)
    user.admin=false
    user.save!
    get :index
    assert_response :success
    assert_no_tag(:a, :attributes => { :href => "/clients/list" })
  end

  test "should never redirect back to url with ?format=js" do
    session[:history] = [ "/tasks/list?format=js" ]
    get :redirect_from_last
    assert_redirected_to "/tasks/list?"
  end

  test "should render auto_complete_for_user_name" do
    get :auto_complete_for_user_name, :user => { :name => "aaa" }
    assert_response :success
  end

  test "should render auto_complete_for_customer_name" do
    get :auto_complete_for_customer_name, :customer => { :name => "aaa" }
    assert_response :success
  end

  context "an install with no companies" do
    setup do
      Company.destroy_all
    end

    should "redirect to install path" do
      get :index
      assert_redirected_to "/install"
    end
  end
end
