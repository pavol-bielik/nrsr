require 'test_helper'

class VotingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:votings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create voting" do
    assert_difference('Voting.count') do
      post :create, :voting => { }
    end

    assert_redirected_to voting_path(assigns(:voting))
  end

  test "should show voting" do
    get :show, :id => votings(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => votings(:one).to_param
    assert_response :success
  end

  test "should update voting" do
    put :update, :id => votings(:one).to_param, :voting => { }
    assert_redirected_to voting_path(assigns(:voting))
  end

  test "should destroy voting" do
    assert_difference('Voting.count', -1) do
      delete :destroy, :id => votings(:one).to_param
    end

    assert_redirected_to votings_path
  end
end
