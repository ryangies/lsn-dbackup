use strict;
use lib qq(/code/src/lib/perl);
use Perl::Options qw(my_opts);
use App::Console::Prompts qw(prompt_Yn prompt_yN);
use App::Console::Color qw(c_printf);
use Data::Hub::Util qw(dir_remove);

my $OPTS = my_opts(\@ARGV, {
  'daily' => 30,
  'monthly' => 12,
  'verbose' => 0,
  'interactive' => 1,
# 'log' => undef, # TODO - Write messages to log file
});

sub ONE_HOUR  {60 * 60;}
sub ONE_DAY   {60 * 60 * 24;}
sub ONE_MONTH {60 * 60 * 24 * 30;}
sub ONE_YEAR  {60 * 60 * 24 * 365.25;}

sub _printf {
  return unless $$OPTS{'verbose'};
  c_printf(shift, @_);
}

sub _notify {
  my $info = shift;
  my $message = sprintf '%10s: %02d/%02d/%04d (%s)',
      ($$info{'keep'} ? ucfirst($$info{'reason'}) : 'Remove'),
      $$info{'month'},
      $$info{'day'},
      $$info{'year'},
      $$info{'name'};
  my $color = $$info{'keep'} ? 'g' : 'r';
  _printf("%_${color}s\n", $message);
}

my $dir = shift @ARGV;
my $max_daily = $$OPTS{'daily'} * ONE_DAY;
my $max_monthly = $$OPTS{'monthly'} * ONE_MONTH;
my $now = time;
my %yearly;
my %monthly;

die "Invalid directory: $dir" unless -d $dir;
die "Invalid option: --daily" unless $max_daily =~ /^\d+$/;
die "Invalid option: --monthly" unless $max_monthly =~ /^\d+$/;

opendir DIR, $dir;
my @listing = grep /^\d{8}\.\d{3,}/, readdir DIR;
closedir DIR;

my @keep = ();
my @remove = ();
my $rc = 0;

foreach my $name (reverse sort @listing) {
  my $path = "$dir/$name";
  my ($y,$m,$d,$v) = $name =~ /^(\d{4})(\d{2})(\d{2})\.(\d{3,})$/;
  my $seconds = `date --date $y$m$d +%s`;
  chomp $seconds;
  my $age = $now - $seconds;
  my $keep = 0;
  my $reason = undef;
  if ($age < $max_daily) {
    $keep = 1;
    $reason = 'daily';
  }
  if (!$yearly{$y}) {
    $yearly{$y} = $name;
    $keep = 1;
    $reason ||= 'yearly';
  }
  if ($age < $max_monthly) {
    if (!$monthly{"$y$m"}) {
      $monthly{"$y$m"} = $name;
      $keep = 1;
      $reason ||= 'monthly';
    }
  }
  my $info = {
    reason => $reason,
    keep => $keep,
    dir => $dir,
    name => $name,
    age => $age,
    year => $y,
    month => $m,
    day => $d,
    revision => $v,
    path => $path,
  };
  my $bucket = $keep ? \@keep : \@remove;
  push @$bucket, $info;
  _notify($info);
}

if (@remove) {
  my $remove_total = @remove;
  if (!$$OPTS{'interactive'} || prompt_yN("Remove $remove_total images")) {
    my $remove_count = 0;
    foreach my $info (@remove) {
      my $path = $$info{'path'};
      $remove_count++;
      _printf("[%03d/%03d] Removing: %s\n", $remove_count, $remove_total, $path);
      if (!dir_remove($path)) {
        $remove_count--;
        warn "[STOPPING] Could not remove: $path!\n";
        last;
      }
    }
    if (my $remove_failed = ($remove_total - $remove_count)) {
      warn "Failed to remove $remove_failed images!\n";
      $rc = 1;
    }
  }
}

exit $rc;
