require "string_scanner"

# Old-style ASCII property lists parser.
#
# This format was used in the OpenStep frameworks.  It is officially
# documentated at the page ["Old-Style ASCII Property Lists"][apple]
# in the Documentation Archive.
#
# [apple]: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/OldStylePlists/OldStylePLists.html
# [gnustep]: https://gnustep.github.io/resources/documentation/Developer/Base/Reference/NSPropertyList.html
# [wiki]: https://en.wikipedia.org/wiki/Property_list
module NSPlist
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  def self.parse(source)
    Parser.new(source).parse
  end

  private class Parser
    def initialize(source)
      @scanner = StringScanner.new(source)
    end

    def parse
      skip_separator
      parse_expression
    end

    def parse_expression
      parse_array || parse_binary_data || parse_dictionary || parse_string
    end

    def parse_string
      parse_quoted_string || parse_bare_string
    end

    def parse_quoted_string
      @scanner.skip('"') || return
      content = @scanner.scan_until('"').not_nil!
      skip_separator
      NSString.new(content[..-2])
    end

    def parse_bare_string
      content = @scanner.scan(%r{ [a-zA-Z0-9_$+/:.-]+ }x) || return
      skip_separator
      NSString.new(content)
    end

    def parse_array
      @scanner.skip('(') || return
      skip_separator
      elements = [] of NSArray::Element
      until @scanner.eos?
        element = parse_expression || break
        elements << NSArray::Element.new(element)
        skip_separator
        @scanner.skip(',') || break
        skip_separator
      end
      @scanner.skip(')') || return
      skip_separator
      NSArray.new(elements)
    end

    def parse_dictionary
      @scanner.skip('{') || return
      skip_separator
      dictionary = parse_dictionary_body || return
      @scanner.skip('}') || return
      skip_separator
      dictionary
    end

    def parse_dictionary_body
      dictionary = {} of NSString => NSDictionary::Value
      until @scanner.eos?
        key = parse_string || break
        skip_separator
        @scanner.skip('=') || return
        skip_separator
        value = parse_expression || return
        skip_separator
        @scanner.skip(';') || return
        skip_separator
        dictionary[key] = NSDictionary::Value.new(value)
      end
      NSDictionary.new(dictionary)
    end

    def parse_binary_data
      @scanner.skip('<') || return
      skip_separator
      bytes = ""
      until @scanner.eos?
        bytes += @scanner.scan(/ [0-9a-f]+ /x) || break
        skip_separator
      end
      @scanner.skip('>') || return
      skip_separator

      # TODO: Extract hexbytes definition and optimize.
      bytes.size.even? || (bytes = bytes[..-2] + "0" + bytes[-1])
      NSData.new(bytes.hexbytes)
    end

    def skip_separator
      skip_spaces
      while @scanner.skip("/*")
        @scanner.skip_until("*/") || raise "no comment end"
        skip_spaces
      end
    end

    def skip_spaces
      @scanner.skip(/ [ \n\t]* /x)
    end

    delegate eos?, to: @scanner
  end

  class NSString
    def initialize(@string : String)
    end

    def ==(other : NSString)
      @string == other.to_s
    end

    def ==(other)
      @string == other
    end

    def to_s
      @string
    end
  end

  class NSData
    getter :bytes

    def initialize(@bytes : Bytes)
    end

    def ==(other : NSData)
      @bytes == other.bytes
    end

    def ==(other)
      @bytes == other
    end
  end

  class NSArray
    record Element, value : NSArray | NSData | NSString | NSDictionary

    def initialize(@array : Array(Element))
    end

    def initialize(array)
      @array = array.map { |element| Element.new(NSString.new(element)) }
    end

    def ==(other : NSArray)
      @array == other.to_a
    end

    def to_a
      @array
    end
  end

  class NSDictionary
    record Value, value : NSArray | NSData | NSString | NSDictionary

    def initialize(@dictionary : Hash(NSString, Value))
    end

    def initialize(dictionary)
      @dictionary = dictionary.transform_keys { |key| NSString.new(key) }
        .transform_values { |value| Value.new(NSString.new(value)) }
    end

    def ==(other : NSDictionary)
      @dictionary == other.to_h
    end

    def to_h
      @dictionary
    end
  end
end
