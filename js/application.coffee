
valueFn = (value) -> (-> value)
attr = (name) -> ((obj) -> obj[name])

app = angular.module 'kstep', ['ng', 'ngSanitize', 'ngCookies']
app.config ['$routeProvider', '$locationProvider', '$interpolateProvider', ($route, $location, $interpolate) ->
    $route
        .when '/',
            controller: 'BlogCtl'
            templateUrl: '/partials/list.html'

        .when '/tags',
            controller: 'TagsCtl'
            templateUrl: '/partials/tags.html'

        .when '/tag/:tag',
            controller: 'TagCtl'
            templateUrl: '/partials/tag.html'

        .when '/:year/:month/:day/:name.html',
            controller: 'PostCtl'
            templateUrl: '/partials/post.html'

        .when '/:year/:month/:day',
            controller: 'BlogCtl'
            templateUrl: '/partials/date.html'

        .when '/:year/:month',
            controller: 'BlogCtl'
            templateUrl: '/partials/date.html'

        .when '/:year',
            controller: 'BlogCtl'
            templateUrl: '/partials/date.html'

        .otherwise
            redirectTo: '/'

    $location.html5Mode false
    $location.hashPrefix '!'

    $interpolate.startSymbol '{:'
    $interpolate.endSymbol ':}'
]

app.filter 'strip_tags', ->
    tag_re = /<\/[a-zA-Z][a-zA-Z0-9]*>|<[a-zA-Z][a-zA-Z0-9]*(\s+[^>]*?)?\/?>/g
    (value) -> (value or '').toString().replace tag_re, ''

app.filter 'rot13', ->
    latin_re = /[a-zA-Z]/g
    decode = (c) -> String.fromCharCode(if (if c <= "Z" then 90 else 122) >= (c = c.charCodeAt(0) + 13) then c else c - 26)

    (value) ->
        (value or '').toString().replace latin_re, decode

app.filter 'asdate', ['$filter', ($filter) ->
    (value, pattern) -> $filter('date') new Date(value), pattern
]

app.filter 'lower', ->
    (value) -> (value or '').toString().toLowerCase()
app.filter 'upper', ->
    (value) -> (value or '').toString().toUpperCase()

app.factory 'locales', ['$http', '$rootScope', '$cookies', ($http, $root, $cookies) ->
    locales = (lang) ->
        $root.locale = $http.get('/i18n/' + lang + '.json').then (result) ->
            result.data.lang = lang
            $cookies.lang = lang
            result.data

    locales($cookies.lang or 'en')
    locales
]

app.directive 'ggSearch', ($jsload) -> {
    restrict: 'AE'
    template: '<gcse:search></gcse:search>'
    replace: yes
    compile: (elem, attrs) ->
        $jsload "//www.google.com/cse.js?cx=#{attrs.ggSearch or id}"
}

app.directive 'youtube', -> {
    restrict: 'AE'
    scope: yes
    replace: yes
    template: '<iframe ng-src="http://www.youtube.com/embed/{: id :}" width="{: width :}" height="{: height :}" frameborder="0" allowfullscreen></iframe>'
    compile: (elem, attrs) ->
        youtube_id = attrs.youtube or attrs.id
        width = parseInt(attrs.width, 10) or 560
        height = parseInt(attrs.height, 10) or 315

        (scope, elem, attrs) ->
            scope.id = youtube_id
            scope.width = width
            scope.height = height
}

app.directive 'totop', ['$window', ($window) -> {
    restrict: 'AC'
    compile: (elem, attrs) ->
        win = $ $window
        win.bind 'scroll', (ev) ->
            elem.css 'display', if win.scrollTop() > win.height() / 3 then '' else 'none'
        elem.css 'display', 'none'

        (scope, elem, attrs) ->
            elem.bind 'click', ->
                win.scrollTop(0)
                elem.css 'display', 'none'
}]

app.factory 'appcache', ['$window', '$rootScope', ($window, $root) ->
    appcache = $window.applicationCache or {
        fakeAppCache: yes
        UNCACHED            : 0,
        IDLE                : 1
        CHECKING            : 2
        DOWNLOADING         : 3
        UPDATEREADY         : 4
        OBSOLETE            : 5
        oncached            : null
        onchecking          : null
        ondownloading       : null
        onnoupdate          : null
        onobsolete          : null
        onupdateready       : null
        status              : 1
        addEventListener    : angular.noop
        dispatchEvent       : angular.noop
        removeEventListener : angular.noop
        swapCache           : angular.noop
        update              : angular.noop
    }

    callbacks = {}
    appcache.bind = (evname, callback) ->
        appcache.addEventListener evname, (callbacks[callback] = (ev) -> callback.call this, ev $root.$apply()), false

    appcache.unbind = (evname, callback) ->
        appcache.removeEventListener evname, callbacks[callback] or callback, false

    appcache
]

app.factory '$jsload', ['$timeout', '$q', '$document', '$rootScope', ($timeout, $q, $document, $root) ->
    cache = {}
    queue = {}

    (src, force) ->
        return queue[src] if queue[src]

        deferred = $q.defer()

        if !force and cache[src]
            deferred.resolve cache[src]
        else
            queue[src] = deferred.promise

            if cache[src]
                cache[src].parentNode.removeChild cache[src]
                delete cache[src]

            $timeout ->
                script = $document[0].createElement 'script'
                script.type = 'text/javascript'
                script.async = yes
                script.src = src

                script.onerror = (ev) ->
                    delete queue[src]
                    deferred.reject script
                    $root.$digest()

                script.onreadystatechange = script.onload = (ev) ->
                    delete queue[src]
                    if not ev.readyState or ev.readyState is 'loaded'
                        cache[src] = script
                        deferred.resolve script
                        $root.$digest()

                $document[0].getElementsByTagName('head')[0].appendChild script

        deferred.promise
]

app.factory 'Pager', -> (list, per_page, current_page) ->
    @total_pages = 0
    @pages = []

    @set_page = (new_page) ->
        total_pages = Math.ceil list.length / per_page
        if total_pages isnt @total_pages
            @total_pages = total_pages
            @pages = [1..total_pages]

        @page = if new_page < 1 then 1 else if new_page > total_pages then total_pages else new_page
        @slice = list.slice (@page - 1) * per_page, @page * per_page
        this

    @set_page(current_page)

app.factory 'Disqus', ['$window', '$jsload', ($window, $jsload) ->
    (shortname) ->
        $jsload('http://' + shortname + '.disqus.com/embed.js', true).then -> $window.DISQUS
]

app.directive 'disqus', ['$location', '$window', 'Disqus', '$parse', ($location, $window, disqus, $parse) ->
    id_seq = 0

    {
        restrict: 'ACE'
        terminal: yes
        compile: (elem, attrs) ->
            shortname = attrs.disqus or attrs.name
            id = attrs.id

            return if not shortname
            if not id
                elem.attr 'id', id = 'disqus_thread' + id_seq++

            (scope, elem, attrs) ->
                $window.disqus_identifier = $location.path()
                $window.disqus_url = $location.absUrl()
                $window.disqus_container_id = id
                $window.DISQUS = undefined
                elem.html ''
                disqus shortname
    }
]

app.config ['$httpProvider', ($http) ->
    $http.responseInterceptors.push ['$rootScope', '$q', ($root, $q) ->
        (promise) ->
            $root.$loading = yes
            promise.then ((response) ->
                $root.$loading = no
                response
            ), ((response) ->
                $root.$loading = no
                $q.reject(response)
            )

    ]
]

app.directive 'ngMeta', ['$parse', ($parse) -> {
    restrict: 'E'
    terminal: yes
    compile: (elem, attrs) ->
        return if not attrs.value and not attrs.update

        nameExpr = $parse attrs.name
        valueExpr = if attrs.value then $parse(attrs.value) else null
        updateExpr = if attrs.update then $parse(attrs.update) else null

        (scope, elem, attrs) ->
            nameExpr.assign scope, valueExpr scope if valueExpr?
            angular.extend (nameExpr scope), updateExpr scope if updateExpr?
}]

app.provider 'GA', ->
    _gaq = []

    {
        setAccount: (domain, account) ->
            [account, domain] = [domain, account] unless account

            _gaq.push ['_setAccount', account]
            _gaq.push ['_setDomainName', domain] if domain
            this

        $get: ['$window', '$location', '$jsload', '$timeout', ($window, $location, $jsload, $timeout) ->
            $window._gaq = _gaq

            prefix = if $location.protocol() is 'https' then 'https://ssl' else 'http://www'
            $jsload prefix + '.google-analytics.com/ga.js'
            (args...) -> $window._gaq.push args
        ]
    }

app.config ['GAProvider', (GA) -> GA.setAccount 'kstep.me', 'UA-23938138-1']

app.controller 'RootCtl', ['$scope', '$http', 'locales', 'appcache', '$window', 'GA', '$location', ($scope, $http, locales, appcache, $window, GA, $location) ->
    appcache.bind 'updateready', ->
        $scope.update_available = true
        appcache.swapCache()

    $scope.page = {}
    $scope.locales = locales

    $scope.reload_site = -> $window.location.reload()

    $scope.social_accounts = [
        {
            url: "https://twitter.com/kstepme"
            icon: "http://twitter.com/favicon.ico"
            name: "Twitter"
        }
        {
            url: "http://www.linkedin.com/pub/konstantin-stepanov/54/47/450"
            icon: "http://www.linkedin.com/favicon.ico"
            name: "LinkedIn"
        }
        {
            url: "http://kstepme.moikrug.ru/"
            icon: "http://moikrug.ru/favicon.ico"
            name: "Мой Круг"
        }
        {
            url: "http://welinux.ru/user/kstep/"
            icon: "http://welinux.ru/favicon.ico"
            name: "WeLinux"
        }
        {
            url: "https://github.com/kstep"
            icon: "http://github.com/favicon.ico"
            name: "Github"
        }
        {
            url: "http://www.ohloh.net/accounts/kstep"
            icon: "http://www.ohloh.net/favicon.ico"
            name: "Ohloh"
        }
        {
            url: "http://search.cpan.org/~kstepme/"
            icon: "http://search.cpan.org/favicon.ico"
            name: "CPAN"
        }

        $scope.$on '$routeChangeSuccess', ->
            GA '_trackPageview', $location.path()
    ]
]

app.controller 'PostCtl', ['$scope', '$routeParams', ($scope, $params) ->
    angular.extend $scope.page,
        url: "/#{$params.year}/#{$params.month}/#{$params.day}/#{$params.name}.html"
        group: 'blog'
]

app.controller 'BlogCtl', ['$scope', '$routeParams', '$http', 'Pager', ($scope, $params, $http, Pager) ->
    $scope.$watch 'locale.index_title', (locale_title) -> $scope.page.title = locale_title

    angular.extend $scope.page,
        title: $scope.locale.index_title
        url: '/'
        group: 'blog'

    date = "#{$params.year or ''}-#{$params.month or ''}-#{$params.day or ''}".replace /-+$/g, ''
    $scope.date =
        year: $params.year
        month: $params.month
        day: $params.day

    $scope.pager = $http.get('/data/list.json').then (result) ->
        posts = if date then (p for p in result.data when p.date.indexOf(date) isnt -1) else result.data
        new Pager posts, 40, 1
]

app.controller 'TagCtl', ['$scope', '$http', '$routeParams', ($scope, $http, $params) ->
    $scope.$watch 'locale.tag', (locale_title) -> $scope.page.title = locale_title + ' — ' + $params.tag

    angular.extend $scope.page,
        url: '/tag/' + $params.tag,
        group: 'tags'

    $http.get('/data/tags.json').success (tags) ->
        $scope.tag = tags[$params.tag]
        $scope.tag.name = $params.tag
]

app.controller 'TagsCtl', ['$scope', '$http', ($scope, $http) ->
    $scope.$watch 'locale.tag_cloud', (locale_title) -> $scope.page.title = locale_title

    angular.extend $scope.page,
        url: '/tags'
        group: 'tags'

    $http.get('/data/tags.json').success (tags) ->
        min = Infinity
        max = -Infinity

        for name, tag of tags
            min = tag.size if tag.size < min
            max = tag.size if tag.size > max

        delta = max - min
        for name, tag of tags
            tag.size = (tag.size - min) / delta

        $scope.tags = tags
]
