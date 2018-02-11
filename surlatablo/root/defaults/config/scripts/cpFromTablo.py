#!/usr/bin/python

import datetime
import os
import re
import subprocess
import sys
import tempfile


def log(level='Info', message='Your message goes here!'):
    """A simply logging interface.

    Maintains consistency of logging look and feel.
    """
    NOW = datetime.datetime.now()
    print ("{0:8s}".format("[%s] " % level)) + NOW.strftime("%m/%d/%y %I:%M%p") + " - %s " % message


def run_cmd(cmd):
    """Return, as a tuple, a command line return code, stdout, and stderr.

    Runs the command on commandline and writes results to a temp file.
    """
    ON_POSIX = 'posix' in sys.builtin_module_names

    my_output = tempfile.NamedTemporaryFile(delete=False, suffix=".txt")
    return_code = -999

    try:
        return_code = subprocess.call(cmd, close_fds=ON_POSIX, shell=True,
                                      stdout=my_output, stderr=my_output)
    except OSError:
        log('Error', 'Execution of cmd=%s failed' % cmd)
    my_output.close()

    my_input = open(my_output.name, 'r').readlines()
    os.unlink(my_output.name)
    result = (return_code, "".join(my_input))
    return result


def get_md_resync():
    """Should we fetch from the tablo?

    Tries to determine linux software RAID parity check status, and
    returns True as long as the parity check is not found to be in progress.

    Linux software RAID status is stored in /proc/mdstat.  It can
    be parsed for
         mdResync=1   (parity check is in progress)
         mdResync=0   (parity chcck is not in progress)

    If neither is found, perform the fetch.
    """
    # A failed match means no parity check is in progress,
    # since either the `mdResync` string does not exist (software RAID disabled),
    # or it the value is zero (parity check not in progress).
    cmd = 'cat /proc/mdstat | egrep "mdResync=[^0]"'
    (cmd_return_code, cmd_out) = run_cmd(cmd)

    pf = True
    if not cmd_return_code:
        pf = False
        log('Warn', 'Skipping fetch from tablo due to parity sync in progress')
    return pf


if __name__ == '__main__':
    """
    COPY_WINDOW:  shows which aired more recently than (TODAY - COPY_WINDOW) will be copied from the tablo.
        This helps make sure we do not miss any shows if the server is down for a bit of time for
        maintenance or any unscheduled outages.

    DEL_WINDOW:  shows which are older than (TODAY - DEL_WINDOW) will be deleted from the tablo.  This duration
        is probably best to be kept at an order of magnitude greater than the COPY_WINDOW, so that there
        is an opportunity to grab files manually in the rare case of them being missed originally.
    """
    COPY_WINDOW = datetime.timedelta(days=2)
    DEL_WINDOW = datetime.timedelta(weeks=8)
    SURLATABLO_PY = '/config/scripts/surlatablo.py'
    NOW = datetime.datetime.now()
    CURRENT_HOUR = datetime.datetime.time(NOW).hour
    AUTO_DEL_WARN = 7

    if get_md_resync():
        # log('Info', 'Querying tablo for new shows')
        cmd_list = [SURLATABLO_PY, '--query', 'lair_date~=""']
        cmd = " ".join(cmd_list)
        (cmd_return_code, cmd_out) = run_cmd(cmd)
        if not cmd_return_code:
            for line in cmd_out.splitlines():

                try:
                    (rec_id, date, meta_type, title) = line.split("\t")
                except ValueError:
                    continue

                time_delta = datetime.date.today() - datetime.datetime.strptime(date, '%Y-%m-%d').date()
                if time_delta <= COPY_WINDOW:
                    cmd_list = None
                    if meta_type == 'TV':
                        cmd_list = [SURLATABLO_PY, '--query', 'rec_id~=' + rec_id, '--convert', '--ccaption']
                    elif meta_type == 'MOVIE':
                        cmd_list = [SURLATABLO_PY, '--query', 'rec_id~=' + rec_id, '--convert', '--zapcommercials', 'Mp4z']
                    if cmd_list is not None:
                        cmd = " ".join(cmd_list)
                        (cmd_return_code, cmd_out) = run_cmd(cmd)
                        if not re.search('try --clobber', cmd_out):
                            log('Info', 'Retrieved: %s' % line)
                elif time_delta >= DEL_WINDOW:
                    if meta_type == 'TV':
                        cmd_list = [SURLATABLO_PY, '--query', 'rec_id~=' + rec_id, '--convert', '--noprotected', 'DeleteX']
                        log('Info', 'Deleted: %s' % line)
                    elif CURRENT_HOUR % 24 == 0:
                        log ('Info', 'Consider deleting: %s' % line)
                elif CURRENT_HOUR % 24 == 0:
                    time_until_auto_delete = DEL_WINDOW - time_delta
                    if time_until_auto_delete.days <= AUTO_DEL_WARN:
                        log('Warn', 'Auto delete in %d days: %s' % (time_until_auto_delete.days, line))
