#!/usr/bin/env python3

__version__ = '0.0.1'


import argparse
import subprocess
import os
import sys
import grp
import pwd


parser = argparse.ArgumentParser()

parser.add_argument("--workdir", default="/workdir",
                    help="Directory of the mounted volume in the container")

# Swallow the rest of the args passed in
parser.add_argument("args", default="", nargs=argparse.REMAINDER)

args = parser.parse_args()

username ="builder"

if os.path.exists(args.workdir):
    st = os.stat(args.workdir)
    uid, gid = st.st_uid, st.st_gid
else:
    print("""
        Error - either;
            * the docker run command does not mount a volume
            * the volume path specified in the docker run command does not match the path the container expects

                Usage: docker container run -it --rm -v /workdir:/workdir <image_name>
    """)
    sys.exit(1)

if uid == 0 or gid ==0:
    print("The workdir passed in can not be owned by root")
    sys.exit(1)

try:
    grp.getgrgid(gid)
except KeyError:
    cmd = "sudo groupadd -o -g {} {}".format(gid, username)
    subprocess.check_call(cmd.split(), stdout=sys.stdout, stderr=sys.stderr)

try:
    pwd.getpwuid(uid)
except KeyError:
    cmd = "sudo useradd -g {} -m -o -u {} {}".format(gid, uid, username)
    subprocess.check_call(cmd.split(), stdout=sys.stdout, stderr=sys.stderr)

assert username == "builder", "sudoers file expects username to be builder"

cmd = "sudo -E -H -u {} ".format(username)
cmd = cmd.split() + ["builder-launch.sh"] + [args.workdir] + args.args
os.execvp(cmd[0], cmd)
