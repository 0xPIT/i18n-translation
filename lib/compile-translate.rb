#
# i18n translation script compiler v0.1
# http://cweiss.de
# 2012, Christopher Weiss
# @cweissde
#
# licensed under the MIT
# Date: Sat Aug 04 11:46 2012
#

#!/usr/bin/env ruby
require "optparse"

# defaults
options = {}
indentation = 2
# the pattern to match the key & value
pattern = /\A(.*?): (\"(.*)\"|(.*))/i
# the pattern to match the key
key_pattern = /^[ ]{#{indentation}}(.*)$/i
# the pattern to match the key again
prefix_pattern = /^[ ]{#{indentation}}\S(.*):/i
# indentation pattern
indentation_pattern = /[ ]{#{indentation}}/

# Warnings
warning = "\e[31mi18n Warning:\e[0m"
error = "#{warning} Missing parameters. --help for more information"

# Help Messages
verbose_help = "Output more information"
pattern_help = "Translation Regex e.g. '\A(.*?): (\"(.*)\"|(.*))' (translationKey: translation)"
files_help = "files to convert: [file 1,file 2]"
locales_help = "locales for files: [locale 1,locale 2]"
export_dir_help = "export dir for converted files"
help = "Show this message"

# Options
optparse = OptionParser.new do | opts |
  opts.on("-f FILES", "--files FILES", Array, files_help) do | files |
    options[:files] = files
  end

  opts.on("-l LOCALES", "--locales LOCALES", Array, locales_help) do | locales |
    options[:locales] = locales
  end

  opts.on("", "--export_dir FOLDER", export_dir_help) do | dir |
    options[:dir] = dir
  end

  opts.on( "-v", "--verbose", verbose_help) do
    options[:verbose] = true
  end

  # opts.on("", "--pattern PATTERN", pattern_help) do | pattern |
  #   options[:pattern] = pattern
  # end

  opts.on("-h", "--help", help) do
    puts opts
    exit
  end
end

# extend options
optparse.parse!
files = options[:files]
locales = options[:locales]
# pattern = options[:pattern] || pattern
dir = options[:dir] ? "#{options[:dir]}/" : ""
verbose = options[:verbose] || false

# Helper
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end
end

# check required parameters
if locales.blank?
  puts error
  exit
elsif files.blank?
  puts error
  exit
elsif files.length != locales.length
  puts error
  exit
end

# check that the file exits else throw an error
begin
  # get file from all files
  files.each_with_index do | file, index |
    locale = locales[index]
    file = IO.readlines(file)
    filename = "#{dir}#{locale}.js"
    output = Array.new
    key_prefix = Array.new

    # start parsing
    file.each do | el |
      match = el.match(key_pattern)

      # matching key?
      if match.present?
        key = match.to_s.gsub("\"", "")

        # match for kay and value
        value_match = el.match(pattern)
        # the first key wihtout value
        if key.match(prefix_pattern) && value_match.blank?
          # clear prefix array
          key_prefix.clear
          # set the prefix
          key_prefix << key.match(prefix_pattern).to_s.gsub(':', '').strip!

          # key and value match
        elsif value_match.present?
          key_translation = value_match[1].to_s.gsub("\"", "").strip!

          # if a prefix is set add this to the key
          if key_prefix.present?
            key_translation = key_prefix.compact.join('.'), '.', key_translation
          end

          # value beautifier
          value = value_match[3] ? value_match[3] : value_match[2]
          value = value.gsub("'", "")

          # pre-check if the key has a value
          if key_translation.present? && value.empty? && verbose == true
            puts "#{warning} Empty translation for: '#{key_translation}'"
          end

          # if double tix on the start of the value, we remove this and show that there a syntax missmatch is
          if value_match[3].present? && verbose == true
            puts "#{warning} Found syntax missmatch: #{key_translation}: #{value_match[2]}. Took: #{value_match[3]} as translation"
          end

          # saving output
          output << [ key_translation, value ]

        else
          # prefix beautifier
          newPrefix = key.to_s.gsub(':', '').strip!

          # check to prevend doublicated keys
          if key_prefix.last != newPrefix
            index = key.to_s.scan(indentation_pattern).size
            key_prefix[index] = newPrefix
          end
        end
      else
        # clear prefix if we have a empty line
        key_prefix.clear
      end
    end

    # if export_dir is set then check if the folder exits
    if dir.present?
      # if not create it
      Dir.mkdir(dir) unless File.exists?(dir)
    end

    # write to file
    File.open( filename, "w" ) do | file |
      # build JSON
      output = output.map { | el | "'#{el[0]}': '#{el[1]}'" }.join(", ")
      file.puts "/*globals i18n: false*/"
      file.puts "(function () {"
      file.puts "    i18n.setTranslations({ '#{locale}': {#{output} }});"
      file.puts "}( window ));"
      # output in console
      if verbose == true
        puts "'#{locale}': #{output}"
      end
      puts "i18n Created #{filename}"
    end

  end
rescue
  raise "#{warning} No file specified or is not available. --help for more informations."
  exit
end
