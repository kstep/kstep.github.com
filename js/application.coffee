
@valueFn = (value) -> (-> value)
@attr = (name) -> ((obj) -> obj[name])

app = angular.module 'kstep', ['ng', 'ngSanitize', 'ngCookies']

app.filters = (obj) ->
    for name, filter of obj
        @filter(name, filter)
    this

app
.provider
    GA: ->
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

.config([
    '$routeProvider'
    '$locationProvider'
    '$interpolateProvider'
    '$httpProvider'
    'GAProvider'
    ($route, $location, $interpolate, $http, GA) ->
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

        GA.setAccount 'kstep.me', 'UA-23938138-1'])

.filters
    lpad: ->
        (value, num, pad) ->
            value = (value || '').toString()
            pad = pad or '0'
            if value.length < num
                value = (new Array(num - value.length + 1).join pad) + value
            value
    rpad: ->
        (value, num, pad) ->
            value = (value || '').toString()
            pad = pad or '0'
            if value.length < num
                value = value + (new Array(num - value.length + 1).join pad)
            value

    strip_tags: ->
        tag_re = /<\/[a-zA-Z][a-zA-Z0-9]*>|<[a-zA-Z][a-zA-Z0-9]*(\s+[^>]*?)?\/?>/g
        (value) -> (value or '').toString().replace tag_re, ''

    rot13: ->
        latin_re = /[a-zA-Z]/g
        decode = (c) -> String.fromCharCode(if (if c <= "Z" then 90 else 122) >= (c = c.charCodeAt(0) + 13) then c else c - 26)

        (value) -> (value or '').toString().replace latin_re, decode

    asdate: ['$filter', ($filter) ->
        (value, pattern) -> $filter('date') new Date(value), pattern
    ]

    lower: -> (value) -> (value or '').toString().toLowerCase()
    upper: -> (value) -> (value or '').toString().toUpperCase()
    caps: -> (value) -> (value or '').toString().replace /^./, (c) -> c.toUpperCase()
    allcaps: -> (value) -> (value or '').toString().replace /\b./g, (c) -> c.toUpperCase()

.directive
    ggSearch: ['$jsload', ($jsload) ->
        restrict: 'AE'
        template: '<gcse:search></gcse:search>'
        replace: yes
        compile: (elem, attrs) -> $jsload "//www.google.com/cse.js?cx=#{attrs.ggSearch or id}"
    ]

    youtube: ->
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

    totop: ['$window', ($window) ->
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
    ]

    disqus: ['$location', '$window', 'Disqus', '$parse', ($location, $window, disqus, $parse) ->
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
    ngMeta: ['$parse', ($parse) ->
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
    ]
    calendar: ->
        restrict: 'CEA'
        controller: 'CalendarCtl'

.factory
    appcache: ['$window', '$rootScope', ($window, $root) ->
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

    $jsload: ['$timeout', '$q', '$document', '$rootScope', ($timeout, $q, $document, $root) ->
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

    Pager: -> (list, per_page, current_page) ->
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

    Disqus: ['$window', '$jsload', ($window, $jsload) ->
        (shortname) ->
            $jsload('http://' + shortname + '.disqus.com/embed.js', true).then -> $window.DISQUS
    ]

    locales: ['$http', '$rootScope', '$cookies', ($http, $root, $cookies) ->
        locales = (lang) ->
            $root.locale = $http.get('/i18n/' + lang + '.json').then (result) ->
                result.data.lang = lang
                $cookies.lang = lang
                result.data

        locales($cookies.lang or 'en')
        locales
    ]

.controller
    RootCtl: ['$scope', '$http', 'locales', 'appcache', '$window', 'GA', '$location', ($scope, $http, locales, appcache, $window, GA, $location) ->
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

    PostCtl: ['$scope', '$routeParams', ($scope, $params) ->
        angular.extend $scope.page,
            url: "/#{$params.year}/#{$params.month}/#{$params.day}/#{$params.name}.html"
            group: 'blog'
    ]

    BlogCtl: ['$scope', '$routeParams', '$http', 'Pager', ($scope, $params, $http, Pager) ->
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

    TagCtl: ['$scope', '$http', '$routeParams', ($scope, $http, $params) ->
        $scope.$watch 'locale.tag', (locale_title) -> $scope.page.title = locale_title + ' — ' + $params.tag

        angular.extend $scope.page,
            url: '/tag/' + $params.tag,
            group: 'tags'

        $http.get('/data/tags.json').success (tags) ->
            $scope.tag = tags[$params.tag]
            $scope.tag.name = $params.tag
    ]

    TagsCtl: ['$scope', '$http', ($scope, $http) ->
        $scope.$watch 'locale.tags', (locale_title) -> $scope.page.title = locale_title

        angular.extend $scope.page,
            url: '/tags'
            group: 'tags'

        $http.get('/data/tags.json').success (tags) ->
            min = Infinity
            max = -Infinity
            tags_list = []

            for name, tag of tags
                min = tag.size if tag.size < min
                max = tag.size if tag.size > max
                tag.name = name
                tags_list.push tag

            delta = max - min
            for tag in tags_list
                tag.weight = (tag.size - min) / delta

            $scope.tags = tags_list
    ]
    CalendarCtl: ['$scope', '$element', '$attrs', ($scope, $element, $attrs) ->
        inner_date = (date) ->
            #return date if date is $scope.date

            date = unless date? then new Date \
                else if angular.isDate date then date \
                else if angular.isObject date then \
                     new Date date.year, date.month - 1, date.day \
                else new Date date

            year: date.getFullYear()
            month: date.getMonth() + 1
            day: date.getDate()
            dow: date.getDay()

        today = inner_date new Date

        is_leap = (year) -> (year % 4 == 0) and (year % 100 != 0 or year % 400 == 0)

        weekdays = [
            'sun'
            'mon'
            'tue'
            'wed'
            'thu'
            'fri'
            'sat'
            'sun'
        ]

        months = [
            'december'
            'january'
            'february'
            'march'
            'april'
            'may'
            'june'
            'july'
            'august'
            'september'
            'october'
            'november'
            'december'
        ]

        # Currently selected date
        $scope.date = inner_date ($attrs.calendar or $attrs.date or null)

        # Today date
        $scope.today = today

        # List of days for enumeration
        $scope.days = [1..31]

        # Weekday for given day in current month
        first_dow = 1
        $scope.weekday = (day) -> weekdays[(first_dow + day - 1) % 7]

        $scope.is_current = (day) -> $scope.date.day == day  # Is the day is current one?
        $scope.are_equal = (date1, date2) ->  # Are these two dates equal?
            date1.year == date2.year and date1.month == date2.month and date1.day == date2.day

        $scope.$watch 'date', ((date) ->
            $scope.date = date = inner_date date  # Normalize date

            $scope.leap_year = is_leap(date.year)  # Leap year flag

            # Is today for day in current month
            $scope.is_today = if date.year == today.year and date.month == today.month \
                then ((day) -> day == date.day) else ((day) -> false)

            $scope.month = months[date.month]  # Current month name

            # Calculate first month day's weekday
            first_dow = (8 + date.dow - date.day % 7) % 7
        ), on
    ]
