#!/bin/bash
# Weekly backup of ~/weewx51 (felddy/weewx + nginx). Runs from root crontab:
#   0 23 * * 0 /home/jkozik/weewx51/weewxbck.sh >> /home/jkozik/weewx51/weewxbck.log 2>&1
# The weewxrtlsdr project has its own script: ~/projects/weewxrtlsdr/weewxrtlsdrbck.sh
#
# weewx.sdb is copied with SQLite's online backup API (consistent snapshot
# while weewxd keeps writing; no container stop). FTP login is read from a
# chmod-600 file shared with the weewxrtlsdr backup.
BCKDIR=/backup/weewxBck
WEEWXHOME=/home/jkozik/weewx51
FTPCFG=/home/jkozik/.ncftp-backup.cfg
FTPDIR=/weewx
KEEP_DAYS=84

echo "=== weewx51 backup $(/bin/date) ==="
if [[ ! -d ${BCKDIR}${WEEWXHOME} ]]; then
 echo creating ${BCKDIR}${WEEWXHOME};
 mkdir -p ${BCKDIR}${WEEWXHOME}
fi
rsync -avz --exclude 'data/archive/weewx.sdb' $WEEWXHOME ${BCKDIR}${WEEWXHOME} || { echo "rsync FAILED"; exit 1; }

# Snapshot the live database into the same spot rsync used to put it
python3 - ${WEEWXHOME}/data/archive/weewx.sdb ${BCKDIR}${WEEWXHOME}/weewx51/data/archive/weewx.sdb <<'EOF' || { echo "db snapshot FAILED"; exit 1; }
import sqlite3, sys
src = sqlite3.connect(f"file:{sys.argv[1]}?mode=ro", uri=True)
dst = sqlite3.connect(sys.argv[2])
src.backup(dst)
print(sys.argv[2], dst.execute("pragma integrity_check").fetchone()[0])
dst.close(); src.close()
EOF

touch /backup/weewxbackupage

DATE=`/bin/date +%Y%m%d`
TIME=`/bin/date +%H`
BCKUPFILE="/backup/weewx.$DATE.$TIME.tar.gz"
tar czf $BCKUPFILE  --exclude='.*' ${BCKDIR}/ || { echo "tar FAILED"; exit 1; }
ls -l $BCKUPFILE

ncftpput -f $FTPCFG $FTPDIR $BCKUPFILE && echo "ftp upload OK" || echo "ftp upload FAILED"

# Retention: keep ~12 weeks of local tarballs (copies also go to FTP .143).
# Only prune if today's tarball was created, so a failing backup never
# deletes the last good ones.
if [[ -s $BCKUPFILE ]]; then
 echo "pruning tarballs older than ${KEEP_DAYS} days:"
 find /backup -maxdepth 1 -name 'weewx.*.tar.gz' -mtime +${KEEP_DAYS} -print -delete
fi
