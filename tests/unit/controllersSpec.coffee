
describe 'RootCtl', ->

    beforeEach ->
        module('kstep')

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

