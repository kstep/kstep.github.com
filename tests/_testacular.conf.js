files = [JASMINE, JASMINE_ADAPTER, '../js/_libs/jquery.min.js', '../js/_libs/angular.js', '../js/_libs/angular-*.js', 'libs/angular-mocks.js', '../js/underscore-min.js', '../js/application-min.js', '**/*Spec.js', '**/*Spec.coffee'];
browsers = ['Firefox', 'Chrome', 'Opera'];
autoWatch = true;
preprocessors = {
    '**/*.coffee': 'coffee'
};
