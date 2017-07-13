# This module will validate the format of a commit message to ensure that it
# follows the community agreed upon standards.
#
module Format
  def self.title_line(line, line_number, real_line_number)
    if line_number.zero? && line.length > 50
      return "Error #{real_line_number}: First line should be less than 50 \
      characters in length."
    end
    false
  end

  def self.blank_line(line, line_number, real_line_number)
    if line_number == 1 && !line.empty?
      return "Error #{real_line_number}: Second line should be empty."
    end
    false
  end

  def self.line_chars(line, real_line_number)
    if line.length > 72 && line[0, 1] != '#'
      return "Error #{real_line_number}: No line should be over 72 characters \
      long."
    end
    false
  end

  def self.lines(message_file, commit_msg, errors)
    File.open("../#{message_file}", 'r').each_with_index do |line, line_number|
      commit_msg.push line
      e = check_format_rules(line_number, line.strip)
      errors.push e if e
    end
  end

  def self.errors(message_file, commit_msg, errors)
    File.open("../#{message_file}", 'w') do |file|
      file.puts "\n# GIT COMMIT MESSAGE FORMAT ERRORS:"
      errors.each { |error| file.puts "#    #{error}" }
      file.puts "\n"
      commit_msg.each { |line| file.puts line }
    end
  end

  def self.fix(message_file, editor)
    print 'Invalid git commit message format. Press y to edit and n to cancel \
    the commit. [y/n] '
    STDIN.reopen('/dev/tty')
    choice = $stdin.gets.chomp

    exit 1 if %w[no n].include?(choice.downcase)
    system(editor, "../#{message_file}")
  end
end