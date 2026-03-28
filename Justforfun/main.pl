#!/usr/bin/perl

# Use strict and warnings for good practice and to catch common errors
use strict;
use warnings;

# Use the Getopt::Long module to handle command-line options
use Getopt::Long;
# Use the Fcntl module for file open modes
use Fcntl qw(:all);

# Define variables
my $input_file = '';
my %word_freq;
my $total_words = 0;
my $help = 0;

# Process command-line arguments
GetOptions(
    'file=s' => \$input_file,
    'help'   => \$help,
) or die "Invalid options passed to $0\n";

# Display help message if requested or no file is provided
if ($help || !$input_file) {
    print "Usage: perl $0 --file <filename>\n";
    print "Options:\n";
    print "  --file <filename>  Specify the input text file to process.\n";
    print "  --help             Display this help message.\n";
    exit;
}

# Open the input file for reading
# Use 'my $fh' for a file handle in a lexical scope
# 'open' is the standard way to open files in Perl
unless (open(my $fh, '<', $input_file)) {
    die "Cannot open file '$input_file' for reading: $!\n";
}

# Read the file line by line and process the words
while (my $line = <$fh>) {
    # Remove leading/trailing whitespace and convert to lowercase for consistent counting
    $line =~ s/^\s+|\s+$//g;
    $line = lc($line);

    # Split the line into words, using non-word characters as delimiters
    # The regex m/[^\w'-]+/ handles various punctuation and spaces
    my @words = split(/[^\w'-]+/, $line);

    # Iterate over each word in the list
    foreach my $word (@words) {
        # Skip empty strings that might result from the split operation
        next unless length $word;
        
        # Increment the frequency count for the word in the hash
        $word_freq{$word}++;
        $total_words++;
    }
}

# Close the file handle
close($fh);

# Print the results
print "--- Word Frequency Report ---\n";
print "Total words processed: $total_words\n\n";
print "Word: Frequency\n";
print "-----------------\n";

# Iterate through the hash and print the word frequencies
# 'sort keys %word_freq' sorts the words alphabetically
foreach my $word (sort keys %word_freq) {
    my $count = $word_freq{$word};
    printf "%-20s %d\n", $word, $count;
}

print "---------------------------\n";

# End of script
exit;
