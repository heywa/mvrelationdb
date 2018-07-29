require 'test_helper'

class RelationlistsControllerTest < ActionController::TestCase
  setup do
    @relationlist = relationlists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:relationlists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create relationlist" do
    assert_difference('Relationlist.count') do
      post :create, relationlist: { frommvid: @relationlist.frommvid, fromtitle: @relationlist.fromtitle, relationid: @relationlist.relationid, tomvid: @relationlist.tomvid, totitle: @relationlist.totitle, updatedate: @relationlist.updatedate }
    end

    assert_redirected_to relationlist_path(assigns(:relationlist))
  end

  test "should show relationlist" do
    get :show, id: @relationlist
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @relationlist
    assert_response :success
  end

  test "should update relationlist" do
    patch :update, id: @relationlist, relationlist: { frommvid: @relationlist.frommvid, fromtitle: @relationlist.fromtitle, relationid: @relationlist.relationid, tomvid: @relationlist.tomvid, totitle: @relationlist.totitle, updatedate: @relationlist.updatedate }
    assert_redirected_to relationlist_path(assigns(:relationlist))
  end

  test "should destroy relationlist" do
    assert_difference('Relationlist.count', -1) do
      delete :destroy, id: @relationlist
    end

    assert_redirected_to relationlists_path
  end
end
