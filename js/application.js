/*jslint browser: true*/
'use strict';

function valueFn(value) {
    return function () { return value; };
}
function attr(name) {
    return function (obj) { return obj[name]; };
}

(function (angular, $, _, undefined) {
angular.module('kstep', ['ng', 'ngSanitize', 'ngCookies'])
    .config(['$routeProvider', '$locationProvider', '$interpolateProvider',
    function ($route, $location, $interpolate) {
        $route
        .when('/', { controller: 'BlogCtl', templateUrl: '/partials/list.html' })
        .when('/tags', { controller: 'TagsCtl', templateUrl: '/partials/tags.html' })
        .when('/tag/:tag', { controller: 'TagCtl', templateUrl: '/partials/tag.html' })

        .when('/:year/:month/:day/:name.html', { controller: 'PostCtl', templateUrl: '/partials/post.html' })

        .when('/:year/:month/:day', { controller: 'BlogCtl', templateUrl: '/partials/date.html' })
        .when('/:year/:month', { controller: 'BlogCtl', templateUrl: '/partials/date.html' })
        .when('/:year', { controller: 'BlogCtl', templateUrl: '/partials/date.html' })

        .otherwise({ redirectTo: '/' });

        $location.html5Mode(false).hashPrefix('!');

        $interpolate.startSymbol('{:').endSymbol(':}');
    }])

    .filter('strip_tags', [function () {
        var tag_re = /<\/[a-zA-Z][a-zA-Z0-9]*>|<[a-zA-Z][a-zA-Z0-9]*(\s+[^>]*?)?\/?>/g;
        return function (value) {
            return (value || '').toString().replace(tag_re, '');
        };
    }])
    .filter('rot13', [function () {
        var latin_re = /[a-zA-Z]/g,
            decode = function (c) {
                return String.fromCharCode((c <= "Z"? 90: 122) >= (c = c.charCodeAt(0) + 13)? c: c - 26);
            };

        return function (value) {
            return (value || '').toString().replace(latin_re, decode);
        };
    }])
    .filter('asdate', ['$filter', function ($filter) {
        return function (value, pattern) {
            return $filter('date')(new Date(value), pattern);
        };
    }])
    .filter('lower', [function () {
        return function (value) {
            return (value || '').toString().toLowerCase();
        };
    }])
    .filter('upper', [function () {
        return function (value) {
            return (value || '').toString().toUpperCase();
        };
    }])

    .factory('locales', ['$http', '$rootScope', '$cookies', function ($http, $root, $cookies) {
        var locales = function (lang) {
            $root.locale = $http.get('/i18n/' + lang + '.json').then(
                function (result) {
                    result.data.lang = lang;
                    $cookies.lang = lang;
                    return result.data;
                }
            );
            return $root.locale;
        };
        locales($cookies.lang || 'en');
        return locales;
    }])

    .directive('youtube', [function () {
        return {
            restrict: 'AE',
            scope: true,
            replace: true,
            template: '<iframe ng-src="http://www.youtube.com/embed/{: id :}" width="{: width :}" height="{: height :}" frameborder="0" allowfullscreen></iframe>',
            compile: function (elem, attrs) {
                var youtube_id = attrs.youtube || attrs.id,
                    width = parseInt(attrs.width, 10) || 560,
                    height = parseInt(attrs.height, 10) || 315;

                return function (scope, elem, attrs) {
                    scope.id = youtube_id;
                    scope.width = width;
                    scope.height = height;
                };
            }
        };
    }])

    .directive('totop', ['$window', function ($window) {
        return {
            restrict: 'AC',
            compile: function (elem, attrs) {
                var win = $($window);

                win.bind('scroll', function (ev) {
                    elem.css('display', win.scrollTop() > win.height() / 3? '': 'none');
                });

                elem.css('display', 'none');

                return function (scope, elem, attrs) {
                    elem.bind('click', function () {
                        win.scrollTop(0);
                        elem.css('display', 'none');
                    });
                };
            }
        };
    }])

    .factory('appcache', ['$window', '$rootScope', function ($window, $root) {
        var appcache = $window.applicationCache || {  // Return stub if no applicationCache is available
            fakeAppCache        : true,
            UNCACHED            : 0,
            IDLE                : 1,
            CHECKING            : 2,
            DOWNLOADING         : 3,
            UPDATEREADY         : 4,
            OBSOLETE            : 5,
            oncached            : null,
            onchecking          : null,
            ondownloading       : null,
            onnoupdate          : null,
            onobsolete          : null,
            onupdateready       : null,
            status              : 1,
            addEventListener    : angular.noop,
            dispatchEvent       : angular.noop,
            removeEventListener : angular.noop,
            swapCache           : angular.noop,
            update              : angular.noop
        };

        // Normalized shortcuts
        var callbacks = {};
        appcache.bind = function (evname, callback) {
            appcache.addEventListener(evname, callbacks[callback] = function (ev) {
                callback.call(this, ev);
                $root.$apply();
            }, false);
        };
        appcache.unbind = function (evname, callback) {
            appcache.removeEventListener(evname, callbacks[callback] || callback, false);
        };

        return appcache;
    }])

    .factory('$jsload', ['$timeout', '$q', '$document', '$rootScope', function ($timeout, $q, $document, $root) {
        var cache = {},
            queue = {};

        return function (src, force) {
            if (queue[src]) {
                return queue[src];
            }

            var deferred = $q.defer();

            if (!force && cache[src]) {
                deferred.resolve(cache[src]);

            } else {
                queue[src] = deferred.promise;

                if (cache[src]) {
                    cache[src].parentNode.removeChild(cache[src]);
                    delete cache[src];
                }

                $timeout(function () {
                    var script = $document[0].createElement('script');
                    script.type = 'text/javascript';
                    script.async = true;
                    script.src = src;

                    script.onerror = function (ev) {
                        delete queue[src];
                        deferred.reject(script);
                        $root.$digest();
                    };
                    script.onreadystatechange = script.onload = function (ev) {
                        delete queue[src];
                        if (!ev.readyState || ev.readyState === 'loaded') {
                            cache[src] = script;
                            deferred.resolve(script);
                            $root.$digest();
                        }
                    };

                    $document[0].getElementsByTagName('head')[0].appendChild(script);
                });
            }

            return deferred.promise;
        };
    }])

    .factory('Pager', [function () {
        return function (list, items_per_page, current_page) {

            var length = list.length,
                total_pages = Math.ceil(length / items_per_page);

            this.total_pages = 0;
            this.pages = [];

            this.set_page = function (new_page) {
                var total_pages = Math.ceil(list.length / items_per_page);
                if (total_pages !== this.total_pages) {
                    this.total_pages = total_pages;
                    this.pages = [];
                    var p;
                    for (p = 0; p < total_pages; p++) {
                        this.pages.push(p + 1);
                    }
                }

                if (new_page < 1) {
                    new_page = 1;
                } else if (new_page > total_pages) {
                    new_page = total_pages;
                }

                this.page = new_page;

                var from = (new_page - 1) * items_per_page,
                    to = from + items_per_page;
                this.slice = list.slice(from, to);
            };

            this.set_page(current_page);
        };
    }])

    .factory('Disqus', ['$window', '$jsload', function ($window, $jsload) {
        return function (shortname) {
            return $jsload('http://' + shortname + '.disqus.com/embed.js', true).then(function () {
                return $window.DISQUS;
            });
        };
    }])

    .directive('disqus', ['$location', '$window', 'Disqus', '$parse', function ($location, $window, disqus, $parse) {
        var id_seq = 0;

        return {
            restrict: 'ACE',
            terminal: true,
            compile: function (elem, attrs) {
                var shortname = attrs.disqus || attrs.name,
                    id = attrs.id;

                if (!shortname) { return; }
                if (!id) {
                    id = 'disqus_thread' + (id_seq++);
                    elem.attr('id', id);
                }

                return function (scope, elem, attrs) {
                    $window.disqus_identifier = $location.path();
                    $window.disqus_url = $location.absUrl();
                    $window.disqus_container_id = id;
                    $window.DISQUS = undefined;
                    elem.html('');

                    disqus(shortname);
                };
            }
        };
    }])

    .config(['$httpProvider', function ($http) {
        $http.responseInterceptors.push(['$rootScope', '$q', function ($rootScope, $q) {
            return function (promise) {
                $rootScope.$loading = true;

                return promise.then(
                function (response) {
                    $rootScope.$loading = false;
                    return response;
                },
                function (response) {
                    $rootScope.$loading = false;
                    return $q.reject(response);
                });
            };
        }]);
    }])

    .controller('RootCtl', ['$scope', '$http', 'locales', 'appcache', '$window', function ($scope, $http, locales, appcache, $window) {
        appcache.bind('updateready', function () {
            $scope.update_available = true;
            appcache.swapCache();
        });

        $scope.page = {};
        $scope.locales = locales;

        $scope.reload_site = function () {
            $window.location.reload();
        };

        $scope.social_accounts = [
            { url: "https://twitter.com/kstepme", icon: "http://twitter.com/favicon.ico", name: "Twitter" },
            { url: "http://www.linkedin.com/pub/konstantin-stepanov/54/47/450", icon: "http://www.linkedin.com/favicon.ico", name: "LinkedIn" },
            { url: "http://kstepme.moikrug.ru/", icon: "http://moikrug.ru/favicon.ico", name: "Мой Круг" },
            { url: "http://welinux.ru/user/kstep/", icon: "http://welinux.ru/favicon.ico", name: "WeLinux" },
            { url: "https://github.com/kstep", icon: "http://github.com/favicon.ico", name: "Github" },
            { url: "http://www.ohloh.net/accounts/kstep", icon: "http://www.ohloh.net/favicon.ico", name: "Ohloh" },
            { url: "http://search.cpan.org/~kstepme/", icon: "http://search.cpan.org/favicon.ico", name: "CPAN" }
        ];
    }])

    .directive('ngMeta', ['$parse', function ($parse) {
        return {
            restrict: 'E',
            terminal: true,
            compile: function (elem, attrs) {
                if (!attrs.value && !attrs.update) {
                    return;
                }

                var nameExpr = $parse(attrs.name),
                    valueExpr = attrs.value? $parse(attrs.value): null,
                    updateExpr = attrs.update? $parse(attrs.update): null;

                return function (scope, elem, attrs) {
                    if (valueExpr) {
                        nameExpr.assign(scope, valueExpr(scope));
                    }
                    if (updateExpr) {
                        angular.extend(nameExpr(scope), updateExpr(scope));
                    }
                };
            }
        };
    }])

    .controller('PostCtl', ['$scope', '$routeParams', function ($scope, $params) {
        angular.extend($scope.page, {
            url:   '/' + $params.year + '/' + $params.month + '/' + $params.day + '/' + $params.name + '.html',
            group: 'blog'
        });
    }])
    .controller('BlogCtl', ['$scope', '$routeParams', '$http', 'Pager', function ($scope, $params, $http, Pager) {
        $scope.$watch('locale.index_title', function (locale_title) {
            $scope.page.title = locale_title;
        });

        angular.extend($scope.page, {
            title: $scope.locale.index_title,
            url:   '/',
            group: 'blog'
        });

        var date = (($params.year || '') + "-" + ($params.month || '') + "-" + ($params.day || '')).replace(/-+$/g, '');

        $scope.date = {
            year: $params.year,
            month: $params.month,
            day: $params.day
        };

        $scope.pager = $http.get('/data/list.json').then(
            function (result) {
                var posts = result.data;
                if (date) {
                    posts = _.filter(posts,
                        function (post) { return post.date.indexOf(date) !== -1; }
                    );
                }

                return new Pager(posts, 40, 1);
            }
        );
    }])
    .controller('TagCtl', ['$scope', '$http', '$routeParams', function ($scope, $http, $params) {
        $scope.$watch('locale.tag', function (locale_title) {
            $scope.page.title = locale_title + ' — ' + $params.tag;
        });

        angular.extend($scope.page, {
            url:   '/tag/' + $params.tag,
            group: 'tags'
        });

        $http.get('/data/tags.json').then(function (result) {
            $scope.tag = result.data[$params.tag];
            $scope.tag.name = $params.tag;
        });
    }])
    .controller('TagsCtl', ['$scope', '$http', function ($scope, $http) {
        $scope.$watch('locale.tag_cloud', function (locale_title) {
            $scope.page.title = locale_title;
        });

        angular.extend($scope.page, {
            url:   '/tags',
            group: 'tags'
        });

        $http.get('/data/tags.json').then(function (result) {
            var tags = result.data,
                sizes = _.pluck(tags, 'size'),
                min_size = _.min(sizes),
                delta = _.max(sizes) - min_size;

            _.each(tags, function (tag) {
                tag.size = (tag.size - min_size) / delta;
            });

            $scope.tags = tags;
        });
    }])
;
}(window.angular, window.jQuery, window._));

