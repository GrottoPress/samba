Spec.before_each { Dude.settings.store.try(&.truncate) }

Spec.after_suite { Dude.settings.store.try(&.truncate) }
