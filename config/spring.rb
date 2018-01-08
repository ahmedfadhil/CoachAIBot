%w(
  .ruby-version
  .rbenv-vars
  tmp.html/restart.txt
  tmp.html/caching-dev.txt
).each { |path| Spring.watch(path) }
