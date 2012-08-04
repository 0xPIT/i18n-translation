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
keyPattern = /^[ ]{#{indentation}}(.*)$/i
# the pattern to match the key again
prefixPattern = /^[ ]{#{indentation}}\S(.*):/i
# indentation pattern
indentationPattern = /[ ]{#{indentation}}/

# Warnings
warning = "\e[31mi18n Warning:\e[0m"
error = "#{warning} Missing parameters. --help for more information"

# Help Messages
verboseHelp = "Output more information"
patternHelp = "Translation Regex e.g. '\A(.*?): (\"(.*)\"|(.*))' (translationKey: translation)"
filesHelp = "files to convert: [file 1,file 2]"
localesHelp = "locales for files: [locale 1,locale 2]"
exportDirHelp = "export dir for converted files"
help = "Show this message"

# Options
optparse = OptionParser.new do | opts |
  opts.on("-f FILES", "--files FILES", Array, filesHelp) do | files |
    options[:files] = files
  end

  opts.on("-l LOCALES", "--locales LOCALES", Array, localesHelp) do | locales |
    options[:locales] = locales
  end

  opts.on("", "--export_dir FOLDER", exportDirHelp) do | dir |
    options[:dir] = dir
  end

  opts.on( "-v", "--verbose", verboseHelp) do
    options[:verbose] = true
  end

  # opts.on("", "--pattern PATTERN", patternHelp) do | pattern |
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
    keyPrefix = Array.new

    # start parsing
    file.each do | el |
      match = el.match(keyPattern)

      # matching key?
      if match.present?
        key = match.to_s.gsub("\"", "")

        # match for kay and value
        valueMatch = el.match(pattern)
        # the first key wihtout value
        if key.match(prefixPattern) && valueMatch.blank?
          # clear prefix array
          keyPrefix.clear
          # set the prefix
          keyPrefix << key.match(prefixPattern).to_s.gsub(':', '').strip!

          # key and value match
        elsif valueMatch.present?
          keyTranslation = valueMatch[1].to_s.gsub("\"", "").strip!

          # if a prefix is set add this to the key
          if keyPrefix.present?
            keyTranslation = keyPrefix.compact.join('.'), '.', keyTranslation
          end

          # value beautifier
          value = valueMatch[3] ? valueMatch[3] : valueMatch[2]
          value = value.gsub("'", "")

          # pre-check if the key has a value
          if keyTranslation.present? && value.empty? && verbose == true
            puts "#{warning} Empty translation for: '#{keyTranslation}'"
          end

          # if double tix on the start of the value, we remove this and show that there a syntax missmatch is
          if valueMatch[3].present? && verbose == true
            puts "#{warning} Found syntax missmatch: #{keyTranslation}: #{valueMatch[2]}. Took: #{valueMatch[3]} as translation"
          end

          # saving output
          output << [ keyTranslation, value ]

        else
          # prefix beautifier
          newPrefix = key.to_s.gsub(':', '').strip!

          # check to prevend doublicated keys
          if keyPrefix.last != newPrefix
            index = key.to_s.scan(indentationPattern).size
            keyPrefix[index] = newPrefix
          end
        end
      else
        # clear prefix if we have a empty line
        keyPrefix.clear
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
      file.puts "(function() {"
      file.puts "i18n.setTranslations({ '#{locale}': {#{output} }});"
      file.puts "})( window );"
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
