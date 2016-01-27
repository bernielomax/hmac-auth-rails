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
