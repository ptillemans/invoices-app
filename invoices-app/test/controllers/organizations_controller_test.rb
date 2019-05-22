require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  setup do
    @organization = organizations(:melexis)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organizations)
  end


  test "should get new" do
    skip("Disabled till able to mock the ViiperUploader service")
    get :new
    assert_response :success
  end

  test 'should create organization' do
    Organization.where(name: 'Test Org').delete_all

    assert_difference('Organization.count') do
      post :create, organization: {name: 'Test Org', backends: %w(jira viiper)}
    end

    org = Organization.find_by(name: 'Test Org')
    assert_equal %w(jira viiper), org.backends

    assert_redirected_to organization_path(assigns(:organization))
  end

  test 'should show organization' do
    get :show, id: @organization
    assert_response :success
  end

  test 'should get edit' do
    skip("Disabled till able to mock the ViiperUploader service")
    get :edit, id: @organization
    assert_response :success
  end

  test 'should update organization' do
    patch :update, id: @organization, organization: { name: "Test Org" }
    assert_redirected_to organization_path(assigns(:organization))
  end

  test 'should destroy organization' do
    assert_difference('Organization.count', -1) do
      delete :destroy, id: @organization
    end

    assert_redirected_to organizations_path
  end
end
