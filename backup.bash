#!/bin/bash

# rsync
rsync -av --delete -e 'ssh -p 63501' /mnt/lixq/vod/Work root@lixq-el5:/home/lixq/backup/
rsync -av --delete -e 'ssh -p 63501' /mnt/lixq/vod/Work root@lixq-el6:/home/lixq/backup/
rsync -av --delete -e 'ssh -p 63501' /mnt/lixq/vod/Work root@lixq-el7:/home/lixq/backup/
rsync -av --delete -e 'ssh -p 63501' /mnt/lixq/vod/sbin root@lixq-el5:/home/lixq/backup/
rsync -av --delete -e 'ssh -p 63501' /mnt/lixq/vod/sbin root@lixq-el6:/home/lixq/backup/
rsync -av --delete -e 'ssh -p 63501' /mnt/lixq/vod/sbin root@lixq-el7:/home/lixq/backup/
sb=$(ls /mnt/lixq/vod/trunk/ | tail -n 1)
rsync -arv -e 'ssh -p 63501' /mnt/lixq/vod/trunk/$sb /mnt/lixq/vod/lixq/$sb* root@lixq-el5:/root/vod/
rsync -arv -e 'ssh -p 63501' /mnt/lixq/vod/trunk/$sb /mnt/lixq/vod/lixq/$sb* root@lixq-el6:/root/vod/
rsync -arv -e 'ssh -p 63501' /mnt/lixq/vod/trunk/$sb /mnt/lixq/vod/lixq/$sb* root@lixq-el7:/root/vod/

for i in 5 6 7; do
    echo lixq-el$i
    ssh root@lixq-el$i -p 63501 'du -csh /home/lixq/backup/*'
    echo
done
