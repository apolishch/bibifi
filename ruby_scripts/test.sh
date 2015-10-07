#!/bin/bash
cd "/root/install/tests/"

./run_tests.py core/core1.json
./run_tests.py core/core2.json
./run_tests.py core/core3.json
./run_tests.py core/core4.json
./run_tests.py core/core5.json
./run_tests.py core/core6.json

./run_tests.py core/createaccount.json
./run_tests.py core/deposit.json
./run_tests.py core/withdraw.json
./run_tests.py core/getbalance.json

./run_tests.py performance/1.json
./run_tests.py performance/2.json
./run_tests.py performance/3.json
./run_tests.py performance/4.json
./run_tests.py performance/5.json
./run_tests.py performance/6.json
./run_tests.py performance/7.json
./run_tests.py performance/8.json
./run_tests.py performance/9.json
./run_tests.py performance/10.json

./run_tests.py core/invalid1.json
./run_tests.py core/timeout1.json