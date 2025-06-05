use strict;
use warnings;

my $file_path = shift @ARGV;
die "Usage: $0 <filepath>\n" unless $file_path;

my $complexity = 0;
my $module_loaded = 0;
my $using_fallback = 0;

# Try to use Perl::Metrics::Simple
eval {
    require Perl::Metrics::Simple;
    Perl::Metrics::Simple->import();
    my $analyzer = Perl::Metrics::Simple->new(filenames => [$file_path]);
    my $metrics_ref = $analyzer->calculate_metrics(); # Should be $metrics_ref

    # Ensure $metrics_ref is an array reference and has elements
    if (ref($metrics_ref) eq 'ARRAY' && @$metrics_ref) {
        my $metrics = $metrics_ref->[0]{metrics}; # Access the hashref of metrics
        my $mccabe_key;

        # Try to find a standard McCabe complexity key
        for my $key (qw(mccabe_complexity cyclomatic_complexity mccabe cyclo)) {
            if (exists $metrics->{$key}) {
                $mccabe_key = $key;
                last;
            }
        }

        # If not found, search more broadly
        unless ($mccabe_key) {
            for my $key (keys %$metrics) {
                if ($key =~ /mccabe/i || $key =~ /cyclo/i) {
                    $mccabe_key = $key;
                    last;
                }
            }
        }

        if ($mccabe_key && defined $metrics->{$mccabe_key}) {
            $complexity = $metrics->{$mccabe_key};
            $module_loaded = 1;
        } else {
            die "Perl::Metrics::Simple did not return a recognizable cyclomatic complexity metric.\n";
        }
    } else {
        die "Perl::Metrics::Simple->calculate_metrics() returned unexpected data structure.\n";
    }
};

if (!$module_loaded || $@) {
    # print STDERR "Warning: Perl::Metrics::Simple failed or not available. Falling back to keyword counting for $file_path. Error: $@\n" if $@;
    $using_fallback = 1; # Mark that fallback is being used
    open my $fh, '<', $file_path or die "Could not open file '$file_path' $!\n";
    my $content = do { local $/; <$fh> };
    close $fh;

    my $keyword_count = 0;
    # Using word boundaries \b for more accurate keyword matching.
    $keyword_count += () = $content =~ /\bif\b/g;
    $keyword_count += () = $content =~ /\belsif\b/g; # 'else if' is caught by 'if' and 'else'
    $keyword_count += () = $content =~ /\belse\b/g;
    $keyword_count += () = $content =~ /\bfor\b/g;
    $keyword_count += () = $content =~ /\bforeach\b/g; # Common Perl loop
    $keyword_count += () = $content =~ /\bwhile\b/g;
    $keyword_count += () = $content =~ /\buntil\b/g;
    $keyword_count += () = $content =~ /\bgiven\b/g;
    $keyword_count += () = $content =~ /\bwhen\b/g;
    $keyword_count += () = $content =~ /\bunless\b/g;
    $keyword_count += () = $content =~ /&&/g;      # Logical AND
    $keyword_count += () = $content =~ /\|\|/g;    # Logical OR
    $keyword_count += () = $content =~ /\bdefined\s*\(/g; # consider defined() as a branch point
    $keyword_count += () = $content =~ /\?\?/g;    # Defined-Or operator (Perl 5.10+)
    $keyword_count += () = $content =~ /\bcatch\b/g; # For try/catch blocks if any (e.g. Try::Tiny)

    # Ternary operator: a ? b : c. The '?' is the branch point.
    # This regex is a bit simplistic for nested ternaries but okay for a fallback.
    $keyword_count += () = $content =~ /\S\s*\?\s*\S/g;


    $complexity = 1 + $keyword_count;
}

my $func_name = $file_path;
if ($func_name =~ m|untested_fn_sources/([^/]+)\.pl$|) { # More robust extraction
    $func_name = $1;
} else {
    $func_name =~ s|\.pl$||; # Basic fallback if path is unexpected
}

# Indicate if fallback was used in the output for clarity during this execution.
# my $indicator = $using_fallback ? "(fallback)" : "";
# print "$func_name $complexity $indicator\n";
print "$func_name $complexity\n"; # Final version as per spec: function_name complexity_score
