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
CACHE_REDIS_URL=redis://localhost:6379/0
DATABASE_URL=postgres://postgres:password@localhost:5432/samba_spec
```

Update the file with your own details. Then run tests with `crystal spec`.

## Contributing

1. [Fork it](https://github.com/GrottoPress/samba/fork)
1. Switch to the `master` branch: `git checkout master`
1. Create your feature branch: `git checkout -b my-new-feature`
1. Make your changes, updating changelog and documentation as appropriate.
1. Commit your changes: `git commit`
1. Push to the branch: `git push origin my-new-feature`
1. Submit a new *Pull Request* against the `GrottoPress:master` branch.
