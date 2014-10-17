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

- But now if we go to the route '/' will occur error, we can fix it by do this in simplemvc.rb:

```rb
      if env["PATH_INFO"] == "/"
        return [302, {"Location" => "/pages/about"}, []]
      end
```

## Rendering views

- We got to use erubis to render template

- `gem install erubis` ( in the blog app)

- Then we should add dependency in the simplemvc.gemspec and run bundle

```rb  
  spec.add_runtime_dependency "erubis"
```

- In the simplemvc/lib/simplemvc, we create a controller.rb

```rb  
require "erubis"

module Simplemvc
  class Controller
    def render(view_name, locals = {})
      filename = File.join("app", "views", controller_name, "#{view_name}.erb")
      template = File.read(filename)
      Erubis::Eruby.new(template).result(locals)
    end

    def controller_name
      self.class.to_s.gsub(/Controller$/, "").downcase
    end
  end
end
```

- Then we should require controller.rb in the simplemvc.rb

```rb
require "simplemvc/version"
require "simplemvc/controller.rb"

module Simplemvc
  class Application

    def call(env)
      if env["PATH_INFO"] == "/"
        return [302, {"Location" => "/pages/about"}, []]
      end
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

- Finally, we set the PagesController inheritate to Simplemvc::Controller

```rb  
class PagesController < Simplemvc::Controller
  def about
    "about me"
    render :about, name: "Denny", last_name: "Ku"
  end
end
```

- Now app/views/pages/about.erb can be accessed

### Camelcase constant?

- We need to Open the String class and do some stuffs.

- First in the simplemvc.rb

```rb 
require "simplemvc/utils.rb"
```

- Then create the utils.rb

```rb 
class String
  def to_snake_case
    self.gsub("::", "/").
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').        #FOOBar => foo_bar
      gsub(/([a-z\d])([A-Z])/, '\1_\2').       #FO86OBar #=> fo86_o_bar
      tr("-", "_").
      downcase
  end

  def to_camel_case
    return self if self !~ /_/ && self =~ /[A-z]+.*/
    split('_').map{ |str| str.capitalize }.join # hi_there #=> HiThere
  end

end
```

- Then we change the `downcase` in controller.rb to `to_snake_case` 

- And `capitalize` in simplemvc.rb to `to_camel_case`

- Then it works. We now following the naming convention in Rails.

--------------------

