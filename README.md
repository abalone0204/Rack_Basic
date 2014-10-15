# Rack basic

## Setup

- `bundle gem simplemvc` #=> simplemvc is gem's name

- In the `simplemvc.gemspec`, we need to add :

```rb
spec.add_runtime_dependency "rack"
# Then remember to run bundle in simplemvc
```

- And then implement the simplemvc.rb.

```rb simplemvc.rb 
require "simplemvc/version"

module Simplemvc
  class Application
    def call(env)
      [200, {"Content-Type" => "text/html"}, ["Hello"]]
      # [http status, header, response]
    end
  end
end
```

- run `gem build simplemvc.gemspec`

- Now we can using our gem 

- create a directory, in there, blog, then set the Gemfile.

```rb
source "https://rubygems.org"

gem "simplemvc", path: "../simplemvc"
```

- We add the path after `gem "simplemvc"`, because of doing so, we can use simplemvc directly instead building it again everytime we update it.

- Then we set the `config.ru` in oreder to boot up our blog app by rack.

```rb config.ru 
require './config/application.rb'

run Blog::Application.new
```

- Then we can run `rackup` to boot up.


