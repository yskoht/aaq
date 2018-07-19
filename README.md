
# AAQ - Ascii Art Quine

[![Gem Version](https://badge.fury.io/rb/aaq.svg)](https://badge.fury.io/rb/aaq)
[![MIT License](https://img.shields.io/github/license/mashape/apistatus.svg)](LICENSE)

Create ascii art quine from image file.

![Demo.gif](https://github.com/yskoht/aaq/raw/gif/demo.gif)

```sh
# Download sample image
curl -O https://github-media-downloads.s3.amazonaws.com/Octocats.zip && unzip Octocats.zip
aaq Octocat/Octocat.png --color
```

## Installation

```sh
$ gem install aaq
```

## Usage

Simple quine.

```sh
aaq Octocat/Octocat.png
```

Colorful quine.

```sh
aaq Octocat/Octocat.png --color
```

Delete escape sequence.

```sh
aaq Octocat/Octocat.png --color | ruby -ne 'puts $_.gsub(/\e.*?m/, "")' | ruby
```

Put `--color` option.

```sh
aaq Octocat/Octocat.png | xargs -0 -J % ruby -e % '' --color
```

In your source code.

```ruby
require 'aaq'

puts AAQ::AAQ.new(img_file_name).convert
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yskoht/aaq.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
