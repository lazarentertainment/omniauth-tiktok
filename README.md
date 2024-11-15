# Tiktok OAuth2 Strategy for OmniAuth.

Supports OAuth 2.0 server-side flow with Tiktok API.
Read the Tiktok docs for more details: https://developers.tiktok.com/doc/login-kit-web

## Usage

`OmniAuth::Strategies::Tiktok` is simply a Rack middleware. Read the OmniAuth docs for detailed instructions: https://github.com/omniauth/omniauth.

Here's a quick example, adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :tiktok, CLIENT_KEY, CLIENT_SECRET, *options
end
```

...Or with devise (https://github.com/heartcombo/devise#omniauth)

```ruby
# config/initializers/devise.rb
config.omniauth(
    :tiktok,
    CLIENT_KEY,
    CLIENT_SECRET,
    ...options
)

```

## Options

* `skip_info`: skip User Info API call to retrieve `info` hash. default: `false`
* `scope`: oauth scopes, seperated by comma. default: `"user.info.basic"`
* `callback_url`: override default callback_url
* `callback_path`: override default callback_path

## Auth Hash

Here's an example Auth Hash available in `request.env['omniauth.auth']`:

```
{
  provider: 'tiktok',
  uid: '1234567',
  info: {
    display_name: 'ABCDEF'
  },
  credentials: {
    token: 'ABCDEF...', # OAuth 2.0 access_token, which you may wish to store
    expires_at: 1321747205, # when the access token expires (it always will)
    expires: true, # this will always be true
    refresh_token: 'ABCDEF', # it will be valid for 365 days
    refresh_token_expires_at: 1111111 # timestamp
  }
}
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OmniAuth::Tiktok project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lazarentertainment/omniauth-tiktok/blob/master/CODE_OF_CONDUCT.md).