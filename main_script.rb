require 'find'
require 'csv'

# Function to count the occurrences of fa_icon patterns in files
def count_fa_icons(directory)
  icon_counts = Hash.new(0)
  unwanted_words = ['gray', 'red', 'spin', 'pink', '#{icon}', '#{classes}', 'blue', 'green', 'stack-1x', 'lg', 'spinner-pink', 'fw', 'coral', 'solid', 'nil']

  Find.find(directory) do |path|
    next unless File.file?(path)
    next unless ['.rb', '.erb', '.haml', '.slim'].include?(File.extname(path)) # Add other file types if needed

    File.open(path, 'r') do |file|
      file.each_line do |line|
        # Match all fa_icon patterns: fa_icon "icon", fa_icon :icon, fa_icon(:icon, fa_icon("icon")
        line.scan(/fa_icon\s*["']([^"']+)["']|fa_icon\s*:\s*([a-zA-Z_]+)|fa_icon\(\s*:\s*([a-zA-Z_]+)|fa_icon\(\s*["']([^"']+)["']\s*\)|icon_name:\s*:\s*([a-zA-Z_]+)|icon:\s*:\s*([a-zA-Z_]+)|icon_name:\s*["']([^"']+)["']/) do |match|
          icon = match.compact.first # Get the matched icon name, whether it's a string or symbol
          # Further clean icon by removing unwanted words directly, in case they are not separated by underscores
          cleaned_icon = icon.split.reject { |word| unwanted_words.include?(word) }.join

          icon_counts[cleaned_icon] += 1 unless cleaned_icon.empty?
        end
      end
    end
  end

  icon_counts
end

# Function to generate the .csv file
def generate_csv(icon_counts, output_file)
  CSV.open(output_file, 'w') do |csv|
    csv << ["Icon Name", "Count"]
    icon_counts.each do |icon, count|
      csv << [icon, count]
    end
  end
end

# Main execution
directory = '/Users/dimashevchenko/daisybill/daisybill' # Change this to your Rails project path
output_file = 'icon_counts.csv'

icon_counts = count_fa_icons(directory)
generate_csv(icon_counts, output_file)

puts "Icon counts have been written to #{output_file}"
