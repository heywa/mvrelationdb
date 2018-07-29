require 'test_helper'

class RelationtblsControllerTest < ActionController::TestCase
  setup do
    @relationtbl = relationtbls(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:relationtbls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create relationtbl" do
    assert_difference('Relationtbl.count') do
      post :create, relationtbl: { frommvid: @relationtbl.frommvid, fromtitle: @relationtbl.fromtitle, relationid: @relationtbl.relationid, tomvid: @relationtbl.tomvid, totitle: @relationtbl.totitle, updatedate: @relationtbl.updatedate }
    end

    assert_redirected_to relationtbl_path(assigns(:relationtbl))
  end

  test "should show relationtbl" do
    get :show, id: @relationtbl
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @relationtbl
    assert_response :success
  end

  test "should update relationtbl" do
    patch :update, id: @relationtbl, relationtbl: { frommvid: @relationtbl.frommvid, fromtitle: @relationtbl.fromtitle, relationid: @relationtbl.relationid, tomvid: @relationtbl.tomvid, totitle: @relationtbl.totitle, updatedate: @relationtbl.updatedate }
    assert_redirected_to relationtbl_path(assigns(:relationtbl))
  end

  test "should destroy relationtbl" do
    assert_difference('Relationtbl.count', -1) do
      delete :destroy, id: @relationtbl
    end

    assert_redirected_to relationtbls_path
  end
end
