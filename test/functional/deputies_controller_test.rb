require 'test_helper'

class DeputiesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:deputies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create deputy" do
    assert_difference('Deputy.count') do
      post :create, :deputy => { }
    end

    assert_redirected_to deputy_path(assigns(:deputy))
  end

  test "should show deputy" do
    get :show, :id => deputies(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => deputies(:one).to_param
    assert_response :success
  end

  test "should update deputy" do
    put :update, :id => deputies(:one).to_param, :deputy => { }
    assert_redirected_to deputy_path(assigns(:deputy))
  end

  test "should destroy deputy" do
    assert_difference('Deputy.count', -1) do
      delete :destroy, :id => deputies(:one).to_param
    end

    assert_redirected_to deputies_path
  end
end
