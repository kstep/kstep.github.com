
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
    calendar: ['$parse', '$interpolate', ($parse, $interpolate) ->
        restrict: 'CAE'
        scope: yes
        replace: yes
        # I unroll loop here for better performance, all calendar logic is in CSS,
        # I really need to set correct classes only.
        template: '''
            <div ng-class="[month, leap_year]">
                <div class="header">
                    <nobr class="clearfix"><a ng-click="prev_month()">← {: months[(date.month - 1) % 12] | caps :}</a> <strong>{: month | caps :} {: date.year :}</strong> <a ng-click="next_month()">{: months[(date.month + 1) % 12] | caps :} →</a></nobr>
                    <span class="mon">Mon</span>
                    <span class="tue">Tue</span>
                    <span class="wed">Wed</span>
                    <span class="thu">Thu</span>
                    <span class="fri">Fri</span>
                    <span class="sat">Sat</span>
                    <span class="sun">Sun</span>
                </div>
                <a ng-href="{: href(1) :}" class="day-1" ng-class="[weekday(1), is_today(1)]">1</a>
                <a ng-href="{: href(2) :}" class="day-2" ng-class="[weekday(2), is_today(2)]">2</a>
                <a ng-href="{: href(3) :}" class="day-3" ng-class="[weekday(3), is_today(3)]">3</a>
                <a ng-href="{: href(4) :}" class="day-4" ng-class="[weekday(4), is_today(4)]">4</a>
                <a ng-href="{: href(5) :}" class="day-5" ng-class="[weekday(5), is_today(5)]">5</a>
                <a ng-href="{: href(6) :}" class="day-6" ng-class="[weekday(6), is_today(6)]">6</a>
                <a ng-href="{: href(7) :}" class="day-7" ng-class="[weekday(7), is_today(7)]">7</a>
                <a ng-href="{: href(8) :}" class="day-8" ng-class="[weekday(8), is_today(8)]">8</a>
                <a ng-href="{: href(9) :}" class="day-9" ng-class="[weekday(9), is_today(9)]">9</a>
                <a ng-href="{: href(10) :}" class="day-10" ng-class="[weekday(10), is_today(10)]">10</a>
                <a ng-href="{: href(11) :}" class="day-11" ng-class="[weekday(11), is_today(11)]">11</a>
                <a ng-href="{: href(12) :}" class="day-12" ng-class="[weekday(12), is_today(12)]">12</a>
                <a ng-href="{: href(13) :}" class="day-13" ng-class="[weekday(13), is_today(13)]">13</a>
                <a ng-href="{: href(14) :}" class="day-14" ng-class="[weekday(14), is_today(14)]">14</a>
                <a ng-href="{: href(15) :}" class="day-15" ng-class="[weekday(15), is_today(15)]">15</a>
                <a ng-href="{: href(16) :}" class="day-16" ng-class="[weekday(16), is_today(16)]">16</a>
                <a ng-href="{: href(17) :}" class="day-17" ng-class="[weekday(17), is_today(17)]">17</a>
                <a ng-href="{: href(18) :}" class="day-18" ng-class="[weekday(18), is_today(18)]">18</a>
                <a ng-href="{: href(19) :}" class="day-19" ng-class="[weekday(19), is_today(19)]">20</a>
                <a ng-href="{: href(20) :}" class="day-20" ng-class="[weekday(20), is_today(20)]">20</a>
                <a ng-href="{: href(21) :}" class="day-21" ng-class="[weekday(21), is_today(21)]">21</a>
                <a ng-href="{: href(22) :}" class="day-22" ng-class="[weekday(22), is_today(22)]">22</a>
                <a ng-href="{: href(23) :}" class="day-23" ng-class="[weekday(23), is_today(23)]">23</a>
                <a ng-href="{: href(24) :}" class="day-24" ng-class="[weekday(24), is_today(24)]">24</a>
                <a ng-href="{: href(25) :}" class="day-25" ng-class="[weekday(25), is_today(25)]">25</a>
                <a ng-href="{: href(26) :}" class="day-26" ng-class="[weekday(26), is_today(26)]">26</a>
                <a ng-href="{: href(27) :}" class="day-27" ng-class="[weekday(27), is_today(27)]">27</a>
                <a ng-href="{: href(28) :}" class="day-28" ng-class="[weekday(28), is_today(28)]">28</a>
                <a ng-href="{: href(29) :}" class="day-29" ng-class="[weekday(29), is_today(29)]">29</a>
                <a ng-href="{: href(30) :}" class="day-30" ng-class="[weekday(30), is_today(30)]">30</a>
                <a ng-href="{: href(31) :}" class="day-31" ng-class="[weekday(31), is_today(31)]">31</a>
            </div>'''
        compile: (element, attrs) ->
            inner_date = (date) ->
                year: date.getFullYear()
                month: date.getMonth() + 1
                day: date.getDate()
                dow: date.getDay()

            now = inner_date new Date
            today = now

            nowExpr = (scope) -> now
            nowExpr.assign = (scope, value) -> now = value

            dateExpr = if attrs.date then $parse attrs.date else nowExpr
            hrefExpr = $interpolate attrs.href

            (scope, element, attrs) ->
                first_dow = 1
                date = {}

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

                is_leap = (year) -> (year % 4 == 0) and (year % 100 != 0 or year % 400 == 0)

                scope.href = (day) -> hrefExpr { day: day, date: date }
                scope.weekday = (day) -> weekdays[(first_dow + day - 1) % 7]

                scope.months = months
                scope.prev_month = -> (dateExpr.assign or angular.noop) scope, { year: date.year, month: date.month - 1, day: date.day }
                scope.next_month = -> (dateExpr.assign or angular.noop) scope, { year: date.year, month: date.month + 1, day: date.day }
                scope.set_date = (date) -> (dateExpr.assign or angular.noop) scope, date
                scope.today = today

                scope.$watch dateExpr, (newdate) ->
                    newdate = if angular.isDate newdate then newdate \
                        else if angular.isObject newdate then \
                            new Date newdate.year, newdate.month - 1, newdate.day \
                        else new Date newdate

                    date = inner_date newdate

                    scope.is_today = if date.year == today.year and date.month == today.month \
                        then ((day) -> if day == date.day then 'today' else '') \
                        else ((day) -> false)

                    first_dow = (8 + date.dow - date.day % 7) % 7
                    scope.date = date
                    scope.month = months[date.month]
                    scope.leap_year = if is_leap(date.year) then 'leap-year' else ''
    ]

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
