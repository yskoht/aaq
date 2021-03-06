require 'aaq/version'
require 'aaq/colors'

require 'set'
require 'rmagick'

module AAQ
  UNIT_HORIZONTAL_DEFAULT = 6
  UNIT_VERTICAL_DEFAULT = 14

  class AAQ
    attr_reader :img, :width, :height, :data, :code, :unit_horizontal, :unit_vertical

    def initialize(input_img, options: {})
      org_img = Magick::ImageList.new(input_img)
      @unit_horizontal = options[:unit_horizontal] || UNIT_HORIZONTAL_DEFAULT
      @unit_vertical = options[:unit_vertical] || UNIT_VERTICAL_DEFAULT
      @img, @width, @height = resize(org_img)
    end

    def convert
      qtz = quantize
      colors = Set.new(qtz.flatten).to_a.sort
      blank_color = remove_blank_color(colors)

      @data = separate_color(qtz, colors).map do |x|
        x.join.gsub(/0+|1+/) do |c|
          "#{c[0] == '0' ? ':' : '_'}#{c.size}"
        end
      end

      @code = encode(@data, colors, blank_color)
      self
    end

    def encode(data, colors, blank_color)
      code = <<~"QUINE"
        eval $s = %w'
        b = #{data}.map{ |x|
          x.gsub(/:[0-9]+|_[0-9]+/){ |c|
            (c[0] == \":\" ? \"0\" : \"1\") * c[1..-1].to_i
          }.reverse.to_i(2)
        };
        e = \"eval $s = %w\" << 39 << $s;
        o = \"\";
        j = k = -1;
        d = \"\" << 39 << \".join\";
        #{width * height}.times{ |i|
          e += (i < e.size) ? "" : $s;
          c = #{Array.new(data.size) { |j| "b[#{j}][i] == 1 ? #{colors[j]} :" }.join(' ')} #{blank_color};
          ARGV.include?(\"--color\")
            ? o << \"\" << 27 << \"[38;5;%sm\" % c << 27 << \"[48;5;%sm\" % c
                << (i < 10 ? e[j+=1] : i > #{width * height - 7} ? d[k+=1] : c == #{blank_color} ? 32 : e[j+=1])
                << 27 << \"[0m\"
            : o << (i < 10 ? e[j+=1] : c == #{blank_color} ? 32 : e[j+=1]);
          o << (i % #{width} == #{width - 1} ? 10 : \"\");
        };
        ARGV.include?(\"--color\") ? \"\" : o[-7, 6] = d;
        puts(o)#'.join
      QUINE
      code.gsub(/\s/, '')
    end

    def to_s
      b = data.map do |x|
        x.gsub(/:[0-9]+|_[0-9]+/) { |c|
          (c[0] == ':' ? '0' : '1') * c[1..-1].to_i
        }.reverse.to_i(2)
      end

      str = "eval$s=%w'"
      k = -1
      c = co = @code.gsub("eval$s=%w'", '').gsub("'.join", '')
      height.times do |h|
        width.times do |w|
          i = h * width + w
          next if i < 10

          c += co if i >= c.size
          str += b.map { |x| x[i] }.include?(1) ? c[k += 1] : ' '
        end
        str += "\n"
      end
      str[-7, 6] = '' << 39 << '.join'
      str
    end

    private

    def resize(org_img)
      w = org_img.columns / @unit_horizontal
      h = org_img.rows / @unit_vertical
      [org_img.resize(w * @unit_horizontal, h * @unit_vertical), w, h]
    end

    def quantize
      memo = {}

      Array.new(height) do |h|
        y = h * @unit_vertical
        Array.new(width) do |w|
          x = w * @unit_horizontal
          to_256color(mode(x, y), memo)
        end
      end
    end

    def mode(x, y)
      h = Hash.new(0)
      y.upto(y + @unit_vertical) do |dy|
        x.upto(x + @unit_horizontal) do |dx|
          h[img.pixel_color(dx, dy)] += 1
        end
      end
      h.max_by { |a| a[1] }[0]
    end

    def to_256(pix)
      [pix.red / 256, pix.green / 256, pix.blue / 256]
    end

    def to_256color(pix, memo)
      return -1 if pix.opacity.positive?
      return memo[pix] if memo.include?(pix)

      memo[pix] = COLORS.min { |a, b|
        dist(a[1], to_256(pix)) <=> dist(b[1], to_256(pix))
      }[0]
    end

    def dist(a, b)
      a.zip(b).map { |x| (x[0] - x[1])**2 }.sum
    end

    def remove_blank_color(colors)
      if colors.include?(-1)
        colors.delete(-1)
      elsif colors.include?(15)
        colors.delete(15)
      else
        -2
      end
    end

    def separate_color(qtz, colors)
      colors.each.map do |c|
        qtz.flatten.map do |q|
          q == c ? '1' : '0'
        end
      end
    end
  end
end
