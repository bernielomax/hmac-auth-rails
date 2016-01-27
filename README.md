# hmac-auth-rails

#### Disclaimer: Although this is covered in the MIT license agreement, please be aware that in no way will the authors be responsible for any security issues or loss of income that may arise from using this code. Use this code at your own risk.

## Overview

This application integrates with Rails and provides in-built SHA1 HMAC authentication. It was originally built to be used with [angular-hmac-auth](https://github.com/todopagos/angular-hmac-auth) an open-source Angular module. Currently it only supports SHA1 encryption. If you require better encryption methods please contribute.

## Installation

### Install the Gemfile

Add the following line to your Rails Gemfile:

`gem 'hmac-auth-rails'`

### Make your authentication model authenticatable

Add the line below to your applications model that handles the authentication:

```
class User < ActiveRecord::Base

  hmac_authenticatable
```  

### Built-in authentication fields

To use built-in fields you will need to ensure that your authentication model has the `auth_token` and `secret_key` string fields defined: 

```
class User < ActiveRecord::Base

  hmac_authenticatable
  
  field :auth_token, type: String
  field :secret_key, type: String
```

### Custom authentication fields

If you do not wish to use the built-in fields you can specifiy your own custom fields in the model:

```
class User < ActiveRecord::Base

  hmac_authenticatable
  
  self.auth_token_field = :custom_auth_token
  self.secret_key_field = :custom_secret_key
  
  field :custom_auth_token, type: String
  field : custom_secret_key, type: String
```

### Auto-generating auth tokens and secret keys

The following snippet can help you in setting up your model to auto-generate the `auth_token` and `secret_key` when a new record is initialised.

```
  after_initialize :generate_key, :generate_token

  protected
  def generate_token
    self.auth_token ||= loop do
      random_token = SecureRandom.hex(32)
      break random_token unless User.exists?(auth_token: random_token)
    end
  end

  def generate_key
    self.secret_key  ||= SecureRandom.base64(64)
  end
```

### When using devise

To ensure that you validate HMAC authentication before the `:authenticate_user!` method is called. You will want the following line.

`prepend_before_filter :hmac_auth`

To exclude certain actions from being `hmac_authenticatable` you could use the following exclude parameter.

`prepend_before_filter :hmac_auth, :except => :my_action`

### Applying HMAC authentication globaly

A good way to apply HMAC authentication globaly is to add `:hmac_auth` to your `ApplicationController` and inherit the controller for all other sub-controllers.

```
module Api::V1
  class ApiController < ApplicationController
    prepend_before_filter :hmac_auth
  end
end
```

Your sub-controller would look similar to the following:

```
module Api::V1
  class UsersController < ApiController
  end
end
```

## Testing with Rspec

Set into the `spec/dummy` folder and run the following:

```
bundle exec rspec
```

## Plays nice with

### todopagos/angular-hmac-auth

[https://github.com/todopagos/angular-hmac-auth](https://github.com/todopagos/angular-hmac-auth)

### plataformatec/devise

[https://github.com/plataformatec/devise](https://github.com/plataformatec/devise)

## Putting all the "plays nice with" together

Create an API Application Controller that excludes the `auth` action:

```
module Api::V1
  class ApiController < ApplicationController
    prepend_before_filter :hmac_auth, :except => :auth
  end
end
```

Setup the `auth` action to set the user as the `current_user`:

```
def auth
  @user = current_user
end
```    

The `auth` jbuilder view will look like the following:

```
json.auth do
  json.auth_token @user[@user.auth_token_field]
  json.secret_key @user[@user.secret_key_field]
end
```

And when rendered:

```
{
    "auth": {
      "auth_token": "39e75f277f2edb7d9f547a8b3e21fa4c1c5fd5e213909e7c93a87539e12e60ea",
      "secret_key": "wrlM6KWL0SgyCM0sBbhXfXdwKxqDxC3Df3/wmOwiw2HZOIMvi4L1m51/fhowUz5Ys8BL2vr2GezS4lK4deXGJQ=="
    }
}
```

The following is an example of how you load the `auth` details via the `angular-hmac-auth` module and intercept all `$http` calls in order to add the HMAC authencation headers:

```
var hmacAuthApp = angular.module("hmac-auth-demo",['hmacAuthInterceptor'])

    .constant('REST_PATH', "/api/v1")

    .provider('configService', ['REST_PATH',function(REST_PATH) {
        var loadConfig = ['$http','$q', function($http,$q) {
            var deferred = $q.defer();
            $http.get(REST_PATH + '/users/auth').then(function(response) {
                deferred.resolve(response["data"]["auth"]);
            });
            return deferred.promise;
        }];
        this.$get = loadConfig;
    }])

    .config(['$httpProvider', function($httpProvider) {
        $httpProvider.interceptors.push('hmacInterceptor');
    }])

    .run(['hmacInterceptor','REST_PATH', function(hmacInterceptor,REST_PATH){
        hmacInterceptor.whitelist = REST_PATH + '/usrs/auth';
    }])

    .controller('DemoController', [ '$scope','$http','configService','hmacInterceptor','REST_PATH', function($scope,$http, configService, hmacInterceptor, REST_PATH){
        var demo = $scope;

        configService.then(function(config){
            hmacInterceptor.accessId =  config["auth_token"];
            hmacInterceptor.secretKey =  config["secret_key"];
            $http.get(REST_PATH + '/users').then(function(response){
                demo.users = response.data.users;
            });
        });
    }]);
```  

An example of the headers that gets appended to the Angular HTTP requests:

```
X_HMAC_AUTHORIZATION:APIAuth 39e75f277f2edb7d9f547a8b3e21fa4c1c5fd5e213909e7c93a87539e12e60ea:l+f5GfID1ABZm6W7zAaf+5lb9N4=
X_HMAC_CONTENT_MD5:1B2M2Y8AsgTpgAmY7PhCfg==
X_HMAC_CONTENT_TYPE:
X_HMAC_DATE:Sun, 24 Jan 2016 09:00:06 GMT
```
The `spec/dummy` application actually has working version of the above and can be run by setting into the folder and calling `rails s`

# More information

For any more information please contact Bernie Lomax. Bernie!, Bernie!, Bernie!