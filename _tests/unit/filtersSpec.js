describe('Filters', function () {
    beforeEach(module('kstep'));

    describe('strip_tags', function () {
        var strip_tags;

        beforeEach(inject(function ($filter) {
            strip_tags = $filter('strip_tags');
        }));

        it('should remove all tags from a string', function () {
            var string = '<p><b>bold text</b><br /><a href="#">&</a><span class="red label" onclick="alert(\'clicked!\')">spanned text</span></p><hr/>';
            expect(strip_tags(string)).toBe('bold text&spanned text');
        });
    });
});
