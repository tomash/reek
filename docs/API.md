# API

## Using `reek` inside your Ruby application

`reek` can be used inside another Ruby project.

```bash
gem install reek
```

You can use reek inside your Ruby file `check_dirty.rb`

```ruby
require 'reek'

source =<<END
class Dirty
  # This method smells of :reek:NestedIterators but ignores them
  def awful(x, y, offset = 0, log = false)
    puts @screen.title
    @screen = widgets.map { |w| w.each { |key| key += 3 * x } }
    puts @screen.contents
    fail
  end
end
END

reporter = Reek::CLI::Report::TextReport.new
reporter.add_examiner Reek::Examiner.new(source)

puts reporter.show
```

This will show the list of errors in variable `source`.

`Reek::Examiner.new` can take `source` as `String`, `File` or `IO`, or an array
of file names.

```
# Examine a file object
reporter.add_examiner Reek::Examiner.new(File.new('dirty.rb'))
# Examine source from an array of file names
reporter.add_examiner Reek::Examiner.new(['also_dirty.rb', 'clean.rb')
```

Also, besides normal text output, `reek` can also generate output in YAML,
JSON, HTML and XML by using the following Report types:

```
TextReport
YAMLReport
JSONReport
HTMLReport
XMLReport
```
