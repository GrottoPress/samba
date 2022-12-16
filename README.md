# Samba

**Samba** is a Single Sign On authentication solution for [Lucky](https://luckyframework.org) framework. It extends [Shield](https://github.com/grottopress/shield)'s OAuth 2 implementation with authentication capabilities.

*Samba* allows a user to log in once in an organization, and gain automatic access other apps in the organization. Conversely, when a user logs out of one app, they are automatically logged out of all other apps.

*Samba* defines two roles:

1. **Server**: An OAuth 2 authorization server maintained by your organization.

1. **Client**: Any application within your organization, other than the *Samba* Server, whose user identification and authentication functions are handled by the Server.

## Installation

### The Server

*You should already have an OAuth 2 authorization server. See *Shield*'s [documentation](https://github.com/GrottoPress/shield/tree/master/docs) for details.*

1. Add the dependency to your `shard.yml`:

   ```yaml
   # ->>> shard.yml

   # ...
   dependencies:
     samba:
       github: GrottoPress/samba
   # ...
   ```

1. Run `shards install`

1. Require *Samba* in your app:

   ```crystal
   # ->>> src/app.cr

   # ...
   require "samba/server"
   # ...
   ```

1. Require *presets*, right after *Shield*'s presets:

   ```crystal
   # ->>> src/app.cr

   # ...
   require "./models/base_model"
   require "./models/**"

   require "shield/presets"
   require "samba/presets/server"
   # ...
   ```

### The Client

1. Add the dependency to your `shard.yml`:

   ```yaml
   # ->>> shard.yml

   # ...
   dependencies:
     samba:
       github: GrottoPress/samba
   # ...
   ```

1. Run `shards install`

1. Require *Samba* in your app:

   ```crystal
   # ->>> src/app.cr

   # ...
   require "samba/client"
   # ...
   ```

1. Require *presets*, right after models:

   ```crystal
   # ->>> src/app.cr

   # ...
   require "./models/base_model"
   require "./models/**"

   require "samba/presets/client"
   # ...
   ```

## Usage

### The Server

1. Set up actions:

   ```crystal
   # ->>> src/actions/oauth/authorization/create.cr

   Oauth::Authorization::Create < BrowserAction
     # ...
     include Samba::Oauth::Authorization::Create

     post "/oauth/authorization" do
       run_operation
     end
     # ...
   end
   ```

   `Samba::Oauth::Authorization::Create` modifies `Shield::Oauth::Authorization::Create` to set the OAuth client ID in session after a successful authorization code request.

   These client IDs are used to determine which `BearerLogin` tokens to revoke whenever a user logs out.

   ---
   ```crystal
   # ->>> src/actions/current_login/destroy.cr

   class CurrentLogin::Destroy < BrowserAction
     # ...
     include Samba::CurrentLogin::Destroy

     get "/logout" do
       run_operation
     end
     # ...
   end
   ```

   This action is used for Single Sign Out. All a *Samba* Client has to do is point its logout link to this URL.

### The Client

Each *Samba* Client must be registered with the *Samba* Server as a *confidential* OAuth client, if it is a full stack monolith.

If a *Samba* Client is an API backend, each of its frontend apps, rather, must be registered with the Server. They may or may not be *confidential* OAuth clients.

1. Configure:

   ```crystal
   # ->>> config/samba.cr

   Samba.configure do |settings|
     # ...
     settings.oauth_authorization_endpoint = "https://samba.server/oauth/authorize"

     # The OAuth client details
     # If this app is an API backend, set to `nil`.
     settings.oauth_client = {
       id: "x9y8z7",
       # This URI must match what was used to register the OAuth client
       redirect_uri: Oauth::Callback.url_without_query_params,
       secret: "a1b2c3"
     }
   
     # Additional trusted OAuth clients whose tokens are accepted for
     # authentication. If this app is an API backend, set this to all the OAuth
     # client IDs of all its frontend apps. Otherwise, leave empty.
     settings.oauth_client_ids = ["def456"]
   
     settings.oauth_token_endpoint = "https://samba.server/oauth/token"
   
     settings.oauth_token_introspection_endpoint =
       "https://samba.server/oauth/token/verify"

     # The challenge method to use for authorization code requests
     settings.oauth_code_challenge_method = "S256"
   
     # *Samba* makes an API call to the OAuth introspection endpoint whenever a
     # request is received. This setting allows caching the response.
     settings.verify_oauth_token = ->(key : String, verify : -> OauthToken) do
       # This example uses Dude (https://github.com/GrottoPress/dude), but you
       # may use any caching engine of choice
       #
       # `verify.call` is what actually does the API call
       Dude.get(OauthToken, key, 30.seconds) { verify.call }
     end

     # This token may be used when making token introspection requests.
     # It is required if this app is an API backend. Otherwise, if you do
     # not need to use it in any way, set to `nil`.
     #
     # This is typically a user-generated bearer token with access to the
     # token instrospection endpoint, at least.
     settings.server_api_token = "g4h5i6"
     # ...

     # A Client sends an authorization code request with the "sso" scope to
     # signal to the Server this is an authentication request.
     #
     # Specify additional scopes to request when sending the authorization code
     # request.
     #
     # (You'd typically want access to some sort of a user info endpoint
     # that the Server exposes)
     settings.login_token_scopes = ["server.current_user.show"]
   end
   ```

1. Set up models:

   ```crystal
   # ->>> src/models/user.cr

   class User < BaseModel
     # ...
     table :users do
       # ...
       column remote_id : Int64
       # ...
     end

     # Since this app is within your organization, you may not want to
     # duplicate user information across apps. The recommendation is
     # to keep all user data at the Server, and define a method at each
     # Client that fetches the info from the Server when needed.
     #
     # This example uses Dude (https://github.com/GrottoPress/dude) for
     # caching.
     #
     # Another recommendation is to have all Clients share a single cache
     # store, so that when a Client writes data to the store, other Clients
     # can read it without going to the Server.
     getter remote : RemoteUser? do
       key = "users:#{remote_id}"
       Dude.get(RemoteUser, key, 3.minutes) { remote! }
     end

     def remote! : RemoteUser?
       # The server API token must have the needed scope to access
       # endpoint being requested
       token = Samba.settings.server_api_token
       # Do a HTTP GET for the user using the server API token
     end

     # An example for using with Carbon mailer
     #
     include Carbon::Emailable

     def email : String
       remote.not_nil!.email.not_nil!
     end

     def emailable : Carbon::Address
       Carbon::Address.new(email)
     end
     # ...
   end
   ```

   The `remote_id` column is required. The type of this column should match the primary key type of the `User` model of the *Samba* Server.

1. Set up migrations:

   ```crystal
   # ->>> db/migrations/XXXXXXXXXXXXXX_create_users.cr

   class CreateLogins::VXXXXXXXXXXXXXX < Avram::Migrator::Migration::V1
     def migrate
       create :users do
         # ...
         add remote_id : Int64, unique: true
         # ...
       end
     end

     def rollback
       drop :users
     end
   end
   ```

1. Set up actions:

   While the setup instructions here are for full stack monoliths, there are API equivalents of each action that should be used when building a decoupled API backend.

   ```crystal
   # ->>> src/actions/browser_action.cr

   abstract class BrowserAction < Lucky::Action
     # ...
     include Samba::LoginHelpers
     include Samba::LoginPipes

     #skip :pin_login_to_ip_address

     #def do_require_logged_out_failed
     #  flash.info = Rex.t(:"action.pipe.not_logged_out")
     #  redirect_back fallback: CurrentUser::Show
     #end
 
     #def do_check_authorization_failed
     #  flash.failure = Rex.t(:"action.pipe.authorization_failed")
     #  redirect_back fallback: CurrentUser::Show
     #end
     # ...
   end
   ```

   ---
   ```crystal
   # ->>> src/actions/oauth/callback.cr

   class Oauth::Callback < BrowserAction
     # ...
     include Samba::Oauth::Token::Create

     get "/oauth/callback" do
       run_operation
     end
     # ...
   end
   ```

   This action must match the redirect URI registered for the client.

### Federation

While *Samba* is designed for use in your own organization, it should not stand in your way if you decide to bolt on authentication from Identity Providers outside your organization.

For instance, you may add a "Log in with GitHub" button to your *Samba* Server's login page, that allows your users to log in with GitHub. *Samba* does not care how the user logs in.

When your user is logged in at your *Samba* Server, however they were logged in, *Samba* would log them in automatically if the user tries to access any of your organization's apps.

Note, however, that *Samba* itself cannot be used to implement a "Log in with GitHub" login flow, for instance. You may need to read the GitHub API, and use whatever libraries and tools they provide for such a purpose.

If you decide to go federated, only your *Samba* Server should interact with services outside your organization. The server may be registered with the third-party provider as an OAuth client for such a purpose.

## Development

Create a `.env` file:

```env
CLIENT_CACHE_REDIS_URL=redis://localhost:6379/0
CLIENT_DATABASE_URL=postgres://postgres:password@localhost:5432/samba_client_spec
SERVER_DATABASE_URL=postgres://postgres:password@localhost:5432/samba_server_spec
```

Update the file with your own details, then run tests as follows:

- Run Client tests with `crystal spec spec/client`
- Run Server tests with `crystal spec spec/server`

*Do not run client and server tests together; you would get a compile error.*

## Contributing

1. [Fork it](https://github.com/GrottoPress/samba/fork)
1. Switch to the `master` branch: `git checkout master`
1. Create your feature branch: `git checkout -b my-new-feature`
1. Make your changes, updating changelog and documentation as appropriate.
1. Commit your changes: `git commit`
1. Push to the branch: `git push origin my-new-feature`
1. Submit a new *Pull Request* against the `GrottoPress:master` branch.
