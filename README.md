# Rack basic

## Setup

- `bundle gem simplemvc` #=> simplemvc is gem's name

- In the `simplemvc.gemspec`, we need to add :

```rb
spec.add_runtime_dependency "rack"
# Then remember to run bundle in simplemvc
```

- And then implement the simplemvc.rb.

```rb
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

```rb
require './config/application.rb'

run Blog::Application.new
```

- Then we can run `rackup` to boot up.

------------------

## Routing

- As an example, we need to route `/pages/about` to the method `about` in the PageController.

- First, we open our `simplemvc.rb`, and let's read some codes.

```rb
require "simplemvc/version"

module Simplemvc
  class Application

    def call(env)
      # env["PATH_INFO"] = "/pages/about" => PagesController.send(:about)
      controller_class, action = get_controller_and_action(env)
      response = controller_class.new.send(action)
      [200, {"Content-Type" => "text/html"}, [response]]
    end

    def get_controller_and_action(env)
        _, controller_name, action = env["PATH_INFO"].split("/") #=> ['', 
        controller_name = controller_name.capitalize + "Controller"
        [Object.const_get(controller_name), action] 
    end
    
  end
end
```

- Now we can add PagesController in our blog application.

(`app/controllers/pages_controller.rb`, semms familiar, right? )


- Here is what pages controller looks like:

```rb 
class PagesController
  def about
    "about me"
  end
end
```

- Then we need to make our application know where and what pages controller is. So in the `application.rb`


```rb
require 'simplemvc'

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "app", "controllers")
require 'pages_controller'
module Blog
  class Application < Simplemvc::Application
    
  end
end
```




