
require! {
  \./package.json : pkg
  \gulp
  \gulp-connect
  \gulp-concat-util : concat
  \gulp-stylus : styl
  \gulp-sass : sass
  \gulp-csscomb
  \gulp-cssmin
  \gulp-requirejs-optimize : rjs
  \gulp-uglifyjs
  \gulp-symlink
  \gulp-browserify
  \gulp-livescript
  \gulp-jade
  \gulp-watch : watch
  \gulp-qunit
}

const VERSION = pkg.version
const BANNER = """
/*! 漢字標準格式 v#{VERSION} | MIT License | css.hanzi.co */
/*! Han.css: the CSS typography framework optimised for Hanzi */
\n
"""

const CSS-BANNER = """
@charset "UTF-8";

#{BANNER}
"""

const unwrap = ( name, path, src ) ->
  rdefineEnd = /\}\);?[^}\w]*$/

  if path is /.\/var\//
    src = src
      .replace( /define\([\w\W]*?return/, 'var ' + /var\/([\w-]+)/.exec(name)[1] + ' =' )
      .replace( rdefineEnd, '')
  else if name is /^fibre$/
    src = '\nvar Fibre =\n' + src
      .replace( /void\s/, '' )
      .replace( "var Finder = Finder || require( './finder.umd' )\n", '' )
      .replace( /\/\/\s*EXPOSE[\w\W]*\/\/\s*EXPOSE/, 'return Fibre' )
  else
    src = src
      .replace( /\s*return\s+[^\}]+(\}\);?[^\w\}]*)$/, '$1' )
      .replace( /define\([^{]*?{/, '' )
      .replace( rdefineEnd, '' )
      .replace( /\/\*\s*ExcludeStart\s*\*\/[\w\W]*?\/\*\s*ExcludeEnd\s*\*\//ig, '' )
      .replace( /\/\/\s*BuildExclude\n\r?[\w\W]*?\n\r?/ig, '' )
      .replace( /define\(\[[^\]]+\]\)[\W\n]+$/, '' )
  src

rjs-config = {
  baseUrl: \src/js
  name: \han
  out: \./han.js
  optimize: \none
  findNestedDependencies: yes
  skipSemiColonInsertion: yes
  wrap: {
    startFile: \src/js/intro.js
    endFile: \src/js/outro.js
  }
  paths: {
    fibre: \../lib/fibre.js/index
  }
  rawText: {}
  onBuildWrite: unwrap
}

gulp.task \dep        <[ normalize.css fibre.js ]>
gulp.task \build      <[ dist:font dist:cssmin dist:uglify ]>
gulp.task \build:styl <[ dist:font dist:cssmin-styl dist:uglify ]>
gulp.task \dev        <[ watch server ]>
gulp.task \default    <[ build demo ]>

gulp.task \server !->
  gulp-connect.server {
    port: 7777
    livereload: true
  }

# Build for distribution
gulp.task \dist:font ->
  gulp.src './font/han*.{woff,otf}'
    .pipe gulp.dest \./dist/font

gulp.task \dist:styl ->
  gulp.src \./index.styl
    .pipe styl!
    .pipe concat \han.css, {
      process: ( src ) ->
        src
          .replace /@charset\s(['"])UTF-8\1;\n/g, ''
          .replace /@VERSION/g, "v#{VERSION}"
    }
    .pipe concat.header CSS-BANNER
    .pipe gulp-csscomb!
    .pipe gulp.dest \./dist

gulp.task \dist:sass ->
  gulp.src \./src/sass/han.scss
    .pipe sass!
    .pipe concat \han.css, {
      process: ( src ) ->
        src
          .replace /@charset\s(['"])UTF-8\1;\n/g, ''
          .replace /@VERSION/g, "v#{VERSION}"
    }
    .pipe concat.header CSS-BANNER
    .pipe gulp-csscomb!
    .pipe gulp.dest \./dist

gulp.task \dist:cssmin <[ dist:sass ]> ->
  gulp.src \./dist/han.css
    .pipe gulp-cssmin { keepSpecialComments: 0 }
    .pipe concat \han.min.css, {
      process: ( src ) ->
        src.replace /@charset\s(['"])UTF-8\1;/g, ''
    }
    .pipe concat.header CSS-BANNER
    .pipe gulp.dest \./dist

gulp.task \dist:cssmin-styl <[ dist:styl ]> ->
  gulp.src \./dist/han.css
    .pipe gulp-cssmin { keepSpecialComments: 0 }
    .pipe concat \han.min.css, {
      process: ( src ) ->
        src.replace /@charset\s(['"])UTF-8\1;/g, ''
    }
    .pipe concat.header CSS-BANNER
    .pipe gulp.dest \./dist

gulp.task \dist:js ->
  gulp.src \./src/js/han.js
    .pipe rjs rjs-config
    .pipe concat \han.js, {
      process: ( src ) ->
        src
          .replace /@VERSION/g, VERSION
          .replace /\n{3,}/g, '\n\n'
    }
    .pipe gulp.dest \./dist

gulp.task \dist:uglify <[ dist:js ]> ->
  gulp.src \./dist/han.js
    .pipe gulp-uglifyjs \han.min.js {
      output: {
        ascii_only: true
      }
    }
    .pipe concat \han.min.js
    .pipe concat.header BANNER
    .pipe gulp.dest \./dist

# API test
gulp.task \test ->
  gulp.src \./test/api.html
    .pipe gulp-qunit!

# Demo
gulp.task \demo <[ build ]> ->
  gulp.start <[ demo:font demo:js demo:sass demo:jade ]>

gulp.task \demo:dist <[ build ]> ->
  gulp.src <[ ./dist/han*.css ./dist/han*.js ]>
    .pipe gulp.dest \./test

gulp.task \demo:dist-styl <[ build:styl ]> ->
  gulp.src <[ ./dist/han*.css ./dist/han*.js ]>
    .pipe gulp.dest \./test

gulp.task \demo:font ->
  gulp.src './dist/font/*.{woff,otf}'
    .pipe gulp.dest \./test/font

gulp.task \demo:sass ->
  gulp.src \./test/*.scss
    .pipe sass!
    .pipe gulp-cssmin { keepSpecialComments: 0 }
    .pipe gulp.dest \./test

gulp.task \demo:jade ->
  gulp.src \./test/*.jade
    .pipe gulp-jade!
    .pipe gulp.dest \./test

gulp.task \demo:js <[ demo:dist ]> ->
  gulp.src \./test/test-commonjs.ls
    .pipe gulp-livescript!
    .pipe gulp-browserify!
    .pipe gulp-uglifyjs {
      output: {
        ascii_only: true
      }
    }
    .pipe gulp.dest \./test
  gulp.src \./test/api.ls
    .pipe gulp-livescript!
    .pipe gulp.dest \./test

# Watch
gulp.task \watch <[ default ]> ->
  gulp.watch \./src/sass/**/* <[ demo:dist ]>
  gulp.watch \./src/styl/**/* <[ demo:dist-styl ]>
  gulp.watch \./src/js/**/*   <[ demo:js ]>
  gulp.watch \./test/*.scss   <[ demo:sass ]>
  gulp.watch \./test/*.jade   <[ demo:jade ]>
  gulp.watch \./test/*.ls     <[ demo:js ]>

# Dependencies
gulp.task \normalize.css !->
  gulp.src \./node_modules/normalize.css/normalize.css
    .pipe concat \_normalize.scss
    .pipe gulp.dest \./src/sass/locale

gulp.task \fibre.js !->
  gulp.src \./node_modules/fibre.js/dist/fibre.js
    .pipe concat \index.js
    .pipe gulp.dest \./src/lib/fibre.js

