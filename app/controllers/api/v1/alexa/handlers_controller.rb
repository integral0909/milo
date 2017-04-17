# ================================================
# RUBY->API->V1->ALEXA-CONTROLLER ================
# ================================================
class Api::V1::Alexa::HandlersController < ActionController::Base

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    message = "hello from Shift!"
    session_attributes = {"previous_session": "something"}
    session_end = true

    render json: {
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": message,
        },
        "shouldEndSession": session_end
      },
      "sessionAttributes": session_attributes
    }
  end
end
