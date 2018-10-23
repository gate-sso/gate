class DataDogClient
  include HTTParty
  base_uri 'https://api.datadoghq.com/api/v1'

  def initialize(app_key, api_key)
    @base_path = 'https://api.datadoghq.com/api/v1'
    @app_key = app_key
    @api_key = api_key
    @headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
    }
  end

  def get_user(email)
    url = append_auth("/user/#{email}")
    response = self.class.get(url, headers: @headers)
    if response.success?
      JSON.parse(response.body)['user']
    else
      {}
    end
  end

  def new_user(email)
    url = append_auth('/user')
    response = self.class.post(url, body: { handle: email }.to_json, headers: @headers)
    if response.success?
      JSON.parse(response.body)['user']
    else
      {}
    end
  end

  def activate_user(email)
    url = append_auth("/user/#{email}")
    response = self.class.put(url, body: { email: email, disabled: false }.to_json, headers: @headers)
    if response.success?
      JSON.parse(response.body)['user']
    else
      {}
    end
  end

  def deactivate_user(email)
    url = append_auth("/user/#{email}")
    response = self.class.put(url, body: { email: email, disabled: true }.to_json, headers: @headers)
    if response.success?
      JSON.parse(response.body)['user']
    else
      {}
    end
  end

  private

  def append_auth(str)
    auth_str = "api_key=#{@api_key}&application_key=#{@app_key}"
    str += str.include?('?') ? "&#{auth_str}" : "?#{auth_str}"
    str
  end
end
