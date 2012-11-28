
describe 'RootCtl', ->

    beforeEach ->
        module 'kstep'

    scope = undefined
    controller = undefined

    beforeEach inject ($rootScope, $controller, $httpBackend) ->
        $httpBackend.whenGET('/i18n/en.json').respond 200, '{"title": "Test"}', {'Content-type': 'application/json'}

        scope = $rootScope.$new()
        controller = $controller('RootCtl', { '$scope': scope })

        $httpBackend.flush()
        $rootScope.$apply()

    it 'should initialize social account list', ->
        expect(scope.social_accounts).toEqual jasmine.any(Array)
        expect(scope.social_accounts[0]).toBeDefined()

    it 'should initialize page object', ->
        expect(scope.page).toEqual jasmine.any(Object)

    it 'should setup locale', ->
        expect(scope.locale).toBeDefined()

describe 'PostCtl', ->

    beforeEach ->
        module 'kstep'

    scope = undefined

    beforeEach inject ($rootScope) ->
        scope = $rootScope.$new()

    it 'should setup post location', inject ($controller) ->
        scope.page = {}
        controller = $controller('PostCtl', { '$scope': scope, '$routeParams': { 'year': 2012, 'month': 10, 'day': 12, 'name': 'post' } })

        expect(scope.page.url).toEqual '/2012/10/12/post.html'
        expect(scope.page.group).toEqual 'blog'

describe 'BlogCtl', ->

    beforeEach ->
        module 'kstep'

    scope = undefined

    beforeEach inject ($rootScope) ->
        scope = $rootScope.$new()

    it 'should load posts list', inject ($controller, $httpBackend) ->
        $httpBackend.whenGET('/data/list.json').respond 200, '[{"title": "Post", "date": "2012-10-12", "tags":[]}]', {'Content-type': 'application/json'}
        scope.locale = {}
        scope.page = {}

        controller = $controller('BlogCtl', { '$scope': scope, '$routeParams': {} })

        expect(scope.pager).toBeDefined()

