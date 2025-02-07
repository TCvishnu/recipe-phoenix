defmodule Recipe.Emails do
  import Swoosh.Email

  def forgot_password_email(user, token) do
    frontend_url = System.get_env("FRONT_END_URL")
    from = System.get_env("EMAIL_FROM")

    case new()
         |> to(user.email)
         |> from(from)
         |> subject("Reset Your Password")
         |> text_body("Click here to reset your password: #{frontend_url}/reset-password?token=#{token}")
         |> Recipe.Mailer.deliver() do
      {:ok, response} ->
        IO.inspect(response, label: "Email Sent Successfully")
        :ok
      {:error, reason} ->
        IO.inspect(reason, label: "Email Sending Error")
        {:error, reason}
    end
  end
end
