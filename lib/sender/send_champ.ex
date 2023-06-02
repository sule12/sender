defmodule Sender.SendChamp do
  use Tesla

  @moduledoc """
  Functions for working with SendChamp APIs
  """

  def client(endpoint) do
    [
      {Tesla.Middleware.BaseUrl, base_url()},
      {Tesla.Middleware.Opts, [endpoint: endpoint]},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"Authorization", "Bearer #{access_key()}"},
         {"content-type", "application/json"}
       ]}
    ]
    |> Tesla.client({Tesla.Adapter.Hackney, pool: :sendchamp_hackney_pool})
  end

  defp base_url do
    config = Application.get_env(:sender, :send_champ)
    Keyword.get(config, :base_url)
  end

  defp access_key do
    config = Application.get_env(:sender, :send_champ)
    Keyword.get(config, :access_key)
  end

  @doc """
  Describes how to get wallet balance

  ##Parameters: No paramaters are needed to get the wallet_balance

  ##Example
    iex(90)> Sender.SendChamp.get_wallet_balance


  %{
  business_name: "Company name is displayed here",
  code: 200,
  errors: nil,
  message: "Success",
  status: "success",
  wallet_balance: "Wallet Balance is displayed here"
  }
  """
  def get_wallet_balance do
    "wallet_balance"
    |> client()
    |> post("/wallet/wallet_balance", %{})
    |> case do
      {:ok,
       %Tesla.Env{
         body: %{
           "data" => data,
           "status" => status,
           "message" => message,
           "code" => code,
           "errors" => errors
         }
       }} ->
        %{
          business_name: data["business_name"],
          wallet_balance: data["wallet_balance"],
          status: status,
          message: message,
          code: code,
          errors: errors
        }

      {:error, _} ->
        nil
    end
  end

  @doc """
  Describes how to send sms using Send Champ APIs

  ##Parameters:
    - to: String that represents the phone number which should be in international format e.g 2348053007205
    - message: String that represents Text message being sent
    - sender_name: String that represents the sender of the message.This Sender ID must have been requested via the dashboard
    - route: String that represents a route you want your SMS to go through. dnd, non_dnd or international


  ##Example


  iex(1)> Sender.SendChamp.send_sms %{to: "2348053007205", message: "Good day", sender_name: "Phix IT", route: "non_dnd"}


  %{
  code: 200,
  errors: nil,
  id: "MN-SMS-aBksjBLTtY",
  message: "processing",
  message_status: "processing",
  phone_number: "2348053007205",
  reference: "MN-SMS-aBksjBLTtY",
  status: "success"
  }
  """

  def send_sms(body) do
    "send_sms"
    |> client()
    |> post("/sms/send", body)
    |> case do
      {:ok,
       %Tesla.Env{
         body: %{
           "data" => data,
           "status" => status,
           "message" => message,
           "code" => code,
           "errors" => errors
         }
       }} ->
        %{
          id: data["id"],
          phone_number: data["phone_number"],
          reference: data["reference"],
          message_status: data["status"],
          status: status,
          message: message,
          code: code,
          errors: errors
        }

      {:error, _} ->
        nil
    end
  end

  def create_sender_id(body) do
    "create_sender_id"
    |> client()
    |> post("/sms/create-sender-id", body)
  end

  @spec sms_delivery_report(any) :: {:error, any} | {:ok, Tesla.Env.t()}
  def sms_delivery_report(sms_uid) do
    "sms_delivery_report"
    |> client()
    |> get("/sms/status/#{sms_uid}")
  end
end
