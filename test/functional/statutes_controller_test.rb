require 'test_helper'

class StatutesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:statutes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create statute" do
    assert_difference('Statute.count') do
      post :create, :statute => { }
    end

    assert_redirected_to statute_path(assigns(:statute))
  end

  test "should show statute" do
    get :show, :id => statutes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => statutes(:one).to_param
    assert_response :success
  end

  test "should update statute" do
    put :update, :id => statutes(:one).to_param, :statute => { }
    assert_redirected_to statute_path(assigns(:statute))
  end

  test "should destroy statute" do
    assert_difference('Statute.count', -1) do
      delete :destroy, :id => statutes(:one).to_param
    end

    assert_redirected_to statutes_path
  end
end
