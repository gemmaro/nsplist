# nsplist

[![GitHub release](https://img.shields.io/github/release/gemmaro/nsplist.svg)](https://github.com/gemmaro/nsplist/releases)

Old-style ASCII property lists parser.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     nsplist:
       github: gemmaro/nsplist
   ```

2. Run `shards install`

## Usage

```crystal
require "nsplist"

NSPlist.parse(source) #=> property list data
```

## Development

`crystal spec` for testing, and `crystal docs` to generate an API documentation.

## Contributing

1. Fork it (<https://github.com/gemmaro/nsplist/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Related Works

There are several related works on the property list parsing.  For
parsing the property lists in the XML format, there is a
[plist-cr][xml] libarry.

[xml]: https://github.com/egillet/plist-cr

## Contributors

- [gemmaro](https://github.com/gemmaro) - creator and maintainer
