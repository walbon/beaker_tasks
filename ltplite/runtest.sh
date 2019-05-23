#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /kernel/root/Regression/ltplite
#   Description: small set of ltp testing for kernel validating
#   Author: Gustavo Walbon <gwalbon@linux.ibm.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2019 Red Hat, Inc.
#
#   This program is free software: you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation, either version 2 of
#   the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE.  See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see http://www.gnu.org/licenses/.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include Beaker environment
. /usr/bin/rhts-environment.sh || exit 1
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="ltplite"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
	rlRun "yum install -y unzip autoconf automake make clang gcc findutils redhat-lsb-core"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "curl -O https://codeload.github.com/linux-test-project/ltp/zip/master" 0 "Getting latest LTP"
        rlAssertExists "master.zip"
        rlRun "unzip -o master" 0 "Extracting the LTP"
        rlAssertExists "ltp-master"
        rlRun "cd ltp-master" 0 "Accessing directory ltp-master"
        rlRun "make autotools && .configure" 0 "Setup pre building"
        rlRun "make all" 0 "Building LTP"
        rlRun "make install" 0 "Default installation"
        rlRun "egrep -wv \"fs|dio|cve|controllers\" scenario_groups/default > runtest/ltplite" 0 "Creating the set of tests for ltplite"
	rlAssertExists "runtest/ltplite"
	rlRun "/opt/bin/runltp -f ltplite" 0 "Run LTP Lite"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
