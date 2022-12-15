# Samba

**Samba** augments *Shield*'s OAuth 2 implementation with authentication. It is a simpler alternative to OpenID Connect...

<!-- TODO: -->

## Installation

*Samba* must be installed on the authorization server and all clients.

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

1. Require *Samba* in your authorization server app:

   ```crystal
   # ->>> src/app.cr

   # ...
   require "samba/server"
   # ...
   ```

1. Require *Samba* in your client apps:

   ```crystal
   # ->>> src/app.cr

   # ...
   require "samba/client"
   # ...
   ```

## Usage

...<!-- TODO: Write usage instructions here -->

## Development

Create a `.env` file:

```env
CLIENT_CACHE_REDIS_URL=redis://localhost:6379/0
CLIENT_DATABASE_URL=postgres://postgres:password@localhost:5432/samba_client_spec
SERVER_DATABASE_URL=postgres://postgres:password@localhost:5432/samba_server_spec
```

Update the file with your own details, then run tests as follows:

- Run client tests with `crystal spec spec/client`
- Run server tests with `crystal spec spec/server`

*Do not run client and server tests together; you would get a compile error.*

## Contributing

1. [Fork it](https://github.com/GrottoPress/samba/fork)
1. Switch to the `master` branch: `git checkout master`
1. Create your feature branch: `git checkout -b my-new-feature`
1. Make your changes, updating changelog and documentation as appropriate.
1. Commit your changes: `git commit`
1. Push to the branch: `git push origin my-new-feature`
1. Submit a new *Pull Request* against the `GrottoPress:master` branch.
