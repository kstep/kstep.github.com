describe 'Directives', ->
    beforeEach ->
        module 'kstep'

    scope = undefined
    beforeEach inject ($rootScope) ->
        scope = $rootScope.$new()

    describe 'totop', ->
        element = undefined

        beforeEach inject ($compile) ->
            element = $compile('<a class="totop"></a>')(scope)
            scope.$apply()

        it 'should scroll to top on click', inject ($window) ->
            scrollTop = 1000
            spyOn($window.jQuery.prototype, 'scrollTop').andCallFake (pos) ->
                scrollTop = pos

            $(element[0]).trigger 'click'
            expect($window.jQuery.prototype.scrollTop).toHaveBeenCalledWith 0
            expect(scrollTop).toEqual 0

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

    describe 'disqus', ->

        it 'should generate unique id for tag without id', inject ($compile) ->
            element0 = $compile('<disqus name="shortname" />')(scope)
            element1 = $compile('<disqus name="shortname" />')(scope)
            scope.$apply()

            expect(element0.attr('id')).toEqual 'disqus_thread0'
            expect(element1.attr('id')).toEqual 'disqus_thread1'

        it 'should load and configure Disqus API', inject ($compile, $window, $jsload) ->
            element = $compile('<disqus id="thread" name="kstep" />')(scope)
            scope.$apply()

            expect($window.disqus_container_id).toEqual 'thread'
            #waitsFor -> $window.DISQUS?

