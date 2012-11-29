describe 'Directives', ->
    beforeEach ->
        module 'kstep'

    scope = undefined
    beforeEach inject ($rootScope) ->
        scope = $rootScope.$new()

    describe 'totop', ->
        element = undefined

        beforeEach inject ($compile) ->
            element = $compile('<totop></totop>')(scope)

        it 'should scroll to top on click', inject ($window) ->
            # TODO: fake onclick and test scrollTop position
            expect(true).toBeTruthy()

    describe 'ngMeta', ->

        it 'should set scope variable', inject ($compile) ->
            element = $compile('<ng-meta name="var" value="\'value\'" />')(scope)

            expect(scope.var).toEqual 'value'

        it 'should update objects in scope', inject ($compile) ->
            scope.var = {}
            element = $compile('<ng-meta name="var" update="{prop: 1024}" />')(scope)

            expect(scope.var.prop).toEqual 1024

    describe 'youtube', ->

        it 'should produce correct youtube iframe', inject ($compile) ->
            element = $compile('<youtube id="YTID" />')(scope)
            scope.$apply()

            expect(element.attr('src')).toEqual 'http://www.youtube.com/embed/YTID'

        it 'should accept width and height attributes', inject ($compile) ->
            element = $compile('<youtube id="YTID" width="1280" height="800" />')(scope)
            scope.$apply()

            expect(element.attr('width')).toEqual '1280'
            expect(element.attr('height')).toEqual '800'


