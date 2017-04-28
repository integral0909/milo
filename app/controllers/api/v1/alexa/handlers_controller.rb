# ================================================
# RUBY->API->V1->ALEXA-CONTROLLER ================
# ================================================
class Api::V1::Alexa::HandlersController < ActionController::Base

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  prepend_before_action :set_access_token_in_params
  before_action only: [:create] do
    doorkeeper_authorize! :admin, :write
  end

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  # receive and check intent then render response
  def create
    user = current_doorkeeper_user
    intent_name = params["request"]["intent"]["name"]
    case intent_name
    when "GetAccountBalance"
      account_balance = user.account_balance / 100.00
      message = "The Shift account balance is $#{account_balance}!"
      render response_with_message(message)
    else
      #error somehow
      render response_with_message("Error. We couldn't find your request")
    end
  end

  # ----------------------------------------------
  # CURRENT-DOORKEEPER-USER ----------------------
  # ----------------------------------------------
  # grab a user from the passed over access_token
  def current_doorkeeper_user
    @current_doorkeeper_user ||= User.find(doorkeeper_token.resource_owner_id)
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # RESPONSE-WITH-MESSAGE ------------------------
  # ----------------------------------------------
  def response_with_message(message)
    {
      json: {
        "response": {
          "outputSpeech": {
            "type": "PlainText",
            "text": message,
          },
          "shouldEndSession": true
        },
        "sessionAttributes": {}
      }
    }
  end

  # ----------------------------------------------
  # SET-ACCESS-TOKENS-IN-PARAMS ------------------
  # ----------------------------------------------
  def set_access_token_in_params
    request.parameters[:access_token] = token_from_params
  end

  # ----------------------------------------------
  # TOKEN-FROM-PARAMS ----------------------------
  # ----------------------------------------------
  def token_from_params
    params["session"]["user"]["accessToken"] rescue nil
  end

end
