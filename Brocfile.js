var concat = require('broccoli-concat');
var mergeTrees = require('broccoli-merge-trees');
var SassSourceMaps = require('broccoli-sass-source-maps');
var Funnel = require('broccoli-funnel');
var Sass = require('sass');

var javascripts = concat('assets/javascripts', {
  inputFiles: ['**/*.js'],
  outputFile: 'app.js'
});

var stylesheets = concat('assets/stylesheets', {
  headerFiles: [
    'variables.scss',
    'breakpoints.scss',
  ],
  inputFiles: ['**/*.scss'],
  outputFile: 'app.scss'
});

var images = new Funnel('assets/images', {
  destDir: 'images'
});

var compileSass = SassSourceMaps(Sass);
var styles = compileSass([stylesheets], 'app.scss', '/app.css');

module.exports = mergeTrees([javascripts, styles, images]);
