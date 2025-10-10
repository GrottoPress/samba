module Samba::AllClientIds
  macro included
    private def all_client_ids
      Samba.settings.oauth_client_ids.tap do |ids|
        Samba.settings.oauth_client.try do |client|
          ids << client[:id] unless ids.includes?(client[:id])
        end
      end
    end
  end
end
