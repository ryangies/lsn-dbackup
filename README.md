lsn-dbackup
===========

Disk-based backup using hard links to reduce vault size. This script is based on the strategy explained here:
http://www.mikerubel.org/computers/rsync_snapshots/

<pre>
usage:
  dbackup {target} {bank} [options] [rsync-options]
where:
  {target}                That which is to be backed up
  {bank}                  The root of where the backups will go
options:
  -y|--non-interactive    Answers yes to all prompts
  -l|--log                Append log messages to a local file
  -v|--verbose            Increase the verbosity of informational messages
  -r|--resume             Resume (or re-run) the last backup
  --                      Stops local option processing
rsync-options:
  Additional options passed to /usr/bin/rsync. These options are already enabled:
    --archive
    --numeric-ids
    --hard-links
    --safe-links
notes:
  * thank you: http://www.mikerubel.org/computers/rsync_snapshots/
  * rysnc-2.5.6 or later is required (as we use --link-dest)
  * output format: {bank}/example.com/path_to_directory/20100225.001
  * use full paths (user@example.com:/home/user/dir instead of
    user@example.com:dir so that the output path is unique per user.
  * options must be separate, i.e., "-r -y", not "-ry"
  * local directory backups use the domain name returned by hostname
  * not all version of rsync support '--log-file' which is used for
    the -l|--log option.  if you have this support, the log file is
    found at: {bank}/example.com/path_to_directory/.log
examples:
  # Local backup
  dbackup /home/my/Documents /var/backup
  # Pull files from example.com without prompting to continue
  dbackup example.com:/var/www /var/backup -y
  # Pass an excludes list to rsync
  dbackup example.com:/var/www /var/backup --exclude-from ./excludes
exit:
  0         Success
  1         Syntax or usage error
  2 - 35    See rsync
  256       Another backup is running the proposed job
</pre>
