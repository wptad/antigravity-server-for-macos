#!/bin/bash

# 复制 authorized_keys（如果存在）
if [ -f /tmp/authorized_keys ]; then
    cp /tmp/authorized_keys /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# 启动 sshd
exec /usr/sbin/sshd -D
