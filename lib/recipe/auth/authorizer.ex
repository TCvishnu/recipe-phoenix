defmodule Authorizer do
  def can?(conn, record) do
    conn.assigns.current_user.id == record.user_id
  end
end
