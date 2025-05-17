require "test_helper"

class CredoresControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get credores_create_url
    assert_response :success
  end

  test "should get show" do
    get credores_show_url
    assert_response :success
  end

  test "should get upload_documento" do
    get credores_upload_documento_url
    assert_response :success
  end

  test "should get upload_certidao" do
    get credores_upload_certidao_url
    assert_response :success
  end

  test "should get buscar_certidoes" do
    get credores_buscar_certidoes_url
    assert_response :success
  end
end
