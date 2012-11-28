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

        beforeEach inject ($controller, $httpBackend) ->

            scope.locale = {}
            scope.page = {}

            $httpBackend.expectGET('/data/list.json').respond [{"title": "Post", "date": "2012-10-12", "tags": []}]
            controller = $controller('BlogCtl', {$scope: scope, $routeParams: {}})

            $httpBackend.flush()

        it 'should load posts list', inject ($httpBackend, Pager) ->
            scope.pager.then (
                (pager) -> expect(pager.slice).toEqual ["title": "Post", "date": "2012-10-12", "tags": []]
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
            expect(scope.tags).toEqual {"tag1": {"size": 0, "posts": []}, "tag2": {"size": 1, "posts": []}}

