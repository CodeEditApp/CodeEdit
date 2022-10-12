#!/usr/bin/ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

class Item
  def initialize(file, line, at)
    @file = file
    @line = line
    @at = at + 1
    if match = line.match(/(func|let|var|class|enum|struct|protocol)\s+(\w+)/)
      @type = match.captures[0]
      @name = match.captures[1]
    end
  end

  def modifiers
    return @modifiers if @modifiers
    @modifiers = []
    if match = @line.match(/(.*?)#{@type}/)
      @modifiers = match.captures[0].split(" ")
    end
    return @modifiers
  end  

  def name 
    @name
  end  

  def file
    @file
  end  

  def to_s
    serialize
  end
  def to_str
    serialize
  end

  def full_file_path
    Dir.pwd + '/' + @file
  end  

  def serialize
    "Item< #{@type.to_s.green} #{@name.to_s.yellow} [#{modifiers.join(" ").cyan}] from: #{@file}:#{@at}:0>"
  end  

  def to_xcode 
    "#{full_file_path}:#{@at}:0: warning: #{@type.to_s} #{@name.to_s} is unused"
  end


end
class Unused
  def find
    items = []
    all_files = Dir.glob("**/*.swift").reject do |path|
      File.directory?(path)
    end

    all_files.each { |my_text_file|
      file_items = grab_items(my_text_file)
      file_items = filter_items(file_items)

      non_private_items, private_items = file_items.partition { |f| !f.modifiers.include?("private") && !f.modifiers.include?("fileprivate") }
      items += non_private_items

      # Usage within the file
      if private_items.length > 0
        find_usages_in_files([my_text_file], [], private_items)
      end  

    }

    puts "Total items to be checked #{items.length}"

    items = items.uniq { |f| f.name }
    puts "Total unique items to be checked #{items.length}"

    puts "Starting searching globally it can take a while".green

    xibs = Dir.glob("**/*.xib")
    storyboards = Dir.glob("**/*.storyboard")

    find_usages_in_files(all_files, xibs + storyboards, items)

  end  

  def ignore_files_with_regexps(files, regexps)
    files.select { |f| regexps.all? { |r| Regexp.new(r).match(f.file).nil? } }
  end  

  def ignoring_regexps_from_command_line_args
    regexps = []
    should_skip_predefined_ignores = false

    arguments = ARGV.clone
    until arguments.empty?
      item = arguments.shift
      if item == "--ignore"
        regex = arguments.shift
        regexps += [regex]
      end  

      if item == "--skip-predefined-ignores"
        should_skip_predefined_ignores = true
      end  
    end  

    if not should_skip_predefined_ignores
      regexps += [
       "^Pods/",
       "fastlane/",
       "Tests.swift$",
       "Spec.swift$",
       "Tests/"
     ]
   end 

   regexps
 end  

  def find_usages_in_files(files, xibs, items_in)
    items = items_in
    usages = items.map { |f| 0 }
    files.each { |file|
      lines = File.readlines(file).map {|line| line.gsub(/^[^\/]*\/\/.*/, "")  }
      words = lines.join("\n").split(/\W+/)
      words_arrray = words.group_by { |w| w }.map { |w, ws| [w, ws.length] }.flatten

      wf = Hash[*words_arrray]

      items.each_with_index { |f, i| 
        usages[i] += (wf[f.name] || 0)
      }
      # Remove all items which has usage 2+
      indexes = usages.each_with_index.select { |u, i| u >= 2 }.map { |f, i| i }

      # reduce usage array if we found some functions already 
      indexes.reverse.each { |i| usages.delete_at(i) && items.delete_at(i) }
    }

    xibs.each { |xib|
      lines = File.readlines(xib).map {|line| line.gsub(/^\s*\/\/.*/, "")  }
      full_xml = lines.join(" ")
      classes = full_xml.scan(/(class|customClass)="([^"]+)"/).map { |cd| cd[1] }
      classes_array = classes.group_by { |w| w }.map { |w, ws| [w, ws.length] }.flatten

      wf = Hash[*classes_array]

      items.each_with_index { |f, i| 
        usages[i] += (wf[f.name] || 0)
      }
      # Remove all items which has usage 2+
      indexes = usages.each_with_index.select { |u, i| u >= 2 }.map { |f, i| i }

      # reduce usage array if we found some functions already 
      indexes.reverse.each { |i| usages.delete_at(i) && items.delete_at(i) }

    }

    regexps = ignoring_regexps_from_command_line_args()

    items = ignore_files_with_regexps(items, regexps)

    if items.length > 0
      if ARGV[0] == "xcode"
        $stderr.puts "#{items.map { |e| e.to_xcode }.join("\n")}"
      else
        puts "#{items.map { |e| e.to_s }.join("\n ")}"
      end
    end  
  end  

  def grab_items(file)
    lines = File.readlines(file).map {|line| line.gsub(/^\s*\/\/.*/, "")  }
    items = lines.each_with_index.select { |line, i| line[/(func|let|var|class|enum|struct|protocol)\s+\w+/] }.map { |line, i| Item.new(file, line, i)}
  end  

  def filter_items(items)
    items.select { |f| 
      !f.name.start_with?("test") && !f.modifiers.include?("@IBAction") && !f.modifiers.include?("override") && !f.modifiers.include?("@objc") && !f.modifiers.include?("@IBInspectable")
    }
  end

end  

class String
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def yellow;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end


Unused.new.find