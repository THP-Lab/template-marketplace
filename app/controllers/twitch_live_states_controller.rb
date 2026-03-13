class TwitchLiveStatesController < ApplicationController
  def show
    render json: live_state_payload
  end

  private

  def live_state_payload
    Twitch::LiveStatePresenter.new(
      company_information: CompanyInformation.instance,
      stream_state: TwitchStreamState.current,
      request: request
    ).as_json
  end
end
