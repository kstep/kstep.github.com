describe 'Controllers', ->

    scope = undefined

    beforeEach ->
        module 'kstep'

    beforeEach inject ($rootScope) ->
        scope = $rootScope.$new()

    afterEach inject ($httpBackend) ->
        $httpBackend.verifyNoOutstandingExpectation()
        $httpBackend.verifyNoOutstandingRequest()

    describe 'RootCtl', ->

        controller = undefined

        beforeEach inject ($controller, $httpBackend) ->
            $httpBackend.whenGET('/i18n/en.json').respond {"title": "Test"}

            controller = $controller('RootCtl', {$scope: scope})

            $httpBackend.flush()

        it 'should initialize social account list', ->
            expect(scope.social_accounts).toEqual jasmine.any(Array)
            expect(scope.social_accounts[0]).toEqual jasmine.any(Object)
            expect(scope.social_accounts[0].url).toBeTruthy()
            expect(scope.social_accounts[0].icon).toBeTruthy()
            expect(scope.social_accounts[0].name).toBeTruthy()

        it 'should initialize page object', ->
            expect(scope.page).toEqual jasmine.any(Object)

        it 'should setup locale', ->
            expect(scope.locale).toBeDefined()

    describe 'PostCtl', ->

        it 'should setup post location', inject ($controller) ->
            scope.page = {}
            controller = $controller('PostCtl', {$scope: scope, $routeParams: {'year': 2012, 'month': 10, 'day': 12, 'name': 'post'}})

            expect(scope.page.url).toEqual '/2012/10/12/post.html'
            expect(scope.page.group).toEqual 'blog'

    describe 'BlogCtl', ->

        controller = undefined
        posts = [
            {"title": "Post1", "date": "2012-10-12", "tags": []}
            {"title": "Post2", "date": "2010-10-12", "tags": []}
            {"title": "Post3", "date": "2011-10-12", "tags": []}
            {"title": "Post4", "date": "2011-10-10", "tags": []}
            {"title": "Post4", "date": "2011-01-05", "tags": []}
            {"title": "Post5", "date": "2010-09-12", "tags": []}
        ]

        beforeEach inject ($httpBackend) ->
            scope.locale = {}
            scope.page = {}
            $httpBackend.expectGET('/data/list.json')
            $httpBackend.whenGET('/data/list.json').respond posts

        it 'should load posts list', inject ($controller, $httpBackend) ->
            controller = $controller 'BlogCtl', {$scope: scope, $routeParams: {}}
            $httpBackend.flush()

            scope.pager.then (
                (pager) -> expect(pager.slice).toEqual posts
            ), (
                (result) -> expect(result.status).toBe 200
            )

        expectations = [
            { params: { year: 2012 }, dates: ['2012-10-12'] }
            { params: { year: 2010 }, dates: ['2010-10-12', '2010-09-12'] }
            { params: { year: 2011, month: 10 }, dates: ['2011-10-12', '2011-10-10'] }
            { params: { year: 2011, month: 10 }, dates: ['2011-10-12', '2011-10-10'] }
            { params: { year: 2010, month: 9, day: 12 }, dates: ['2010-09-12'] }
        ]
        pluck = (attr) -> (list) -> (obj[attr] for obj in list)

        for expectation in expectations
            it "should filter posts by date: #{expectation.params.year}-#{expectation.params.month || '?'}-#{expectation.params.day || '?'}", inject ($controller, $httpBackend) ->
                controller = $controller 'BlogCtl', {$scope: scope, $routeParams: expectation.params}
                $httpBackend.flush()

                scope.pager.then (
                    (pager) ->
                        expect(pager.slice.length).toEqual expectation.dates.length
                        expect(pluck('date')(pager.slice)).toEqual expectations.dates
                ), (
                    (result) -> expect(result.status).toBe 200
                )

    describe 'TagCtl', ->

        controller = undefined

        beforeEach inject ($controller, $httpBackend) ->

            scope.page = {}
            scope.locale = {}

            $httpBackend.expectGET('/data/tags.json').respond {"tag1": {"size": 1, "posts": []}, "tag2": {"size": 2, "posts": []}}

            controller = $controller 'TagCtl', {$scope: scope, $routeParams: {tag: "tag1"}}

            $httpBackend.flush()

        it 'should update URL', ->
            expect(scope.page.url).toEqual '/tag/tag1'

        it 'should set current tag', ->
            expect(scope.tag).toEqual {"name": "tag1", "size": 1, "posts": []}

    describe 'TagsCtl', ->

        controller = undefined

        beforeEach inject ($controller, $httpBackend) ->

            scope.page = {}
            scope.locale = {}

            $httpBackend.expectGET('/data/tags.json').respond {"tag1": {"size": 1, "posts": []}, "tag2": {"size": 2, "posts": []}}

            controller = $controller 'TagsCtl', {$scope: scope}

            $httpBackend.flush()

        it 'should update URL', ->
            expect(scope.page.url).toEqual '/tags'

        it 'should load tags and calculate their weights', ->
            expect(scope.tags).toEqual [
                { name: "tag1", size: 1, weight: 0, posts: [] }
                { name: "tag2", size: 2, weight: 1, posts: [] }
            ]

