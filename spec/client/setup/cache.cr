Spec.before_each { Dude.truncate }

Spec.after_suite { Dude.truncate }
