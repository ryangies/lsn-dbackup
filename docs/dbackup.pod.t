=head1 NAME

  [#name] - [#summary]

=head1 SYNOPSIS

  [#name] {target} {bank} [options] [rsync-options]

where:

  {target}                That which is to be backed up
  {bank}                  The root of where the backups will go

options:

  -y|--non-interactive    Answers yes to all prompts
  -r|--resume             Resume (or re-run) the last backup
  --                      Stops local option processing

rsync-options:

  Additional options passed to C<rsync>. These options are already enabled:

  [#:for (opt) in rsync_opts]
    [#opt]
  [#:end for]

=head1 DESCRIPTION

Files are fetched using rsync to a local directory. The destination files are
hard linked as described by Mike Rubel:

  http://www.mikerubel.org/computers/rsync_snapshots/

notes:

  * rysnc-2.5.6 or later is required (as we use --link-dest)
  * output format: {bank}/example.com/path_to_directory/20100225.001
  * use full paths (user@example.com:/home/user/dir instead of 
    user@example.com:dir so that the output path is unique per user.
  * options must be separate, i.e., "-r -y", not "-ry"
  * local directory backups use the domain name returned by hostname
  * thank you: http://www.mikerubel.org/computers/rsync_snapshots/

examples:

  # Local backup
  [#name] /home/my/Documents /var/backup

  # Pull files from example.com without prompting to continue
  [#name] example.com:/var/www /var/backup -y

  # Pass an excludes list to rsync
  [#name] example.com:/var/www /var/backup --exclude-from ./excludes

exit:

  0         Success
  1         Syntax or usage error
  2 - 35    See rsync
  256       Another backup is running the proposed job

__DATA__

name => lsn-dbackup
summary => Disk-based backup utility
rsync_opts => @{
  --archive
  --numeric-ids
  --delete-during
  --delete-excluded
  --ignore-existing
  --hard-links
  --safe-delete
}
