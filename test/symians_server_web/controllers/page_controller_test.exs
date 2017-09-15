defmodule SymiansServerWeb.PageControllerTest do
  use SymiansServerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"utf-8\">\n    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n    <meta name=\"description\" content=\"\">\n    <meta name=\"author\" content=\"\">\n\n    <title>Symians: Watch the little monkeys grow!</title>\n    <link rel=\"stylesheet\" href=\"/css/app.css\">\n  </head>\n\n  <body>\n    <p class=\"alert alert-info\" role=\"alert\"></p>\n    <p class=\"alert alert-danger\" role=\"alert\"></p>\n    <script src=\"/js/app.js\"></script>\n  </body>\n</html>\n"
  end
end
