
compile
  .init()
  .set('jquery', 'http://url')
  .set('my-lib', 'var foo = 42;')
  .run('uglify', {
    src: 'my-lib',
    dest: 'my-lib.min',
    options: {
      a: 42
    }
  })
  .download('my-lib.min')
  .done('my-lib.min', function(err, lib) {

  });

compile
  .init()
  .set('lib-x', '...')
  .set('lib-y', '...')
  .run('concat', {
    src: ['lib-x','lib-y'],
    dest: 'lib-z'
  })
  .download('lib-z');

compile
  .init()
  .set('my-lib-src', './code/src.coffee')
  .run('coffee', {
    src: 'src',
    dest: 'my-lib'
  })
  .download('lib-z');

compile
  .init()
  .set('my-lib', '...')
  .run('lint', {
    src: 'my-lib'
  })
  .done(function(err) {

  });






